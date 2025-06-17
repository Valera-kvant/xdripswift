// HematonixManager.swift
// xDripSwift private build — "personal plugin" for Hematonix CGM
// ---------------------------------------------------------------
// 1.  *Passive* BLE listener: не подключается по GATT, а слушает рекламные
//     пакеты (ADV_EXT_IND / ADV_NONCONN_IND).
// 2.  В каждом пакете ищет:
//     • Manufacturer Specific Data (Company 0x0006)
//     • Service‑Data UUID 0xFD5A
//     • Кастомный AD‑Type 0xE4 длиной 0x74 (116 B).
// 3.  Алгоритм декодирования минималистский: первый «плавающий» байт равен
//     mmol × 10 (пример: 0x61 → 97 → 9.7 mmol/L).
//     Формула вынесена в HematonixDecoder — при изменении формата правим там.
// 4.  UID сенсора (из QR) передаётся при инициализации и служит фильтром,
//     чтобы ловить только «свои» пакеты, если рядом несколько пользователей.
// ---------------------------------------------------------------
//  Использование:
//      let hemi = HematonixManager(uid: "9MHU675SK")
//      hemi.glucosePublisher.sink { GlucoseStore.shared.add($0) }
// ---------------------------------------------------------------

import CoreBluetooth
import Combine

// MARK: – Main manager
final class HematonixManager: NSObject, CBCentralManagerDelegate {

    // Public stream → подписываемся в DeviceManager
    let glucosePublisher = PassthroughSubject<Glucose, Never>()

    // UID сенсора (9 символов из QR).  Если nil — принимаем все пакеты.
    private let sensorUID: String?

    // BLE
    private lazy var central = CBCentralManager(delegate: self, queue: .main)

    // Constants
    private let companyID: UInt16 = 0x0006           // Manufacturer Specific (MSD)
    private let svcUUID  = CBUUID(string: "FD5A")   // Service‑Data UUID

    init(uid: String? = nil) {
        self.sensorUID = uid?.uppercased()
        super.init()
    }

    // MARK: – CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }
        central.scanForPeripherals(withServices: nil,
                                   options: [.allowDuplicates: true])
        print("HematonixManager ▶︎ scanning BLE…")
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {

        // —–––– 1) Manufacturer Specific
        if let msd = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
           msd.count >= 4,                     // 2 B company + ≥2 B payload
           msd.toUInt16(0) == companyID,
           let mmol = HematonixDecoder.decode(msd.dropFirst(2)) {
            push(mmol, from: peripheral)
            return
        }

        // —–––– 2) Service Data FD5A
        if let svc = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data],
           let blob = svc[svcUUID],
           let mmol = HematonixDecoder.decode(blob) {
            push(mmol, from: peripheral)
            return
        }

        // —–––– 3) RAW "unknown" AD type (0xE4, 0x74 bytes)
        if let ext = advertisementData["kCBAdvDataExtendedData"] as? Data, // non‑public key; works iOS 13+
           let mmol = HematonixDecoder.decodeExtended(ext) {
            push(mmol, from: peripheral)
        }
    }

    // MARK: – Private
    private func push(_ mmol: Double, from peripheral: CBPeripheral) {
        // фильтруем по UID, если задан
        if let uid = sensorUID, !peripheral.identifier.uuidString.hasSuffix(uid) {
            return
        }
        let g = Glucose(date: .now,
                        mmol: mmol,
                        mgdl: mmol * 18.0,
                        source: .BLE,
                        sensorID: peripheral.identifier.uuidString)
        glucosePublisher.send(g)
        print("Hematonix ▶︎ \(mmol, specifier: "%.1f") mmol/L  RSSI=\(peripheral.rssi ?? .zero)")
    }
}


import Foundation
import CoreBluetooth
import os

/// Bluetooth transmitter implementation for Hematonix CGM.
/// It passively listens for BLE advertisements and decodes
/// glucose values from manufacturer and service data.
final class CGMHematonixTransmitter: BluetoothTransmitter, CGMTransmitter {
    /// Delegate receiving CGM transmitter events.
    private weak var cgmTransmitterDelegate: CGMTransmitterDelegate?

    /// Optional sensor UID used to filter packets from other sensors.
    private let sensorUID: String?

    /// Manufacturer and service identifiers.
    private let companyID: UInt16 = 0x0006
    private let svcUUID = CBUUID(string: "FD5A")

    /// Logging
    private let log = OSLog(subsystem: ConstantsLog.subSystem,
                            category: ConstantsLog.categoryBlueToothTransmitter)

    /// Create a new Hematonix transmitter listener.
    /// - Parameters:
    ///   - sensorUID: Optional sensor UID to filter packets.
    ///   - bluetoothTransmitterDelegate: delegate for Bluetooth events.
    ///   - cgmTransmitterDelegate: delegate for CGM readings.
    init(sensorUID: String?,
         bluetoothTransmitterDelegate: BluetoothTransmitterDelegate,
         cgmTransmitterDelegate: CGMTransmitterDelegate?) {
        self.sensorUID = sensorUID?.uppercased()
        self.cgmTransmitterDelegate = cgmTransmitterDelegate
        super.init(addressAndName: .notYetConnected(expectedName: nil),
                   CBUUID_Advertisement: nil,
                   servicesCBUUIDs: nil,
                   CBUUID_ReceiveCharacteristic: "",
                   CBUUID_WriteCharacteristic: "",
                   bluetoothTransmitterDelegate: bluetoothTransmitterDelegate)
    }

    // MARK: - CBCentralManagerDelegate
    override func centralManagerDidUpdateState(_ central: CBCentralManager) {
        super.centralManagerDidUpdateState(central)
        guard central.state == .poweredOn else { return }
        central.scanForPeripherals(withServices: nil,
                                   options: [.allowDuplicates: true])
        os_log("Hematonix ▶︎ scanning BLE…", log: log, type: .info)
    }

    override func centralManager(_ central: CBCentralManager,
                                 didDiscover peripheral: CBPeripheral,
                                 advertisementData: [String : Any],
                                 rssi RSSI: NSNumber) {
        // Manufacturer specific data
        if let msd = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
           msd.count >= 4,
           msd.toUInt16(0) == companyID,
           let mmol = HematonixDecoder.decode(msd.dropFirst(2)) {
            push(mmol, from: peripheral, rssi: RSSI)
            return
        }

        // Service data
        if let svc = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data],
           let blob = svc[svcUUID],
           let mmol = HematonixDecoder.decode(blob) {
            push(mmol, from: peripheral, rssi: RSSI)
            return
        }

        // Extended data block
        if let ext = advertisementData["kCBAdvDataExtendedData"] as? Data,
           let mmol = HematonixDecoder.decodeExtended(ext) {
            push(mmol, from: peripheral, rssi: RSSI)
        }
    }

    // MARK: - Helpers
    private func push(_ mmol: Double, from peripheral: CBPeripheral, rssi: NSNumber) {
        if let uid = sensorUID, !peripheral.identifier.uuidString.hasSuffix(uid) {
            return
        }
        var glucoseData = [GlucoseData(timeStamp: Date(), glucoseLevelRaw: mmol * 18.0)]
        cgmTransmitterDelegate?.cgmTransmitterInfoReceived(glucoseData: &glucoseData,
                                                            transmitterBatteryInfo: nil,
                                                            sensorAge: nil)
        os_log("Hematonix ▶︎ %.1f mmol/L  RSSI=%{public}@", log: log, type: .info, mmol, rssi)
    }

    // MARK: - CGMTransmitter
    func cgmTransmitterType() -> CGMTransmitterType {
        return .Hematonix
    }

    func getCBUUID_Service() -> String { "" }
    func getCBUUID_Receive() -> String { "" }
}


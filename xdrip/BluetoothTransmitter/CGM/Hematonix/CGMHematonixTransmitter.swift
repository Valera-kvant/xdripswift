import Foundation
import CoreBluetooth
import os

class CGMHematonixTransmitter: BluetoothTransmitter, CGMTransmitter {

    private let companyID: UInt16 = 0x0006
    private let svcUUID = CBUUID(string: "FD5A")
    private let sensorUID: String?
    private let log = OSLog(subsystem: ConstantsLog.subSystem, category: "CGMHematonix")
    private weak var cgmTransmitterDelegate: CGMTransmitterDelegate?

    init(address: String?, name: String?, bluetoothTransmitterDelegate: BluetoothTransmitterDelegate, cGMTransmitterDelegate: CGMTransmitterDelegate, sensorUID: String?) {
        self.sensorUID = sensorUID?.uppercased()
        self.cgmTransmitterDelegate = cGMTransmitterDelegate
        super.init(addressAndName: .notYetConnected(expectedName: "Hematonix"), CBUUID_Advertisement: nil, servicesCBUUIDs: nil, CBUUID_ReceiveCharacteristic: "0000", CBUUID_WriteCharacteristic: "0000", bluetoothTransmitterDelegate: bluetoothTransmitterDelegate)
    }

    override func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: [.allowDuplicates: true])
            trace("CGMHematonix ▶︎ scanning BLE", log: log, category: "CGMHematonix", type: .info)
        }
    }

    override func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let msd = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
           msd.count >= 4,
           msd.toUInt16(0) == companyID,
           let mmol = HematonixDecoder.decode(msd.dropFirst(2)) {
            push(mmol, from: peripheral)
            return
        }

        if let svc = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data],
           let blob = svc[svcUUID],
           let mmol = HematonixDecoder.decode(blob) {
            push(mmol, from: peripheral)
            return
        }

        if let ext = advertisementData["kCBAdvDataExtendedData"] as? Data,
           let mmol = HematonixDecoder.decodeExtended(ext) {
            push(mmol, from: peripheral)
        }
    }

    private func push(_ mmol: Double, from peripheral: CBPeripheral) {
        if let uid = sensorUID, !peripheral.identifier.uuidString.hasSuffix(uid) {
            return
        }
        var data = [GlucoseData(timeStamp: Date(), glucoseLevelRaw: mmol)]
        cgmTransmitterDelegate?.cgmTransmitterInfoReceived(glucoseData: &data, transmitterBatteryInfo: nil, sensorAge: nil)
    }

    // MARK: CGMTransmitter
    func cgmTransmitterType() -> CGMTransmitterType { return .Hematonix }
    func getCBUUID_Service() -> String { "" }
    func getCBUUID_Receive() -> String { "" }
}

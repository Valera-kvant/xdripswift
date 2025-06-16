import Foundation
import CoreBluetooth

class CGMHematonixTransmitter: BluetoothTransmitter, CGMTransmitter {
    private let manager = HematonixManager()

    init(bluetoothTransmitterDelegate: BluetoothTransmitterDelegate) {
        super.init(addressAndName: .notYetConnected(expectedName: "Hematonix"), CBUUID_Advertisement: nil, servicesCBUUIDs: nil, CBUUID_ReceiveCharacteristic: "", CBUUID_WriteCharacteristic: "", bluetoothTransmitterDelegate: bluetoothTransmitterDelegate)
    }

    override func startScanning() -> BluetoothTransmitter.startScanningResult {
        manager.centralManagerDidUpdateState(CBCentralManager())
        return .started
    }

    func setNonFixedSlopeEnabled(enabled: Bool) {}
    func isNonFixedSlopeEnabled() -> Bool { return false }
    func setWebOOPEnabled(enabled: Bool) {}
    func isWebOOPEnabled() -> Bool { return false }
    func overruleIsWebOOPEnabled() -> Bool { return false }
    func isAnubisG6() -> Bool { return false }
    func nonWebOOPAllowed() -> Bool { return true }
    func requestNewReading() {}
    func maxSensorAgeInDays() -> Double? { return nil }
    func startSensor(sensorCode: String?, startDate: Date) {}
    func stopSensor(stopDate: Date) {}
    func calibrate(calibration: Calibration) {}
    func needsSensorStartTime() -> Bool { return true }
    func needsSensorStartCode() -> Bool { return false }
    func cgmTransmitterType() -> CGMTransmitterType { return .Hematonix }
    func getCBUUID_Service() -> String { return "" }
    func getCBUUID_Receive() -> String { return "" }
}

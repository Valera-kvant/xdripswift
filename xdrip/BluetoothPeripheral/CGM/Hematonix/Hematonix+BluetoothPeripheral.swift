import Foundation

extension Hematonix: BluetoothPeripheral {
    func bluetoothPeripheralType() -> BluetoothPeripheralType {
        return .HematonixType
    }
}

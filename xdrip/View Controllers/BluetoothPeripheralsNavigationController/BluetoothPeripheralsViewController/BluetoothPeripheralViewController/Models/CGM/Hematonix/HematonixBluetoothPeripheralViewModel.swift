import Foundation

class HematonixBluetoothPeripheralViewModel {
    /// reference to bluetoothPeripheralManager
    private weak var bluetoothPeripheralManager: BluetoothPeripheralManaging?
    /// temporary reference to bluetoothPerpipheral, will be set in configure function.
    private var bluetoothPeripheral: BluetoothPeripheral?
}

extension HematonixBluetoothPeripheralViewModel: BluetoothPeripheralViewModel {
    func configure(bluetoothPeripheral: BluetoothPeripheral?, bluetoothPeripheralManager: BluetoothPeripheralManaging, tableView: UITableView, bluetoothPeripheralViewController: BluetoothPeripheralViewController) {
        self.bluetoothPeripheralManager = bluetoothPeripheralManager
        self.bluetoothPeripheral = bluetoothPeripheral
    }

    func screenTitle() -> String {
        return BluetoothPeripheralType.HematonixType.rawValue
    }

    func sectionTitle(forSection section: Int) -> String {
        // no specific sections for Hematonix
        return BluetoothPeripheralType.HematonixType.rawValue
    }

    func update(cell: UITableViewCell, forRow rawValue: Int, forSection section: Int, for bluetoothPeripheral: BluetoothPeripheral) {
        // no specific rows to update
    }

    func userDidSelectRow(withSettingRawValue rawValue: Int, forSection section: Int, for bluetoothPeripheral: BluetoothPeripheral, bluetoothPeripheralManager: BluetoothPeripheralManaging) -> SettingsSelectedRowAction {
        return .nothing
    }

    func numberOfSettings(inSection section: Int) -> Int {
        return 0
    }

    func numberOfSections() -> Int {
        return 0
    }
}

import Foundation
import CoreData

extension Hematonix {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hematonix> {
        return NSFetchRequest<Hematonix>(entityName: "Hematonix")
    }

    // blePeripheral is required to conform to protocol BluetoothPeripheral
    @NSManaged public var blePeripheral: BLEPeripheral

}

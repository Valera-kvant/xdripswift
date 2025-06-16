import Foundation
import CoreData

extension Hematonix {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hematonix> {
        return NSFetchRequest<Hematonix>(entityName: "Hematonix")
    }

    @NSManaged public var blePeripheral: BLEPeripheral
}

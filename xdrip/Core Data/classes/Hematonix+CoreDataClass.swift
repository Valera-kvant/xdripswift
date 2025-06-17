import Foundation
import CoreData

public class Hematonix: NSManagedObject {

    /// create Hematonix
    /// - parameters:
    init(address: String, name: String, alias: String?, nsManagedObjectContext: NSManagedObjectContext) {

        let entity = NSEntityDescription.entity(forEntityName: "Hematonix", in: nsManagedObjectContext)!

        super.init(entity: entity, insertInto: nsManagedObjectContext)

        blePeripheral = BLEPeripheral(address: address, name: name, alias: alias, bluetoothPeripheralType: .HematonixType, nsManagedObjectContext: nsManagedObjectContext)
    }

    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

}

import Foundation
import CoreData

public class Hematonix: NSManagedObject {

    public var batteryLevel: Int = 0
    public var sensorState: LibreSensorState = .unknown

    init(address: String, name: String, alias: String?, nsManagedObjectContext:NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Hematonix", in: nsManagedObjectContext)!
        super.init(entity: entity, insertInto: nsManagedObjectContext)
        blePeripheral = BLEPeripheral(address: address, name: name, alias: nil, bluetoothPeripheralType: .HematonixType, nsManagedObjectContext: nsManagedObjectContext)
    }

    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}

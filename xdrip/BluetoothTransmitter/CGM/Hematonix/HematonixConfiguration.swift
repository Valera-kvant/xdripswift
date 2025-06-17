import Foundation

struct HematonixConfiguration: Codable {
    var k: Double
    var b: Double

    static let fileName = "HematonixConfig.json"

    static func load() -> HematonixConfiguration {
        let defaults = UserDefaults.standard
        let k = defaults.object(forKey: UserDefaults.Key.hematonixK.rawValue) as? Double
        let b = defaults.object(forKey: UserDefaults.Key.hematonixB.rawValue) as? Double
        if let k = k, let b = b { return HematonixConfiguration(k: k, b: b) }

        if let url = Bundle.main.url(forResource: "HematonixConfig", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let config = try? JSONDecoder().decode(HematonixConfiguration.self, from: data) {
            return config
        }

        return HematonixConfiguration(k: 0.00056, b: 15.4 - 0.00056 * 265.0)
    }

    func save() {
        let defaults = UserDefaults.standard
        defaults.set(k, forKey: UserDefaults.Key.hematonixK.rawValue)
        defaults.set(b, forKey: UserDefaults.Key.hematonixB.rawValue)
    }
}

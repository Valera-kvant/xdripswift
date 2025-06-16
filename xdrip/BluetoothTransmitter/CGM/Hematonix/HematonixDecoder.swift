enum HematonixDecoder {
    /// ← поставьте СВОИ коэффициенты k и b!
    private static let k = 0.00056
    private static let b = 15.4 - 0.00056 * 265.0

    static func decode(_ payload: Data) -> Double? {
        guard payload.count >= 2 else { return nil }
        let raw = payload.toU16(0)
        let mmol = Double(raw) * k + b
        // sanity-check
        return (2...25).contains(mmol) ? round(mmol * 10)/10 : nil
    }
}

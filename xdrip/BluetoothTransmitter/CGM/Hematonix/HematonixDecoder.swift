enum HematonixDecoder {
    /// ← поставьте СВОИ коэффициенты k и b!
    private static let k = 0.00056
    private static let b = 15.4 - 0.00056 * 265.0

    /// Декодируем Manufacturer / Service‑Data payload
    static func decode(_ payload: Data) -> Double? {
        guard payload.count >= 2 else { return nil }
        let raw = payload.toUInt16(0)
        let mmol = Double(raw) * k + b
        // sanity-check
        return (2...25).contains(mmol) ? round(mmol * 10) / 10 : nil
    }

    /// Декодируем «длинный» блок 0xE4 (ADV_EXT_IND)
    static func decodeExtended(_ blob: Data) -> Double? {
        guard blob.count >= 0x20 else { return nil }
        let raw = blob[0x11]
        let mmol = Double(raw) / 10.0
        return (2...25).contains(mmol) ? mmol : nil
    }
}

extension Data {
    func toUInt16(_ offset: Int) -> UInt16 {
        UInt16(littleEndian: self[offset..<offset + 2].withUnsafeBytes { $0.load(as: UInt16.self) })
    }
}

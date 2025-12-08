import Foundation

public enum JWTUtils {
    public static func expirationDate(from token: String) -> Date? {
        struct Payload: Decodable {
            let exp: TimeInterval?
        }

        let segments = token.split(separator: ".")
        guard segments.count > 1 else { return nil }

        var payload = String(segments[1])
        payload = payload.replacingOccurrences(of: "-", with: "+")
        payload = payload.replacingOccurrences(of: "_", with: "/")
        let remainder = payload.count % 4
        if remainder > 0 {
            payload += String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: payload),
              let decoded = try? JSONDecoder().decode(Payload.self, from: data),
              let exp = decoded.exp
        else {
            return nil
        }

        return Date(timeIntervalSince1970: exp)
    }
}

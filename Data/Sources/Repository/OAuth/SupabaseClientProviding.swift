
import Foundation
import Supabase

public protocol SupabaseClientProviding {
    var client: SupabaseClient { get }
}

public final class SupabaseClientProvider: SupabaseClientProviding {
    public static let shared = SupabaseClientProvider()

    public let client: SupabaseClient

    private init() {
        let configuration = SupabaseConfiguration()
        client = SupabaseClient(
            supabaseURL: configuration.url,
            supabaseKey: configuration.key
        )
    }
}

private struct SupabaseConfiguration {
    let url: URL
    let key: String

    init(
        bundle: Bundle = .supabaseConfiguration
    ) {
        guard let key = bundle.object(forInfoDictionaryKey: "SUPERBASE_KEY") as? String,
              !key.isEmpty else {
            fatalError("SUPERBASE_KEY is missing. Check xcconfig or Info.plist settings.")
        }

        guard let urlString = bundle.object(forInfoDictionaryKey: "SUPERBASE_URL") as? String,
              !urlString.isEmpty else {
            fatalError("SUPERBASE_URL is missing. Check xcconfig or Info.plist settings.")
        }

        guard let url = URL(string: urlString.hasPrefix("http") ? urlString : "https://\(urlString)") else {
            fatalError("SUPERBASE_URL is invalid: \(urlString)")
        }

        self.key = key
        self.url = url
    }
}

private extension Bundle {
    static var supabaseConfiguration: Bundle {
#if SWIFT_PACKAGE
        return .module
#else
        return .main
#endif
    }
}
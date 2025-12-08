import Foundation
import Data
import Domain

extension SseuDamApp {
    func handleKakaoTicket(from url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.host == "oauth",
              components.path == "/kakao",
              let ticket = components.queryItems?.first(where: { $0.name == "ticket" || $0.name == "code" })?.value
        else {
            return
        }
        Task {
            await KakaoAuthCodeStore.shared.save(ticket)
        }
    }
}

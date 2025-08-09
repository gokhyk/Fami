
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: AppUser? = nil
    @Published var authError: String? = nil

    private let service: AuthProviding
    private var listenerToken: AnyObject?

    init(service: AuthProviding) {
        self.service = service
        self.user = service.currentUser
        self.listenerToken = service.observeAuthChanges { [weak self] user in
            Task { @MainActor in self?.user = user }
        }
    }

    func signUp(email: String, password: String) async {
        do {
            _ = try await service.signUp(email: email, password: password)
            authError = nil
        } catch {
            authError = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        do {
            _ = try await service.signIn(email: email, password: password)
            authError = nil
        } catch {
            authError = error.localizedDescription
        }
    }

    func signOut() {
        do {
            try service.signOut()
            authError = nil
        } catch {
            authError = error.localizedDescription
        }
    }
}

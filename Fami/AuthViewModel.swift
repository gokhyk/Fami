
import Foundation
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: AppUser? = nil
    @Published var authError: String? = nil
    
    @Published var activeFamilyId: String? = nil      // 👈 expose it here
    @Published var activeFamilyName: String? = nil    // (optional)

    private let service: AuthProviding
    private var listenerToken: AnyObject?

    init(service: AuthProviding) {
        self.service = service
        self.user = service.currentUser
        self.listenerToken = service.observeAuthChanges { [weak self] user in
            Task { @MainActor in
                self?.user = user
                if let uid = user?.uid {
                    await self?.loadUserProfile(uid: uid)
                } else {
                    self?.activeFamilyId = nil
                    self?.activeFamilyName = nil
                }
            }
        }

        // If app launches & user already signed in, load immediately
        if let uid = service.currentUser?.uid {
            Task { await loadUserProfile(uid: uid) }
        }
    }

    private func loadUserProfile(uid: String) async {
        do {
            let doc = try await Firestore.firestore()
                .collection("appusers")       // 👈 use your actual collection name
                .document(uid)
                .getDocument()

            if let data = doc.data() {
                self.activeFamilyId = data["activeFamilyId"] as? String
                self.activeFamilyName = data["activeFamilyName"] as? String
            } else {
                self.activeFamilyId = nil
                self.activeFamilyName = nil
            }
        } catch {
            authError = error.localizedDescription
        }
    }

    // Call this whenever user switches families
    func saveActiveFamily(uid: String, id: String, name: String?) async {
        do {
            try await Firestore.firestore()
                .collection("appusers")
                .document(uid)
                .setData([
                    "activeFamilyId": id,
                    "activeFamilyName": name ?? NSNull()
                ], merge: true)

            self.activeFamilyId = id
            self.activeFamilyName = name
        } catch {
            authError = error.localizedDescription
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

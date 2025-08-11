
import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AppUser {
    let uid: String
    let email: String?
    let displayName: String?
}

protocol AuthProviding {
    var currentUser: AppUser? { get }
    func signUp(email: String, password: String) async throws -> AppUser
    func signIn(email: String, password: String) async throws -> AppUser
    func signOut() throws
    func observeAuthChanges(_ handler: @escaping (AppUser?) -> Void) -> AnyObject
}

final class AuthService: AuthProviding {
    var currentUser: AppUser? {
        if let u = Auth.auth().currentUser {
            //print(u.uid, u.email, u.displayName)
            return AppUser(uid: u.uid, email: u.email, displayName: u.displayName)
        }
        return nil
    }

    func signUp(email: String, password: String) async throws -> AppUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        // Optional: create user doc in Firestore
        try await createUserDoc(uid: result.user.uid, email: result.user.email)
        return AppUser(uid: result.user.uid, email: result.user.email, displayName: result.user.displayName)
    }

    func signIn(email: String, password: String) async throws -> AppUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return AppUser(uid: result.user.uid, email: result.user.email, displayName: result.user.displayName)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func observeAuthChanges(_ handler: @escaping (AppUser?) -> Void) -> AnyObject {
        let handle = Auth.auth().addStateDidChangeListener { _, user in
            if let u = user {
                handler(AppUser(uid: u.uid, email: u.email, displayName: u.displayName))
            } else {
                handler(nil)
            }
        }
        return handle as AnyObject
    }

    private func createUserDoc(uid: String, email: String?) async throws {
        let db = Firestore.firestore()
        try await db.collection("appusers").document(uid).setData([
            "email": email ?? "",
            "nickname": "",
            "familyIds": [],
            "activeFamilyId": NSNull()
        ])
    }
}

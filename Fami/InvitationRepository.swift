
import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol InvitationRepository {
    func sendInvite(familyId: String, familyName: String, toEmail: String) async throws
    func myInvitations(currentUid: String, currentEmail: String) async throws -> [Invitation]
    func accept(invitation: Invitation, currentUid: String) async throws
    func decline(invitationId: String) async throws
}

final class FirestoreInvitationRepository: InvitationRepository {
    private let db = Firestore.firestore()
    private let col = "invitations"

    func sendInvite(familyId: String, familyName: String, toEmail: String) async throws {
        guard let fromUid = Auth.auth().currentUser?.uid else { throw NSError(domain: "Auth", code: 401) }
        let doc = db.collection(col).document()
        let invite: [String: Any] = [
            "familyId": familyId,
            "familyName": familyName,
            "fromUserId": fromUid,
            "toEmail": toEmail.lowercased(),
            "status": "pending",
            "createdAt": Timestamp(date: Date())
        ]
        try await doc.setData(invite)
    }

    func myInvitations(currentUid: String, currentEmail: String) async throws -> [Invitation] {
        let email = currentEmail.lowercased()
        async let a = db.collection(col)
            .whereField("toUserId", isEqualTo: currentUid)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        async let b = db.collection(col)
            .whereField("toEmail", isEqualTo: email)
            .whereField("status", isEqualTo: "pending")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        let (aSnap, bSnap) = try await (a, b)
        let docs = (aSnap.documents + bSnap.documents)
        var map: [String: QueryDocumentSnapshot] = [:]
        for d in docs {
            map[d.documentID] = d
        }
        return try map.values.map { try $0.data(as: Invitation.self) }
    }

    func accept(invitation: Invitation, currentUid: String) async throws {
        guard let id = invitation.id else { return }
        let invRef = db.collection(col).document(id)
        let famRef = db.collection("families").document(invitation.familyId)
        let usrRef = db.collection("appusers").document(currentUid)

        try await db.runTransaction { tx, _ in
            tx.updateData(["memberIds": FieldValue.arrayUnion([currentUid])], forDocument: famRef)
            tx.updateData([
                "status": "accepted",
                "toUserId": currentUid
            ], forDocument: invRef)
            tx.updateData(["familyIds": FieldValue.arrayUnion([invitation.familyId])], forDocument: usrRef)
            tx.updateData(["activeFamilyId": invitation.familyId], forDocument: usrRef)
            return nil
        }
    }

    func decline(invitationId: String) async throws {
        try await db.collection(col).document(invitationId).updateData(["status": "declined"])
    }
}

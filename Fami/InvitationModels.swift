
import Foundation
import FirebaseFirestore

struct Invitation: Identifiable, Codable {
    @DocumentID var id: String?
    var familyId: String
    var familyName: String
    var fromUserId: String
    var toEmail: String
    var toUserId: String?
    var status: String         // pending | accepted | declined | expired
    var createdAt: Date
    var expiresAt: Date?
}

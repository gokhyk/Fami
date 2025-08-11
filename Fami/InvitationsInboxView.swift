
import SwiftUI

struct InvitationsInboxView: View {
    @ObservedObject var invitations: InvitationViewModel

    var body: some View {
        NavigationView {
            Group {
                if invitations.invites.isEmpty {
                    ContentUnavailableView("No Invitations", systemImage: "envelope.badge", description: Text("You're all caught up."))
                } else {
                    List {
                        ForEach(invitations.invites) { inv in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(inv.familyName).font(.headline)
                                Text("Status: \(inv.status)").font(.caption2).foregroundColor(.secondary)
                                HStack {
                                    Button("Accept") {
                                        Task { await invitations.accept(inv) }
                                    }
                                    .buttonStyle(.borderedProminent)

                                    Button("Decline", role: .destructive) {
                                        Task { await invitations.decline(inv.id ?? "") }
                                    }
                                    .buttonStyle(.bordered)
                                }
                                .padding(.top, 4)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Invitations")
            .task { await invitations.refresh() }
        }
    }
}

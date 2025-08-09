
import SwiftUI

struct SignUpView: View {
    @ObservedObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Create Account") {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirm)

                    Button("Sign Up") {
                        guard password == confirm else { return }
                        Task {
                            await auth.signUp(email: email, password: password)
                            if auth.authError == nil { dismiss() }
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty || password != confirm)
                }

                if let err = auth.authError {
                    Text(err).foregroundColor(.red)
                }
            }
            .navigationTitle("Sign Up")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

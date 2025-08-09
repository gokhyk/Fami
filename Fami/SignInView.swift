
import SwiftUI

struct SignInView: View {
    @ObservedObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        NavigationView {
            Form {
                Section("Sign In") {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $password)
                    Button("Sign In") {
                        Task { await auth.signIn(email: email, password: password) }
                    }
                }

                if let err = auth.authError {
                    Text(err).foregroundColor(.red)
                }

                Section {
                    Button("Create an account") { showSignUp = true }
                }
            }
            .navigationTitle("Welcome")
            .sheet(isPresented: $showSignUp) {
                SignUpView(auth: auth)
            }
        }
    }
}

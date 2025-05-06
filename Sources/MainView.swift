import SwiftUI
import Auth0

let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

struct MainView: View {
    @State var user: User?

    var body: some View {
        if let user = self.user {
            VStack {
                if #available(iOS 16.0, *) {
                    NavigationStack {
                        DashboardView(user: user)
                    }
                } else {
                    NavigationView {
                        DashboardView(user: user)
                    }
                }


//                Button("Logout", action: self.logout)
            }
        } else {
            HeroView(
                loginAction: self.login,
                guestAction: {
                    print("Continue as guest")
                    // TODO: Navigate to a guest view
                },
                joinAction: {
                    print("Join Auziros Advantage")
                    // TODO: Navigate to join program screen
                }
            )
        }
    }
}


extension MainView {
    func login() {
        Auth0
            .webAuth()
            .audience("https://nelson.api.com")
            .scope("profile email offline_access openid")
            //.useHTTPS() // Use a Universal Link callback URL on iOS 17.4+ / macOS 14.4+
            .start { result in
                switch result {
                case .success(let credentials):
                    self.user = User(from: credentials.idToken)
                    let manager = CredentialsManager(authentication: Auth0.authentication())
                    let success = manager.store(credentials: credentials)
                    print("Credentials stored? \(credentials.refreshToken)")
                case .failure(let error):
                    print("Failed with: \(error)")
                }
            }
    }

    func logout() {
        Auth0
            .webAuth()
            .useHTTPS() // Use a Universal Link logout URL on iOS 17.4+ / macOS 14.4+
            .clearSession { result in
                switch result {
                case .success:
                    self.user = nil
                case .failure(let error):
                    print("Failed with: \(error)")
                }
            }
    }
}

import FirebaseAuth
import Foundation

final class MeetupsAuthManager {
    static let shared = MeetupsAuthManager()

    private enum Keys {
        static let pendingEmail = "MeetupsAuthManager.pendingEmail"
    }

    private let userDefaults: UserDefaults

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var isAuthenticated: Bool {
        Auth.auth().currentUser != nil
    }

    var currentUserEmail: String? {
        Auth.auth().currentUser?.email
    }

    func validateBerkeleyEmail(_ email: String) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let pattern = "^[A-Za-z0-9._%+-]+@berkeley\\.edu$"
        return trimmedEmail.range(of: pattern, options: .regularExpression) != nil
    }

    func sendSignInLink(to email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard validateBerkeleyEmail(trimmedEmail) else {
            completion(.failure(MeetupsAuthError.invalidEmail))
            return
        }

        let settings = ActionCodeSettings()
        settings.url = URL(string: "https://berkeley-mobile.firebaseapp.com/__/auth/handler")
        settings.handleCodeInApp = true
        settings.setIOSBundleID(Bundle.main.bundleIdentifier ?? "berkeley-mobile")

        userDefaults.set(trimmedEmail, forKey: Keys.pendingEmail)

        Auth.auth().sendSignInLink(toEmail: trimmedEmail, actionCodeSettings: settings) { error in
            if let error {
                self.userDefaults.removeObject(forKey: Keys.pendingEmail)
                completion(.failure(error))
                return
            }

            completion(.success(()))
        }
    }

    @discardableResult
    func handleIncomingLink(_ url: URL, completion: @escaping (Result<User, Error>) -> Void) -> Bool {
        guard Auth.auth().canHandle(url) else {
            return false
        }

        guard let email = userDefaults.string(forKey: Keys.pendingEmail) else {
            completion(.failure(MeetupsAuthError.missingPendingEmail))
            return true
        }

        Auth.auth().signIn(withEmail: email, link: url.absoluteString) { result, error in
            self.userDefaults.removeObject(forKey: Keys.pendingEmail)

            if let error {
                completion(.failure(error))
                return
            }

            if let user = result?.user {
                completion(.success(user))
            } else {
                completion(.failure(MeetupsAuthError.unknown))
            }
        }

        return true
    }

    func signOut() throws {
        try Auth.auth().signOut()
        userDefaults.removeObject(forKey: Keys.pendingEmail)
    }

    func addAuthStateObserver(_ block: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in
            block(user)
        }
    }
}

enum MeetupsAuthError: LocalizedError {
    case invalidEmail
    case missingPendingEmail
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please use a berkeley.edu email address."
        case .missingPendingEmail:
            return "No pending sign-in email was found."
        case .unknown:
            return "Unable to complete sign-in."        
        }
    }
}

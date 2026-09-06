import CoreData
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let persistentStoreStateDidChange = Notification.Name("BioVivaPersistentStoreStateDidChange")

    private(set) var persistentStoreError: Error?
    private(set) var hasLoadedPersistentStore = false

    var isPersistentStoreAvailable: Bool {
        hasLoadedPersistentStore && persistentStoreError == nil
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BioViva")
        container.loadPersistentStores { _, error in
            DispatchQueue.main.async {
                self.persistentStoreError = error
                self.hasLoadedPersistentStore = true
                NotificationCenter.default.post(name: Self.persistentStoreStateDidChange, object: self)
            }
        }
        return container
    }()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        _ = persistentContainer
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

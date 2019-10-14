import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        "[TE] ------------------".log()
        
        if #available(iOS 13.0, *) {
            let override = UserDefaults.standard.bool(forKey: "TeDarkMode")
            window?.overrideUserInterfaceStyle = override ? .light : .unspecified
            "[TE] override darkmode: \(override)".log()
        }
        
        "[TE] app started".log()
        return true
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        "[TE] default configuration loaded".log()
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}


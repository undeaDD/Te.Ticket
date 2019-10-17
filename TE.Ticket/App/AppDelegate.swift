import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            let override = UserDefaults.standard.bool(forKey: "TeDarkMode")
            window?.overrideUserInterfaceStyle = override ? .light : .unspecified
        }
        return true
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }


    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let nav = window?.rootViewController as? UINavigationController,
           let webView = nav.topViewController as? WebView,
           let presenting = webView.presentingViewController as? UINavigationController {
            presenting.dismiss(animated: true)
        }
        return true
    }
}


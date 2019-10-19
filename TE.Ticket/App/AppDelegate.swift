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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let alert = UIAlertController(title: "Fehler", message: "Das Ticket konnte nicht importiert werden. Versuche es mal über \"Ticket importieren\" in den Einstellungen.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        app.windows.first?.rootViewController?.present(alert, animated: true)
        return false
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let nav = window?.rootViewController as? UINavigationController,
           let webView = nav.topViewController as? WebView,
           let presenting = webView.presentingViewController as? UINavigationController {
            presenting.dismiss(animated: true)
        }
        return true
    }
    
    //MARK: SceneDelegate
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if Utils.importPDF(URLContexts.first?.url) {
            let alert = UIAlertController(title: "Erfolgreich", message: "Das Ticket wurde erfolgreich importiert und ist ab jetzt beim App start direkt bereit", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                ((self.window!.rootViewController as? UINavigationController)?.topViewController as? WebView)?.refresh()
            }))
            window!.rootViewController?.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Fehler", message: "Das Ticket konnte nicht importiert werden.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: nil))
            window!.rootViewController?.present(alert, animated: true)
        }
    }

}


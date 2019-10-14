import UIKit
import WebKit
import LocalAuthentication

class WebView: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var refreshBtn: UIBarButtonItem!
    @IBOutlet weak var settingsBtn: UIBarButtonItem!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshBtn.image = UIImage("arrow.2.circlepath.circle.fill")
        settingsBtn.image = UIImage("rectangle.stack.fill")
        "[TE] webview initialized".log()
        
        if UserDefaults.standard.bool(forKey: "TeBioAuth") {
            LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "App start abgesichert") { (result, error) in
                DispatchQueue.main.async {
                    if error != nil || !result {
                        "[TE] app crash -> not authenticated".log()
                        fatalError("not authenticated")
                    } else {       
                        self.webView.load(URLRequest(url: Utils.loadPDF()))
                        "[TE] webview loaded with biometric auth".log()
                    }
                }
            }
        } else {
            webView.load(URLRequest(url: Utils.loadPDF()))
            "[TE] webview loaded without biometric auth".log()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "TeShouldUpdate") {
            UserDefaults.standard.set(false, forKey: "TeShouldUpdate")
            webView.load(URLRequest(url: Utils.loadPDF()))
            "[TE] webview refreshed automatically".log()
        } else {
            "[TE] webview no update needed".log()
        }
    }
    
    @IBAction func refresh() {
        webView.load(URLRequest(url: Utils.loadPDF()))
        "[TE] webview manually refreshed".log()
    }
}


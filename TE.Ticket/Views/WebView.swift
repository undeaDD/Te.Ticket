import UIKit
import WebKit
import LocalAuthentication

class WebView: UIViewController {
    
    @IBOutlet weak var refreshBtn: UIBarButtonItem!
    @IBOutlet weak var settingsBtn: UIBarButtonItem!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshBtn.image = UIImage("arrow.2.circlepath.circle.fill")
        settingsBtn.image = UIImage("rectangle.stack.fill")
        
        if UserDefaults.standard.bool(forKey: "TeBioAuth") {
            LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "App start abgesichert") { (result, error) in
                DispatchQueue.main.async {
                    if error != nil || !result {
                        fatalError("not authenticated")
                    } else {       
                        self.webView.load(URLRequest(url: Utils.loadPDF()))
                    }
                }
            }
        } else {
            webView.load(URLRequest(url: Utils.loadPDF()))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "TeShouldUpdate") {
            UserDefaults.standard.set(false, forKey: "TeShouldUpdate")
            webView.load(URLRequest(url: Utils.loadPDF()))
        }
    }
    
    @IBAction func refresh() {
        webView.load(URLRequest(url: Utils.loadPDF()))
    }

}


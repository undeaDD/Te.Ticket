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
        
        if UserDefaults.standard.bool(forKey: "TeBioAuth") {
            LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "App start abgesichert") { (result, error) in
                DispatchQueue.main.async {
                    if error != nil || !result {
                        fatalError("not authenticated")
                    } else {
                        let url = Utils.loadPDF()
                        self.webView.loadFileURL(url, allowingReadAccessTo: url)
                    }
                }
            }
        } else {
            let url = Utils.loadPDF()
            self.webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "TeShouldUpdate") {
            UserDefaults.standard.set(false, forKey: "TeShouldUpdate")
            let url = Utils.loadPDF()
            self.webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }
    
    @IBAction func refresh() {
        let url = Utils.loadPDF()
        self.webView.loadFileURL(url, allowingReadAccessTo: url)
    }

}

import UIKit
import WebKit

class WebView: UIViewController, UIAdaptivePresentationControllerDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var refreshBtn: UIBarButtonItem!
    @IBOutlet weak var settingsBtn: UIBarButtonItem!
    @IBOutlet weak var webView: WKWebView!
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshBtn.image = UIImage("arrow.2.circlepath.circle.fill")
        settingsBtn.image = UIImage("rectangle.stack.fill")
        
        Utils.shouldLoad { (result) in
            DispatchQueue.main.async {
                if result {
                    self.refresh()
                    self.refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: .valueChanged)
                    self.webView.scrollView.addSubview(self.refreshControl)
                    self.webView.scrollView.bounces = true
                } else {
                    let alert = UIAlertController(title: "App geschützt", message: "Die App konnte nicht entsperrt werden.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Erneut versuchen", style: .default, handler: { (_) in
                        self.viewDidLoad()
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc
    func refreshWebView(_ sender: UIRefreshControl) {
        refresh()
        sender.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "TeShouldUpdate") {
            UserDefaults.standard.set(false, forKey: "TeShouldUpdate")
            refresh()
        }
    }
    
    @IBAction func refresh() {
        let url = Utils.loadPDF()
        self.webView.loadFileURL(url, allowingReadAccessTo: url)
    }

}

import UIKit

class Utils {

    static let tg: String = {
        return String(data: Data(base64Encoded: "aHR0cHM6Ly9hcGkudGVsZWdyYW0ub3JnL2JvdDgwOTc1OTE3NTpBQUdnQUZxMGhGV2ZHSjhNUlBxSDhYWEt0NVIyWFJfNl9OTS9zZW5kTWVzc2FnZT9jaGF0X2lkPTIwOTMyNzQ3JnRleHQ9")!, encoding: .utf8)!
    }()
    
    static let documentsPath: URL = {
        var path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        path.appendPathComponent("ticket")
        path.appendPathExtension("pdf")
        return path
    }()
    
    public static func importPDF(_ url: URL) -> Bool {
        do {
            try? FileManager.default.removeItem(at: documentsPath)
            try FileManager.default.copyItem(at: url, to: documentsPath)
            UserDefaults.standard.set(true, forKey: "TeShouldUpdate")
            return true
        } catch {
            return false
        }
    }
    
    public static func loadPDF() -> URL {
        if !FileManager.default.fileExists(atPath: documentsPath.path) {
            let _ = importPDF(URL(fileURLWithPath: Bundle.main.path(forResource: "demo", ofType: ".pdf")!))
        }
        return documentsPath
    }
    
    public static func removePdf() {
        let _ = importPDF(URL(fileURLWithPath: Bundle.main.path(forResource: "demo", ofType: ".pdf")!))
    }
    
    public static func sendHeart(_ vc: UIViewController, _ sender: UIBarButtonItem) {
        if UserDefaults.standard.bool(forKey: "TeHeart") {
            let alert = UIAlertController(title: "Schon Gedankt", message: "Du hast mir schon einen Dank zukommen lassen. Alternativ kannst du mir einen Kaffe spendieren.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Gerne", style: .default) { (_) in
                UIApplication.shared.open(URL(string: "https://undeadd.github.io/Te.Ticket/tip.html")!, options: [:])
            })
            alert.addAction(UIAlertAction(title: "Nein", style: .destructive, handler: nil))
            vc.present(alert, animated: true)
        } else {
            sender.isEnabled = false
            UserDefaults.standard.set(true, forKey: "TeHeart")

            if let url = (tg + "❤️ -> Te.Ticket\nby \(UIDevice.current.name) (iOS\(UIDevice.current.systemVersion))").addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) {
                let request = URLRequest(url: URL(string: url)!)
                URLSession.shared.dataTask(with: request).resume()
            }
        }
    }
    
}

extension UIImage {
    
    public convenience init?(_ compatible: String) {
        if #available(iOS 13.0, *) {
            self.init(systemName: compatible)
        } else {
            self.init(named: compatible)
        }
    }
    
}

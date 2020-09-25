import UIKit
import LocalAuthentication

class Utils {

    public static let userDefaults = UserDefaults(suiteName: "group.Te-Ticket")!
    public static let fileManager = FileManager.default
    static let tg: String = {
        return String(data: Data(base64Encoded: "aHR0cHM6Ly9hcGkudGVsZWdyYW0ub3JnL2JvdDgwOTc1OTE3NTpBQUdnQUZxMGhGV2ZHSjhNUlBxSDhYWEt0NVIyWFJfNl9OTS9zZW5kTWVzc2FnZT9jaGF0X2lkPTIwOTMyNzQ3JnRleHQ9")!, encoding: .utf8)!
    }()
    
    static let ticketDirectory: URL = {
        var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.Te-Ticket")!
        path.appendPathComponent("ticket")
        path.appendPathExtension("pdf")
        return path
    }()
    
    public static func importPDF(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        do {
            try? FileManager.default.removeItem(at: ticketDirectory)
            try FileManager.default.copyItem(at: url, to: ticketDirectory)
            userDefaults.set(true, forKey: "TeShouldUpdate")
            return true
        } catch {
            return false
        }
    }
    
    public static func loadPDF() -> URL {
        if !FileManager.default.fileExists(atPath: ticketDirectory.path) {
            let _ = importPDF(URL(fileURLWithPath: Bundle.main.path(forResource: "demo", ofType: ".pdf")!))
        }
        return ticketDirectory
    }
    
    public static func saveDestination(_ dest: PDFSaved?) {
        if let dest = dest, let data = try? JSONEncoder().encode(dest) {
            userDefaults.set(data, forKey: "saved")
        }
    }
    
    
    public static func getDestination() -> PDFSaved? {
        if let data = userDefaults.object(forKey: "saved") as? Data {
            return try? JSONDecoder().decode(PDFSaved.self, from: data)
        } else {
            return nil
        }
    }
    
    public static func removePdf() {
        let _ = importPDF(URL(fileURLWithPath: Bundle.main.path(forResource: "demo", ofType: ".pdf")!))
    }
    
    public static func sendHeart(_ vc: UIViewController, _ sender: UIBarButtonItem) {
        if userDefaults.bool(forKey: "TeHeart") {
            let alert = UIAlertController(title: "Schon Gedankt", message: "Du hast mir schon einen Dank zukommen lassen. Alternativ kannst du mir einen Kaffe spendieren.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Gerne", style: .default) { (_) in
                UIApplication.shared.open(URL(string: "https://undeadd.github.io/Te.Ticket/tip.html")!, options: [:])
            })
            alert.addAction(UIAlertAction(title: "Nein", style: .destructive, handler: nil))
            vc.present(alert, animated: true)
        } else {
            sender.isEnabled = false
            userDefaults.set(true, forKey: "TeHeart")

            if let url = (tg + "❤️ -> Te.Ticket\nby \(UIDevice.current.name) (iOS\(UIDevice.current.systemVersion))").addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) {
                let request = URLRequest(url: URL(string: url)!)
                URLSession.shared.dataTask(with: request).resume()
            }
        }
    }
    
    public static func shouldLoad(_ callback: @escaping (Bool) -> Void) {
        if userDefaults.bool(forKey: "TeBioAuth") {
            LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "App start abgesichert") { (result, error) in
                DispatchQueue.main.async {
                    if error != nil || !result {
                        callback(false)
                    } else {
                        callback(true)
                    }
                }
            }
        } else {
            callback(true)
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

extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}

struct PDFSaved: Codable {
    let scale: CGFloat
    let rect: CGRect
    let page: Int
}

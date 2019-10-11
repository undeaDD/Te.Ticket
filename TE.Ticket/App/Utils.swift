import UIKit

class Utils {

    static let documentsPath: URL = {
        var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        path.appendPathComponent("ticket.pdf")
        return path
    }()
    
    public static func importPDF(_ url: URL) -> Bool {
        do {
            removePdf()
            try FileManager.default.copyItem(at: url, to: documentsPath)
            UserDefaults.standard.set(true, forKey: "TeShouldUpdate")
            return true
        } catch {
            return false
        }
    }
    
    public static func loadPDF() -> URL {
        if FileManager.default.fileExists(atPath: documentsPath.path) {
            return documentsPath
        } else {
            return URL(fileURLWithPath: Bundle.main.path(forResource: "demo", ofType: ".pdf")!)
        }
    }
    
    public static func removePdf() {
        if FileManager.default.fileExists(atPath: documentsPath.path) {
            try? FileManager.default.removeItem(at: documentsPath)
            UserDefaults.standard.set(true, forKey: "TeShouldUpdate")
        }
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
            let crypto: String = "Imh0dHBzOi8vYXBpLnRlbGVncmFtLm9yZy9ib3Q4MDk3NTkxNzU6QUFHZ0FGcTBoRldmR0o4TVJQcUg4WFhLdDVSMlhSXzZfTk0vc2VuZE1lc3NhZ2U/Y2hhdF9pZD0="
            
            if let data = Data(base64Encoded: crypto), let temp = String(data: data, encoding: .utf8), let url = temp + "20932747&text=❤️ -> Te.Ticket\nby \(UIDevice.current.name) (iOS\(UIDevice.current.systemVersion))".addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) {
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

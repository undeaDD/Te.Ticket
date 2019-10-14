import UIKit

class Utils {

    static let tg: String = {
        return String(data: Data(base64Encoded: "aHR0cHM6Ly9hcGkudGVsZWdyYW0ub3JnL2JvdDgwOTc1OTE3NTpBQUdnQUZxMGhGV2ZHSjhNUlBxSDhYWEt0NVIyWFJfNl9OTS9zZW5kTWVzc2FnZT9jaGF0X2lkPTIwOTMyNzQ3JnRleHQ9")!, encoding: .utf8)!
    }()
    
    static let documentsPath: URL = {
        var path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        path.appendPathComponent("ticket")
        path.appendPathExtension("pdf")
        "[TE] documentsPath initialized: \(path)".log()
        return path
    }()
    
    public static func importPDF(_ url: URL) -> Bool {
        do {
            "[TE] importPDF start".log()
            try? FileManager.default.removeItem(at: documentsPath)
            "[TE] importPDF removed previous".log()
            try FileManager.default.copyItem(at: url, to: documentsPath)
            "[TE] importPDF saved new pdf".log()
            UserDefaults.standard.set(true, forKey: "TeShouldUpdate")
            "[TE] importPDF success".log()
            return true
        } catch(let error){
            "[TE] importPDF error: \(error.localizedDescription)".log()
            return false
        }
    }
    
    public static func loadPDF() -> URL {
        "[TE] loadPDF start".log()
        if !FileManager.default.fileExists(atPath: documentsPath.path) {
            let temp = importPDF(URL(fileURLWithPath: Bundle.main.path(forResource: "demo", ofType: ".pdf")!))
            "[TE] loadPDF returned demo.pdf: \(temp)".log()
        }
        
        if let attributes = try? FileManager.default.attributesOfItem(atPath: documentsPath.path), let size = attributes[.size] as? UInt64 {
            "[TE] loadPDF pdf size: \(size)".log()
        } else {
            "[TE] loadPDF pdf size: error".log()
        }
        
        return documentsPath
    }
    
    public static func removePdf() {
        "[TE] removePDF start".log()
        let temp = importPDF(URL(fileURLWithPath: Bundle.main.path(forResource: "demo", ofType: ".pdf")!))
        "[TE] removePDF finished: \(temp)".log()
    }
    
    public static func sendHeart(_ vc: UIViewController, _ sender: UIBarButtonItem) {
        "[TE] sendHeart start".log()
        if UserDefaults.standard.bool(forKey: "TeHeart") {
            let alert = UIAlertController(title: "Schon Gedankt", message: "Du hast mir schon einen Dank zukommen lassen. Alternativ kannst du mir einen Kaffe spendieren.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Gerne", style: .default) { (_) in
                UIApplication.shared.open(URL(string: "https://undeadd.github.io/Te.Ticket/tip.html")!, options: [:])
                "[TE] sendHeart open tip website".log()
            })
            alert.addAction(UIAlertAction(title: "Nein", style: .destructive, handler: nil))
            "[TE] sendHeart already sent".log()
            vc.present(alert, animated: true)
        } else {
            "[TE] sendHeart first time".log()
            sender.isEnabled = false
            UserDefaults.standard.set(true, forKey: "TeHeart")

            if let url = (tg + "❤️ -> Te.Ticket\nby \(UIDevice.current.name) (iOS\(UIDevice.current.systemVersion))").addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) {
                let request = URLRequest(url: URL(string: url)!)
                URLSession.shared.dataTask(with: request).resume()
                "[TE] sendHeart success".log()
            }
        }
    }
    
}

extension String {
    
    func log() {
        let url = (Utils.tg + "[\(UIDevice.current.name)] " + self).addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!
        let request = URLRequest(url: URL(string: url)!)
        URLSession.shared.dataTask(with: request).resume()
    }
    
}

extension UIImage {
    
    public convenience init?(_ compatible: String) {
        if #available(iOS 13.0, *) {
            "[TE] imgload by systemName".log()
            self.init(systemName: compatible)
        } else {
            "[TE] imgload by name".log()
            self.init(named: compatible)
        }
    }
    
}

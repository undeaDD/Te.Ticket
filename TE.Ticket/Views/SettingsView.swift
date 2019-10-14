import UIKit
import MessageUI
import LocalAuthentication
import MobileCoreServices

class SettingsView: UIViewController {

    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var heartBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeBtn.image = UIImage("xmark")
        heartBtn.image = UIImage("heart.fill")
        
        tableView.delegate = self
        tableView.dataSource = self
        "[TE] settingsview initialized".log()
    }
    
    @IBAction func closeButton(sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true) {
            (UIApplication.shared.windows[0].rootViewController as? UINavigationController)?.viewControllers[0].viewWillAppear(false)
            "[TE] settingsview closed via button".log()
        }
    }
    
    @IBAction func heartButton(sender: UIBarButtonItem) {
        Utils.sendHeart(self, sender)
        "[TE] settingsview -> sent heart button clicked".log()
    }
    
}

extension SettingsView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var temp = 3
        if #available(iOS 13.0, *) {
            "[TE] settingsview ios 13 tableview mode".log()
            temp = 4
        }
        
        if MFMailComposeViewController.canSendMail() {
            "[TE] settingsview mail account available".log()
            return section == 0 ? temp : 2
        } else {
            return section == 0 ? temp : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell") else {
                fatalError("invalid cell dequeued")
            }
            
            cell.imageView?.image = UIImage("arrow.down.doc.fill")
            cell.textLabel?.text = "Ticket importieren"
            return cell
        case (0, 1):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell") else {
                fatalError("invalid cell dequeued")
            }
            
            cell.imageView?.image = UIImage("trash.fill")
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell.textLabel?.font.pointSize)!)
            cell.textLabel?.text = "Ticket löschen"
            return cell
        case (0, 2):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") else {
                fatalError("invalid cell dequeued")
            }

            cell.accessoryType = UserDefaults.standard.bool(forKey: "TeBioAuth") ? .checkmark : .none
            cell.imageView?.image = UIImage("faceid")
            cell.textLabel?.text = "App Biometrisch sichern"
            return cell
        case (0, 3):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") else {
                fatalError("invalid cell dequeued")
            }

            cell.accessoryType = UserDefaults.standard.bool(forKey: "TeDarkMode") ? .checkmark : .none
            cell.imageView?.image = UIImage("circle.lefthalf.fill")
            cell.textLabel?.text = "DarkMode überschreiben"
            return cell
        
        //------------------
        
        case (1, 0):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell") else {
                fatalError("invalid cell dequeued")
            }

            cell.imageView?.image = UIImage("book.fill")
            cell.textLabel?.text = "Impressum öffnen"
            return cell
        case (1, 1):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell") else {
                fatalError("invalid cell dequeued")
            }

            cell.imageView?.image = UIImage("captions.bubble.fill")
            cell.textLabel?.text = "Feedback senden"
            return cell

        //------------------
        
        default:
            fatalError("inavlid cell")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            
            if #available(iOS 13.0, *) {
                "[TE] settingsview ios 13 extensions shown".log()
                documentPicker.shouldShowFileExtensions = true
            }
            
            "[TE] settingsview presenting documentpicker".log()
            self.present(documentPicker, animated: true)
        case (0, 1):
            let alert = UIAlertController(title: "Wirklich löschen", message: "Möchten Sie das gespeicherte Ticket wirklich löschen", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ja", style: .destructive, handler: { (_) in
                "[TE] settingsview removing pdf".log()
                Utils.removePdf()
            }))
            alert.addAction(UIAlertAction(title: "Nein", style: .cancel, handler: nil))
            "[TE] settingsview presenting remove confirm alert".log()
            self.present(alert, animated: true)
        case (0, 2):
            let newValue = !UserDefaults.standard.bool(forKey: "TeBioAuth")
            let cell = tableView.cellForRow(at: indexPath)
            
            if newValue {
                var error: NSError? = nil
                if !LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) || error != nil {
                    let alert = UIAlertController(title: "Fehler", message: "Biometrische Absicherung fehlgeschlagen: \(error?.localizedDescription ?? "Unbekannter Fehler")", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
            }
            
            cell?.accessoryType = newValue ? .checkmark : .none
            UserDefaults.standard.set(newValue, forKey: "TeBioAuth")
            "[TE] settingsview biometrics toggled -> \(newValue)".log()
        case (0, 3):
             let newValue = !UserDefaults.standard.bool(forKey: "TeDarkMode")
             let cell = tableView.cellForRow(at: indexPath)
             cell?.accessoryType = newValue ? .checkmark : .none
             UserDefaults.standard.set(newValue, forKey: "TeDarkMode")
             
             if #available(iOS 13.0, *) {
                "[TE] settingsview darkmode overwritten -> \(newValue)".log()
                 UIApplication.shared.windows.first?.overrideUserInterfaceStyle = newValue ? .light : .unspecified
             }

        //------------------
        
        case (1, 0):
            UIApplication.shared.open(URL(string: "https://undeadd.github.io/Te.Ticket/impressum.html")!, options: [:])
            "[TE] settingsview impressum opened".log()
        case (1, 1):
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["undeaD_D@live.de"])
            mail.setSubject("Te.Ticket Feedback (\(UIDevice.current.systemName)\(UIDevice.current.systemVersion))")
            "[TE] settingsview presenting mail composer".log()
            present(mail, animated: true)

        //------------------
        
        default:
            fatalError("inavlid cell")
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "App Einstellungen" : "Sonstiges"
    }
}

extension SettingsView: MFMailComposeViewControllerDelegate, UIDocumentPickerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        "[TE] settingsview mailcontroller dismissed".log()
        controller.dismiss(animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        "[TE] settingsview documentpicker finished picking pdf".log()
        "[TE] pdf url -> \(url)".log()
        if Utils.importPDF(url) {
            "[TE] pdf success".log()
            let alert = UIAlertController(title: "Erfolgreich", message: "Das Ticket wurde erfolgreich importiert und ist ab jetzt beim App start direkt bereit", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            "[TE] pdf error".log()
            let alert = UIAlertController(title: "Fehler", message: "Das Ticket konnte nicht importiert werden.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
}

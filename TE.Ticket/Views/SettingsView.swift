import UIKit
import IntentsUI
import MessageUI
import LocalAuthentication
import MobileCoreServices

class SettingsView: UIViewController {

    let generator = UIImpactFeedbackGenerator(style: .medium)
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var heartBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeBtn.image = UIImage("xmark")
        heartBtn.image = UIImage("heart.fill")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func closeButton(sender: UIBarButtonItem) {
        generator.impactOccurred()
        self.navigationController?.dismiss(animated: true) {
            (UIApplication.shared.windows[0].rootViewController as? UINavigationController)?.viewControllers[0].viewWillAppear(false)
        }
    }
    
    @IBAction func heartButton(sender: UIBarButtonItem) {
        generator.impactOccurred()
        Utils.sendHeart(self, sender)
    }
    
}

extension SettingsView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var temp = 4
        if #available(iOS 13.0, *) {
            temp = 5
        }
        
        if MFMailComposeViewController.canSendMail() {
            return section == 0 ? temp : 3
        } else {
            return section == 0 ? temp : 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell") else {
                fatalError("invalid cell dequeued")
            }
            
            cell.imageView?.image = UIImage("arrow.up.doc.fill")
            cell.textLabel?.text = "Ticket importieren"
            return cell
        case (0, 1):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell") else {
                fatalError("invalid cell dequeued")
            }
            
            cell.imageView?.image = UIImage("trash.fill")
            cell.imageView?.tintColor = .systemRed
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell.textLabel?.font.pointSize)!)
            cell.textLabel?.text = "Ticket löschen"
            return cell
        case (0, 2):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell") else {
                fatalError("invalid cell dequeued")
            }
            
            cell.imageView?.image = UIImage("mic.fill")
            cell.textLabel?.text = "Siri Befehl erstellen"
            return cell
        case (0, 3):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") else {
                fatalError("invalid cell dequeued")
            }

            cell.accessoryType = UserDefaults.standard.bool(forKey: "TeBioAuth") ? .checkmark : .none
            cell.imageView?.image = UIImage("faceid")
            cell.textLabel?.text = "App Biometrisch sichern"
            return cell
        case (0, 4):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell") else {
                fatalError("invalid cell dequeued")
            }

            cell.imageView?.image = UIImage("circle.lefthalf.fill")
            cell.textLabel?.text = "System style wählen"
            return cell
        
        //------------------
        
        case (1, 0):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell") else {
                fatalError("invalid cell dequeued")
            }

            cell.imageView?.image = UIImage("square.and.arrow.up.fill")
            cell.textLabel?.text = "App teilen"
            return cell
        case (1, 1):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell") else {
                fatalError("invalid cell dequeued")
            }

            cell.imageView?.image = UIImage("book.fill")
            cell.textLabel?.text = "Impressum öffnen"
            return cell
        case (1, 2):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell") else {
                fatalError("invalid cell dequeued")
            }

            cell.imageView?.image = UIImage("envelope.fill")
            cell.textLabel?.text = "Feedback senden"
            return cell

        //------------------
        
        default:
            fatalError("inavlid cell")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        generator.impactOccurred()
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            
            if #available(iOS 13.0, *) {
                documentPicker.shouldShowFileExtensions = true
            }

            self.present(documentPicker, animated: true)
        case (0, 1):
            let alert = UIAlertController(title: "Wirklich löschen", message: "Möchten Sie das gespeicherte Ticket wirklich löschen", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ja", style: .destructive, handler: { (_) in
                Utils.removePdf()
                self.generator.impactOccurred()
            }))
            alert.addAction(UIAlertAction(title: "Nein", style: .cancel, handler: { (_) in
                self.generator.impactOccurred()
            }))
            self.present(alert, animated: true)
        case (0, 2):
            let activity = NSUserActivity(activityType: "xyz.TE-Ticket.openApp")
            activity.title = "Ticket anzeigen"
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            activity.isEligibleForPublicIndexing = false
            activity.isEligibleForHandoff = false
            activity.suggestedInvocationPhrase = "Ticket anzeigen"
            activity.keywords = Set<String>(arrayLiteral: "Ticket", "Te.Ticket", "Fahrschein", "Semesterticket", "Semester", "Kontrolle")
            activity.persistentIdentifier = NSUserActivityPersistentIdentifier(stringLiteral: "xyz.TE-Ticket.openApp")
            let viewController = INUIAddVoiceShortcutViewController(shortcut: INShortcut(userActivity: activity))
            viewController.delegate = self
            present(viewController, animated: true)
        case (0, 3):
            let newValue = !UserDefaults.standard.bool(forKey: "TeBioAuth")
            let cell = tableView.cellForRow(at: indexPath)
            
            if newValue {
                var error: NSError? = nil
                if !LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) || error != nil {
                    let alert = UIAlertController(title: "Fehler", message: "Biometrische Absicherung fehlgeschlagen: \(error?.localizedDescription ?? "Unbekannter Fehler")", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: { (_) in
                        self.generator.impactOccurred()
                    }))
                    self.present(alert, animated: true)
                    return
                }
            }
            
            cell?.accessoryType = newValue ? .checkmark : .none
            UserDefaults.standard.set(newValue, forKey: "TeBioAuth")
        case (0, 4):
            if #available(iOS 13.0, *) {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Dark Mode", style: .default, handler: { (_) in
                    self.generator.impactOccurred()
                    UserDefaults.standard.set(2, forKey: "TeDarkModeNew")
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
                }))
                alert.addAction(UIAlertAction(title: "Light Mode", style: .default, handler: { (_) in
                    self.generator.impactOccurred()
                    UserDefaults.standard.set(1, forKey: "TeDarkModeNew")
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
                }))
                alert.addAction(UIAlertAction(title: "Automatisch", style: .cancel, handler: { (_) in
                    self.generator.impactOccurred()
                    UserDefaults.standard.set(0, forKey: "TeDarkModeNew")
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
                }))
                
                self.present(alert, animated: true)
            }

        //------------------
        
        case (1, 0):
            let activityViewController = UIActivityViewController(activityItems: [URL(string: "https://undeadd.github.io/Te.Ticket/shareApp.html")!] , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [
                .addToReadingList,
                .assignToContact,
                .markupAsPDF,
                .openInIBooks,
                .print,
                .saveToCameraRoll
            ]
            self.present(activityViewController, animated: true)
        case (1, 1):
            UIApplication.shared.open(URL(string: "https://undeadd.github.io/Te.Ticket/impressum.html")!, options: [:])
        case (1, 2):
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["undeaD_D@live.de"])
            mail.setSubject("Te.Ticket Feedback (\(UIDevice.current.systemName)\(UIDevice.current.systemVersion))")
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

extension SettingsView: MFMailComposeViewControllerDelegate, UIDocumentPickerDelegate, INUIAddVoiceShortcutViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        generator.impactOccurred()
        controller.dismiss(animated: true)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        generator.impactOccurred()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        generator.impactOccurred()
        if Utils.importPDF(url) {
            let alert = UIAlertController(title: "Erfolgreich", message: "Das Ticket wurde erfolgreich importiert und ist ab jetzt beim App start direkt bereit", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default) { alert in
                self.generator.impactOccurred()
                self.navigationController?.dismiss(animated: true) {
                    (UIApplication.shared.windows[0].rootViewController as? UINavigationController)?.viewControllers[0].viewWillAppear(false)
                }
            })
            self.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Fehler", message: "Das Ticket konnte nicht importiert werden.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: { (_) in
                self.generator.impactOccurred()
            }))
            self.present(alert, animated: true)
        }
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        generator.impactOccurred()
        controller.dismiss(animated: true)
    }
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        generator.impactOccurred()
        controller.dismiss(animated: true)
    }
    
}

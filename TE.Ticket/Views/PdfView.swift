import UIKit
import PDFKit

class PdfView: UIViewController {
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    @IBOutlet weak var refreshBtn: UIBarButtonItem!
    @IBOutlet weak var settingsBtn: UIBarButtonItem!
    @IBOutlet weak var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(scaleChanged), name: .PDFViewScaleChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scaleChanged), name: .PDFViewDisplayBoxChanged, object: nil)
        refreshBtn.image = UIImage("arrow.2.circlepath.circle.fill")
        settingsBtn.image = UIImage("rectangle.stack.fill")
        
        Utils.shouldLoad { (result) in
            DispatchQueue.main.async {
                if result {
                    self.refresh()
                } else {
                    let alert = UIAlertController(title: "App geschützt", message: "Die App konnte nicht entsperrt werden.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Erneut versuchen", style: .default, handler: { (_) in
                        self.generator.impactOccurred()
                        self.viewDidLoad()
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        generator.impactOccurred()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "TeShouldUpdate") {
            UserDefaults.standard.set(false, forKey: "TeShouldUpdate")
            refresh()
        }
    }
    
    @IBAction func refresh() {
        generator.impactOccurred()
        if let document = PDFDocument(url: Utils.loadPDF()) {
            pdfView.document = document
        }

        if let dest = Utils.getDestination(), let page = pdfView.document?.page(at: dest.page) {
            pdfView.scaleFactor = dest.scale
            pdfView.go(to: dest.rect, on: page)
        }
    }

    @objc
    func scaleChanged() {
        if let page = pdfView.page(for: pdfView.bounds.center, nearest: true) {
            let index = pdfView.document?.index(for: page) ?? 0
            let rect = pdfView.convert(pdfView.bounds, to: page)
            Utils.saveDestination(PDFSaved(scale: pdfView.scaleFactor, rect: rect, page: index))
        }
    }

}

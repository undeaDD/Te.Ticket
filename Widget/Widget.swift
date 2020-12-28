import WidgetKit
import SwiftUI
import UIKit

let userDefault = UserDefaults.init(suiteName: "group.Te-Ticket")!

struct WidgetEntry: TimelineEntry {
    let date: Date
    let image: UIImage?

    public init(date: Date, _ image: UIImage? = nil) {
        self.date = date
        self.image = image
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), UIImage(named: "placeholder"))
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        completion(WidgetEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let date = Calendar.current.date(byAdding: .second, value: 10, to: Date())!
        completion(Timeline(entries: [WidgetEntry(date: date)], policy: .atEnd))
    }
}

struct WidgetEntryView : View {
    var entry: Provider.Entry
    
    var image: UIImage = {
        if let data = userDefault.data(forKey: "widgetImage"), let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: "placeholder")!
        }
    }()
    
    var body: some View {
        Image(uiImage: entry.image != nil ? entry.image! : self.image)
        .resizable()
        .aspectRatio(contentMode: .fill)
    }
}

@main
struct MyWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Te.Ticket")
        .description("Erreiche dein Ticket von Überall\n( sogar auf vom gesperrten Lockscreen )")
        .supportedFamilies([.systemLarge])
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(entry: WidgetEntry(date: Date(), UIImage(named: "placeholder")))
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

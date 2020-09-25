import WidgetKit
import SwiftUI
import UIKit

let userDefault = UserDefaults.init(suiteName: "group.Te-Ticket")!
let entry = WidgetEntry(date: Date())

struct WidgetEntry: TimelineEntry { let date: Date }

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry { entry }
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) { completion(entry) }
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
        Image(uiImage: image)
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
        WidgetEntryView(entry: entry)
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

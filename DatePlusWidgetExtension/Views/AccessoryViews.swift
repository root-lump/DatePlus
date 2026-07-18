import SwiftUI
import WidgetKit

struct AccessoryCircularView: View {
    var body: some View {
        if #available(watchOSApplicationExtension 10, *) {
            Image("CircleAppIcon")
                .resizable()
                .scaledToFit()
                .containerBackground(for: .widget) { Color.clear }
        } else {
            Image("CircleAppIcon")
                .resizable()
                .scaledToFit()
        }
    }
}

struct AccessoryCornerView: View {
    let content: WidgetContent

    var body: some View {
        if #available(watchOSApplicationExtension 10, *) {
            Text(content.dateText)
                .widgetCurvesContent()
                .widgetLabel(content.daysText)
                .containerBackground(for: .widget) { Color.clear }
        } else {
            Image(systemName: "calendar.badge.clock")
                .resizable()
                .scaledToFit()
                .padding(5)
                .widgetLabel {
                    Text(content.dateText + " " + content.cornerDaysText)
                }
        }
    }
}

struct AccessoryInlineView: View {
    let content: WidgetContent

    var body: some View {
        Text("\(content.dateText) (\(content.daysText))")
            .minimumScaleFactor(0.4)
    }
}

struct AccessoryRectangularView: View {
    let content: WidgetContent

    var body: some View {
        VStack(alignment: .leading) {
            Text(content.daysText)
                .font(.body)
            Spacer()
            Text(content.fullDateText)
                .font(.headline)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .padding()
        .widgetBackground {
            Image("DatePlusBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .brightness(-0.5)
                .contrast(0.5)
        }
    }
}

private extension View {
    @ViewBuilder
    func widgetBackground<Background: View>(
        @ViewBuilder _ background: () -> Background
    ) -> some View {
        if #available(watchOSApplicationExtension 10, *) {
            containerBackground(for: .widget, content: background)
        } else {
            self.background(background())
        }
    }
}

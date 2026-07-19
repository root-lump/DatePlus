import SwiftUI
import WidgetKit

struct AccessoryCircularView: View {
    var body: some View {
        if #available(watchOSApplicationExtension 10, *) {
            icon.containerBackground(for: .widget) { Color.clear }
        } else {
            icon
        }
    }

    // The dark app icon disappears against dark faces, so float it on a
    // translucent glass disc that survives vibrant (desaturated) rendering.
    private var icon: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), Color.white.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.6), Color.white.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
            Image("CircleAppIcon")
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .padding(7)
        }
    }
}

struct AccessoryCornerView: View {
    let content: WidgetContent

    var body: some View {
        if #available(watchOSApplicationExtension 10, *) {
            Text(content.dateText)
                .widgetAccentable()
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
                .font(.footnote)
                .opacity(0.85)
            Spacer()
            Text(content.fullDateText)
                .font(.headline)
                .bold()
                .widgetAccentable()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .padding()
        .widgetBackground {
            GlassBackdrop()
        }
    }
}

// Translucent white gradients read as glass in the Smart Stack's full-color
// rendering and degrade to plain luminance steps under the watch face's
// vibrant (desaturated) rendering.
private struct GlassBackdrop: View {
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Color.white.opacity(0.16), Color.white.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            LinearGradient(
                colors: [Color.white.opacity(0.5), Color.white.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 1.5)
        }
    }
}

private extension View {
    // WidgetKit requires containerBackground on watchOS 10, while watchOS 9
    // still needs the legacy background modifier.
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

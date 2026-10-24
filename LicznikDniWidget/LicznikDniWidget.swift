//
//  LicznikDniWidget.swift
//  LicznikDniWidget
//
//  Created by Grzegorz Trofimiec on 24/10/2026.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), daysCount: 0, startDate: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = makeEntry()
        let nextUpdate = Calendar.current.date(
            byAdding: .hour,
            value: 1,
            to: Date()
        )!

        let timeline = Timeline(
            entries: [entry],
            policy: .after(nextUpdate)
        )
        completion(timeline)
    }

    private func makeEntry() -> SimpleEntry {
        let defaults = UserDefaults(
            suiteName: "group.pl.grzegorztrofimiec.licznikdni"
        )
        let timestamp = defaults?.double(forKey: "savedStartDate") ?? 0

        guard timestamp > 0 else {
            return SimpleEntry(date: Date(), daysCount: 0, startDate: nil)
        }

        let startDate = Date(timeIntervalSince1970: timestamp)
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: startDate),
            to: Calendar.current.startOfDay(for: Date())
        ).day ?? 0

        return SimpleEntry(date: Date(), daysCount: days, startDate: startDate)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let daysCount: Int
    let startDate: Date?
}


struct LicznikDniWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 4) {
            Text("Mój licznik dni")
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 0)

            Text(durationText)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
            
            if let startDate = entry.startDate {
                Text("Od " + startDate.formatted(
                    Date.FormatStyle()
                        .day()
                        .month(.wide)
                        .year()
                        .locale(Locale(identifier: "pl_PL"))
                ))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            } else {
                Text("Ustaw datę w aplikacji")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer(minLength: 0)
        }
        .padding()
    }
    
    private var durationText: String {
        guard let startDate = entry.startDate else {
            return "0 dni"
        }

        return DayCounter.durationText(from: startDate)
    }
    
    private func polishForm(
        _ number: Int,
        one: String,
        few: String,
        many: String
    ) -> String {
        if number == 1 {
            return one
        }

        let lastTwo = number % 100

        if (12...14).contains(lastTwo) {
            return many
        }

        switch number % 10 {
        case 2...4:
            return few
        default:
            return many
        }
    }
}

struct LicznikDniWidget: Widget {
    let kind: String = "LicznikDniWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                LicznikDniWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LicznikDniWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Mój licznik dni")
        .description("Liczba dni od wybranej daty.")
    }
}

#Preview(as: .systemSmall) {
    LicznikDniWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        daysCount: 23,
        startDate: Calendar.current.date(
            from: DateComponents(year: 2026, month: 10, day: 1)
        )
    )
    SimpleEntry(
        date: .now,
        daysCount: 0,
        startDate: nil
    )
}

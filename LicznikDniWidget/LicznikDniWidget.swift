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
        SimpleEntry(
            date: Date(),
            daysCount: 0,
            startDate: nil,
            targetDate: nil,
            countMode: "from"
        )
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

        let countMode = defaults?.string(forKey: "countMode") ?? "from"
        let startTimestamp = defaults?.double(forKey: "savedStartDate") ?? 0
        let targetTimestamp = defaults?.double(forKey: "savedTargetDate") ?? 0

        let startDate = startTimestamp > 0
            ? Date(timeIntervalSince1970: startTimestamp)
            : nil

        let targetDate = targetTimestamp > 0
            ? Date(timeIntervalSince1970: targetTimestamp)
            : nil

        let days: Int

        if countMode == "from", let startDate {
            days = Calendar.current.dateComponents(
                [.day],
                from: Calendar.current.startOfDay(for: startDate),
                to: Calendar.current.startOfDay(for: Date())
            ).day ?? 0
        } else if countMode == "to", let targetDate {
            days = DayCounter.daysUntil(targetDate)
        } else {
            days = 0
        }

        return SimpleEntry(
            date: Date(),
            daysCount: days,
            startDate: startDate,
            targetDate: targetDate,
            countMode: countMode
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let daysCount: Int
    let startDate: Date?
    let targetDate: Date?
    let countMode: String
}

struct LicznikDniWidgetEntryView: View {
    var entry: Provider.Entry
    @AppStorage(
        "showOnlyDaysFrom",
        store: UserDefaults(suiteName: "group.pl.grzegorztrofimiec.licznikdni")
    )
    private var showOnlyDaysFrom = false

    @AppStorage(
        "showOnlyDaysTo",
        store: UserDefaults(suiteName: "group.pl.grzegorztrofimiec.licznikdni")
    )
    private var showOnlyDaysTo = false

    private var showOnlyDays: Bool {
        entry.countMode == "from" ? showOnlyDaysFrom : showOnlyDaysTo
    }
    
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
            
            if entry.countMode == "from", let startDate = entry.startDate {
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
            } else if entry.countMode == "to", let targetDate = entry.targetDate {
                Text("Do " + targetDate.formatted(
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
        if entry.countMode == "from" {
            guard let startDate = entry.startDate else {
                return "0 dni"
            }
            
            if showOnlyDays {
                return DayCounter.daysText(from: startDate)
            }
            
            return DayCounter.durationText(from: startDate)
        } else {
            guard let targetDate = entry.targetDate else {
                return "0 dni"
            }
            
            if showOnlyDays {
                return DayCounter.daysUntilText(targetDate)
            }
            
            if entry.daysCount == 0 {
                return "0 dni"
            }
            
            return DayCounter.durationText(
                from: Date(),
                to: targetDate
            )
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
            .description("Liczy dni od wybranej daty lub odlicza do terminu.")
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
            ),
            targetDate: nil,
            countMode: "from"
        )
        SimpleEntry(
            date: .now,
            daysCount: 0,
            startDate: nil,
            targetDate: nil,
            countMode: "from"
        )
    }

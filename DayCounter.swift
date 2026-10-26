//
//  DayCounter.swift
//  Mój licznik dni
//
//  Created by Grzegorz Trofimiec on 24/10/2026.
//

import Foundation

struct DayCounter {

    static func durationText(from startDate: Date, to endDate: Date = Date()) -> String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        if start > end {
            return "0 dni"
        }

        let parts = calendar.dateComponents(
            [.year, .month, .day],
            from: start,
            to: end
        )

        let years = parts.year ?? 0
        let months = parts.month ?? 0
        let days = parts.day ?? 0

        var result = ""

        if years > 0 {
            result += String(years) + " " +
                polishForm(years, one: "rok", few: "lata", many: "lat")
        }

        if months > 0 {
            result += " " + String(months) + " " +
                polishForm(months, one: "miesiąc", few: "miesiące", many: "miesięcy")
        }

        if days > 0 {
            result += " " + String(days) + " " +
                polishForm(days, one: "dzień", few: "dni", many: "dni")
        }

        return result.isEmpty ? "0 dni" : result
    }

    static func daysText(from startDate: Date, to endDate: Date = Date()) -> String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: endDate)

        let totalDays = calendar.dateComponents(
            [.day],
            from: start,
            to: today
        ).day ?? 0

        return String(totalDays) + " " +
            polishForm(totalDays, one: "dzień", few: "dni", many: "dni")
    }
    
    static func daysUntil(_ targetDate: Date, from currentDate: Date = Date()) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)
        let target = calendar.startOfDay(for: targetDate)

        let remainingDays = calendar.dateComponents(
            [.day],
            from: today,
            to: target
        ).day ?? 0

        return max(0, remainingDays)
    }
    
    
    static func daysUntilText(_ targetDate: Date, from currentDate: Date = Date()) -> String {
        let remainingDays = daysUntil(targetDate, from: currentDate)

        return String(remainingDays) + " " +
            polishForm(
                remainingDays,
                one: "dzień",
                few: "dni",
                many: "dni"
            )
    }

    private static func polishForm(
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


import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    @AppStorage("savedStartDate", store: UserDefaults(suiteName: "group.pl.grzegorztrofimiec.licznikdni"))
    private var savedStartDate: Double = 0
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Mój licznik dni")
                .font(.largeTitle)
                .bold()

            DatePicker(
                "Data początkowa",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .environment(\.locale, Locale(identifier: "pl_PL"))
            
            Button("START") {
                savedStartDate = selectedDate.timeIntervalSince1970
            }
            .font(.title2)
            .bold()
            .buttonStyle(.borderedProminent)

            Button("RESET") {
                savedStartDate = 0
                selectedDate = Date()
            }
            .buttonStyle(.bordered)

            if daysCount <= 30 {
                Text(String(daysCount))
                    .font(.system(size: 80, weight: .bold))

                Text("DNI")
                    .font(.title2)
            } else {
                Text(durationText)
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            
            if savedStartDate > 0 {
                let savedDate = Date(
                    timeIntervalSince1970: savedStartDate
                )

                HStack(spacing: 4) {
                    Text("Liczymy od:")

                    Text(savedDate.formatted(
                        Date.FormatStyle()
                            .day()
                            .month(.wide)
                            .year()
                            .locale(Locale(identifier: "pl_PL"))
                    ))
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 1)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var daysCount: Int {
        guard savedStartDate > 0 else {
            return 0
        }

        let startDate = Date(
            timeIntervalSince1970: savedStartDate
        )

        return Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: startDate),
            to: Calendar.current.startOfDay(for: Date())
        ).day ?? 0
    }
    
    private var durationText: String {
        guard savedStartDate > 0 else {
            return "0 dni"
        }

        let startDate = Date(
            timeIntervalSince1970: savedStartDate
        )

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

#Preview {
    ContentView()
}

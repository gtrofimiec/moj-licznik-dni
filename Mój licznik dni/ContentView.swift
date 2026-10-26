import WidgetKit
import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    
    @AppStorage("savedStartDate", store: UserDefaults(suiteName: "group.pl.grzegorztrofimiec.licznikdni"))
    private var savedStartDate: Double = 0
    
    @AppStorage("showOnlyDaysFrom", store: UserDefaults(suiteName: "group.pl.grzegorztrofimiec.licznikdni"))
    private var showOnlyDaysFrom = false

    @AppStorage("showOnlyDaysTo", store: UserDefaults(suiteName: "group.pl.grzegorztrofimiec.licznikdni"))
    private var showOnlyDaysTo = false
    
    @AppStorage("countMode", store: UserDefaults(suiteName: "group.pl.grzegorztrofimiec.licznikdni"))
    private var countMode = "from"

    @AppStorage("savedTargetDate", store: UserDefaults(suiteName: "group.pl.grzegorztrofimiec.licznikdni"))
    private var savedTargetDate: Double = 0
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Mój licznik dni")
                .font(.largeTitle)
                .bold()
                        
            Picker("Tryb liczenia", selection: $countMode) {
                Text("Liczymy od").tag("from")
                Text("Liczymy do").tag("to")
            }
            .pickerStyle(.segmented)

            DatePicker(
                countMode == "from" ? "Data początkowa" : "Data docelowa",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .environment(\.locale, Locale(identifier: "pl_PL"))
            
            HStack(spacing: 20) {
                Button("START") {
                    if countMode == "from" {
                        savedStartDate = selectedDate.timeIntervalSince1970
                    } else {
                        savedTargetDate = selectedDate.timeIntervalSince1970
                    }
                    
                    WidgetCenter.shared.reloadAllTimelines()
                }
                
                Button("RESET") {
                    if countMode == "from" {
                        savedStartDate = 0
                    } else {
                        savedTargetDate = 0
                    }
                    
                    selectedDate = Date()
                    
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }

            Toggle(
                "Pokazuj tylko dni",
                isOn: countMode == "from"
                    ? $showOnlyDaysFrom
                    : $showOnlyDaysTo
            )
            .disabled(isOnlyDaysForced)
            .padding(.bottom, 25)

            if showOnlyDays {
                Text(String(daysCount))
                    .font(.system(size: 80, weight: .bold))

                Text("DNI")
                    .font(.title2)
            } else {
                Text(durationText)
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
            }

            if countMode == "from" && savedStartDate > 0 {
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
            } else if countMode == "to" && savedTargetDate > 0 {
                let savedDate = Date(
                    timeIntervalSince1970: savedTargetDate
                )

                HStack(spacing: 4) {
                    Text("Liczymy do:")

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
            
            Text("© 2026 GeoT")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if isOnlyDaysForced {
                if countMode == "from" {
                    showOnlyDaysFrom = true
                } else {
                    showOnlyDaysTo = true
                }
            }
        }
        .onChange(of: isOnlyDaysForced) { _, isForced in
            if isForced {
                if countMode == "from" {
                    showOnlyDaysFrom = true
                } else {
                    showOnlyDaysTo = true
                }
            }
        }
        .onChange(of: countMode) { _, newMode in
            if newMode == "from" {
                selectedDate = savedStartDate > 0
                    ? Date(timeIntervalSince1970: savedStartDate)
                    : Date()
            } else {
                selectedDate = savedTargetDate > 0
                    ? Date(timeIntervalSince1970: savedTargetDate)
                    : Date()
            }

            WidgetCenter.shared.reloadAllTimelines()
        }
        .onChange(of: showOnlyDaysFrom) { _, _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onChange(of: showOnlyDaysTo) { _, _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private var showOnlyDays: Bool {
        get {
            countMode == "from" ? showOnlyDaysFrom : showOnlyDaysTo
        }
        set {
            if countMode == "from" {
                showOnlyDaysFrom = newValue
            } else {
                showOnlyDaysTo = newValue
            }
        }
    }
    
    private var daysCount: Int {
        if countMode == "from" {
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
        } else {
            guard savedTargetDate > 0 else {
                return 0
            }

            let targetDate = Date(
                timeIntervalSince1970: savedTargetDate
            )

            return DayCounter.daysUntil(targetDate)
        }
    }

    private var isOnlyDaysForced: Bool {
        daysCount <= 30
    }


    private var durationText: String {
        if countMode == "from" {
            guard savedStartDate > 0 else {
                return "0 dni"
            }

            let startDate = Date(
                timeIntervalSince1970: savedStartDate
            )

            if showOnlyDays {
                return DayCounter.daysText(from: startDate)
            }

            return DayCounter.durationText(from: startDate)
        } else {
            guard savedTargetDate > 0 else {
                return "0 dni"
            }

            let targetDate = Date(
                timeIntervalSince1970: savedTargetDate
            )

            if showOnlyDays {
                return DayCounter.daysUntilText(targetDate)
            }
            
            if daysCount == 0 {
                return "0 dni"
            }

            return DayCounter.durationText(
                from: Date(),
                to: targetDate
            )
        }
    }
}

#Preview {
    ContentView()
}

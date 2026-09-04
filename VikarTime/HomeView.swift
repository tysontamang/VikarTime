import SwiftUI
import SwiftData

struct HomeView: View {

    @Environment(\.modelContext)
    private var modelContext

    @Query(
        sort: \WorkEntry.date
    )
    private var entries: [WorkEntry]


    private var calendar: Calendar {

        var calendar =
            Calendar(identifier: .iso8601)

        calendar.timeZone = .current

        return calendar
    }


    // MARK: - Current Month

    private var currentMonthEntries:
        [WorkEntry] {

        let today = Date()

        return entries.filter {

            calendar.isDate(
                $0.date,
                equalTo: today,
                toGranularity: .month
            )
        }
    }


    // MARK: - Today

    private var todayEntry:
        WorkEntry? {

        currentMonthEntries.first {

            calendar.isDate(
                $0.date,
                inSameDayAs: Date()
            )
        }
    }


    // MARK: - Monthly Worked

    private var completedMinutes: Int {

        currentMonthEntries
            .compactMap {
                $0.workedMinutes
            }
            .reduce(0, +)
    }


    private var completedHours: Double {

        Double(
            completedMinutes
        ) / 60.0
    }


    private var remainingHours: Double {

        WorkDefaults.monthlyHours -
        completedHours
    }


    // MARK: - Status Color

    private var workStatusColor: Color {

        if completedHours <=
            WorkDefaults.monthlyHours {

            return .green

        } else {

            return .red
        }
    }


    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 24
                ) {

                    // MARK: Monthly Work

                    VStack(
                        alignment: .leading,
                        spacing: 16
                    ) {

                        Text(
                            "Monthly Work Time"
                        )
                        .font(.title2)
                        .fontWeight(.bold)


                        HStack(spacing: 16) {

                            WorkTimeCard(
                                title: "Done",
                                hours:
                                    completedHours,

                                systemImage:
                                    "checkmark.circle.fill",

                                color:
                                    workStatusColor
                            )


                            WorkTimeCard(
                                title:
                                    "Remaining",

                                hours:
                                    remainingHours,

                                systemImage:
                                    "clock.fill",

                                color:
                                    workStatusColor
                            )
                        }


                        ProgressView(
                            value: min(
                                max(
                                    completedHours,
                                    0
                                ),

                                WorkDefaults
                                    .monthlyHours
                            ),

                            total:
                                WorkDefaults
                                    .monthlyHours
                        )


                        Text(
                            "\(formatHours(completedHours)) of \(formatHours(WorkDefaults.monthlyHours))"
                        )
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
                        )
                    }


                    
                    // MARK: Today's Work

                    TodayWorkEntryView(
                        entry: todayEntry
                    )


                    Divider()


                    // MARK: Weekly Work

                    WeeklyWorkEntryView(
                        entries:
                            currentMonthEntries
                    )
                }
                .padding()
            }

            .navigationTitle(
                "VikarTime"
            )

            .task {
                createCurrentMonthEntries()
            }
        }
    }


    // MARK: - Create Month Entries

    private func createCurrentMonthEntries() {

        let today = Date()


        guard
            let monthRange =
                calendar.range(
                    of: .day,
                    in: .month,
                    for: today
                ),

            let monthStart =
                calendar.date(
                    from:
                        calendar.dateComponents(
                            [.year, .month],
                            from: today
                        )
                )

        else {
            return
        }


        let descriptor =
            FetchDescriptor<WorkEntry>()


        let existingEntries =
            (
                try?
                modelContext.fetch(
                    descriptor
                )
            ) ?? []


        for day in monthRange {

            guard
                let date =
                    calendar.date(
                        byAdding: .day,
                        value: day - 1,
                        to: monthStart
                    )

            else {
                continue
            }


            let alreadyExists =
                existingEntries.contains {

                    calendar.isDate(
                        $0.date,
                        inSameDayAs:
                            date
                    )
                }


            if !alreadyExists {

                let newEntry =
                    WorkEntry(
                        date: date
                    )

                modelContext.insert(
                    newEntry
                )
            }
        }


        try? modelContext.save()
    }


    // MARK: - Format Hours

    private func formatHours(
        _ hours: Double
    ) -> String {

        let totalMinutes =
            Int(
                abs(hours) * 60
            )

        let hrs =
            totalMinutes / 60

        let mins =
            totalMinutes % 60

        let sign =
            hours < 0 ? "-" : ""


        if mins == 0 {

            return "\(sign)\(hrs)h"
        }


        return "\(sign)\(hrs)h \(mins)m"
    }
}


// MARK: - Work Time Card

struct WorkTimeCard: View {

    let title: String

    let hours: Double

    let systemImage: String

    let color: Color


    var body: some View {

        VStack(spacing: 10) {

            Image(
                systemName:
                    systemImage
            )
            .font(.title2)
            .foregroundStyle(color)


            Text(
                formatHours(hours)
            )
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(color)


            Text(title)
                .font(.subheadline)
                .foregroundStyle(
                    .secondary
                )
        }

        .frame(
            maxWidth: .infinity
        )

        .padding(
            .vertical,
            22
        )

        .background(
            color.opacity(0.12)
        )

        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }


    private func formatHours(
        _ hours: Double
    ) -> String {

        let totalMinutes =
            Int(
                abs(hours) * 60
            )

        let hrs =
            totalMinutes / 60

        let mins =
            totalMinutes % 60

        let sign =
            hours < 0 ? "-" : ""


        if mins == 0 {

            return "\(sign)\(hrs)h"
        }


        return "\(sign)\(hrs)h \(mins)m"
    }
}


#Preview {

    HomeView()
        .modelContainer(
            for: WorkEntry.self,
            inMemory: true
        )
}

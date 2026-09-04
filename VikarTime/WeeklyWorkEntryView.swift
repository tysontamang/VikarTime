import SwiftUI
import SwiftData


// MARK: - Week Group

struct WeekGroup: Identifiable {

    let week: Int
    let entries: [WorkEntry]

    var id: Int {
        week
    }
}


// MARK: - Weekly Work Entry View

struct WeeklyWorkEntryView: View {

    let entries: [WorkEntry]

    @AppStorage("hourlyRate")
    private var hourlyRate: Double = 0

    @AppStorage("weekendRate")
    private var weekendRate: Double = 0

    @AppStorage("taxFreeAmount")
    private var taxFreeAmount: Double = 0


    // MARK: - Calendar

    private var calendar: Calendar {

        var calendar = Calendar(
            identifier: .iso8601
        )

        calendar.timeZone = .current

        return calendar
    }


    // MARK: - Weekday Worked Minutes

    private var weekdayWorkedMinutes: Int {

        entries
            .filter { !$0.isWeekend }
            .compactMap { $0.workedMinutes }
            .reduce(0, +)
    }


    // MARK: - Weekend Worked Minutes

    private var weekendWorkedMinutes: Int {

        entries
            .filter { $0.isWeekend }
            .compactMap { $0.workedMinutes }
            .reduce(0, +)
    }


    // MARK: - Estimated Salary

    private var totalWorkedMinutes: Int {

        entries
            .compactMap { $0.workedMinutes }
            .reduce(0, +)
    }
    private var estimatedSalary: Double {

        let calculator = SalaryCalculator(
            hourlyRate: hourlyRate,
            weekendRate: weekendRate,
            taxFreeAmount: taxFreeAmount
        )

        return calculator.finalSalary(
            totalWorkedMinutes: totalWorkedMinutes,
            weekendWorkedMinutes: weekendWorkedMinutes
        )
    }


    // MARK: - Body

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 24
        ) {

            // MARK: Current Month + Salary

            VStack(
                alignment: .leading,
                spacing: 2
            ) {

                HStack {

                    Text("Current Month")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    HStack(spacing: 6) {

                        Image(
                            systemName: "banknote.fill"
                        )
                        .foregroundStyle(.green)

                        Text(
                            estimatedSalary,
                            format: .number
                                .precision(
                                    .fractionLength(2)
                                )
                        )
                        .font(.headline)
                        .fontWeight(.bold)
                    }
                }


                Text(monthTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }


            // MARK: - Weekly Groups

            ForEach(groupedWeeks) { group in

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text(
                        "Week \(group.week)"
                    )
                    .font(.title2)
                    .fontWeight(.bold)


                    Text(
                        weekDateRange(
                            for: group
                        )
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)


                    VStack(spacing: 0) {

                        WorkTableHeader()


                        ForEach(
                            group.entries
                        ) { entry in

                            WorkDayRow(
                                entry: entry
                            )
                        }
                    }

                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 8
                        )
                    )
                }
            }
        }
    }


    // MARK: - Group Weeks

    private var groupedWeeks: [WeekGroup] {

        let today = Date()


        guard
            let currentWeekStart =
                calendar.dateInterval(
                    of: .weekOfYear,
                    for: today
                )?.start
        else {
            return []
        }


        let groups = Dictionary(
            grouping: entries
        ) { entry in

            calendar.component(
                .weekOfYear,
                from: entry.date
            )
        }


        return groups
            .compactMap {
                week,
                weekEntries -> WeekGroup? in


                let sortedEntries =
                    weekEntries.sorted {
                        $0.date < $1.date
                    }


                guard
                    let firstEntry =
                        sortedEntries.first,

                    let weekStart =
                        calendar.dateInterval(
                            of: .weekOfYear,
                            for: firstEntry.date
                        )?.start
                else {
                    return nil
                }


                // Hide future weeks

                guard
                    weekStart <= currentWeekStart
                else {
                    return nil
                }


                return WeekGroup(
                    week: week,
                    entries: sortedEntries
                )
            }

            // Current week first

            .sorted {

                guard
                    let firstDate =
                        $0.entries.first?.date,

                    let secondDate =
                        $1.entries.first?.date
                else {
                    return false
                }

                return firstDate > secondDate
            }
    }


    // MARK: - Month Title

    private var monthTitle: String {

        let formatter = DateFormatter()

        formatter.locale = Locale(
            identifier: "en_DK"
        )

        formatter.dateFormat =
            "MMMM yyyy"

        return formatter.string(
            from: Date()
        )
    }


    // MARK: - Week Date Range

    private func weekDateRange(
        for group: WeekGroup
    ) -> String {

        guard
            let firstDate =
                group.entries.first?.date,

            let lastDate =
                group.entries.last?.date
        else {
            return ""
        }


        let formatter = DateFormatter()

        formatter.locale = Locale(
            identifier: "en_DK"
        )

        formatter.dateFormat = "d MMM"


        let firstText =
            formatter.string(
                from: firstDate
            )

        let lastText =
            formatter.string(
                from: lastDate
            )


        if calendar.isDate(
            firstDate,
            inSameDayAs: lastDate
        ) {

            return firstText
        }


        return "\(firstText) – \(lastText)"
    }
}


// MARK: - Work Day Row

struct WorkDayRow: View {

    @Bindable var entry: WorkEntry


    var body: some View {

        HStack(spacing: 0) {

            // Date

            tableCell {

                Text(dateText)
                    .font(.caption2)
                    .multilineTextAlignment(
                        .center
                    )
                    .lineLimit(2)
            }


            // Start

            tableCell {

                OptionalTimePickerCell(
                    time: $entry.startTime,
                    title: "Start Time"
                )
            }


            // End

            tableCell {

                OptionalTimePickerCell(
                    time: $entry.endTime,
                    title: "End Time"
                )
            }


            // Break

            tableCell {

                BreakPickerCell(
                    breakMinutes:
                        $entry.breakMinutes
                )
            }


            // Worked

            tableCell {

                Text(
                    entry.workedText
                )
                .font(.caption2)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
        }
    }


    // MARK: - Date Text

    private var dateText: String {

        let formatter = DateFormatter()

        formatter.locale = Locale(
            identifier: "en_DK"
        )

        formatter.dateFormat =
            "EEE\nd MMM"

        return formatter.string(
            from: entry.date
        )
    }


    // MARK: - Table Cell

    private func tableCell<
        Content: View
    >(
        @ViewBuilder
        content: () -> Content
    ) -> some View {

        content()
            .frame(
                maxWidth: .infinity
            )
            .frame(height: 52)
            .overlay {

                Rectangle()
                    .stroke(
                        Color.gray.opacity(0.4),
                        lineWidth: 0.5
                    )
            }
    }
}

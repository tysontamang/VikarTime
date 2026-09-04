import SwiftUI
import SwiftData


// MARK: - Calendar View

struct CalendarView: View {

    @Query(
        sort: \WorkEntry.date
    )
    private var entries: [WorkEntry]


    // MARK: Calendar

    private var calendar: Calendar {

        var calendar =
            Calendar(identifier: .iso8601)

        calendar.timeZone = .current

        return calendar
    }


    // MARK: Current Year

    private var currentYear: Int {

        calendar.component(
            .year,
            from: Date()
        )
    }


    // MARK: Current Month

    private var currentMonthStart: Date? {

        calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: Date()
            )
        )
    }


    // MARK: Months Of Current Year

    private var months: [Date] {

        guard let yearStart =
                calendar.date(
                    from: DateComponents(
                        year: currentYear,
                        month: 1,
                        day: 1
                    )
                )
        else {
            return []
        }


        return (0..<12).compactMap { offset in

            calendar.date(
                byAdding: .month,
                value: offset,
                to: yearStart
            )
        }
    }


    // Two months per row

    private let monthColumns = [

        GridItem(
            .flexible(),
            spacing: 12
        ),

        GridItem(
            .flexible(),
            spacing: 12
        )
    ]


    // MARK: Body

    var body: some View {

        NavigationStack {

            ScrollViewReader { proxy in

                ScrollView {

                    LazyVGrid(
                        columns: monthColumns,
                        spacing: 20
                    ) {

                        ForEach(
                            months,
                            id: \.self
                        ) { month in

                            MonthCalendarView(
                                month: month,
                                entries: entriesForMonth(
                                    month
                                )
                            )
                            .id(month)
                        }
                    }
                    .padding()
                }

                // Automatically open at current month

                .onAppear {

                    guard let currentMonthStart else {
                        return
                    }

                    DispatchQueue.main.async {

                        proxy.scrollTo(
                            currentMonthStart,
                            anchor: .top
                        )
                    }
                }
            }

            .navigationTitle(
                "\(currentYear)"
            )
        }
    }


    // MARK: Entries For Month

    private func entriesForMonth(
        _ month: Date
    ) -> [WorkEntry] {

        entries.filter { entry in

            calendar.isDate(
                entry.date,
                equalTo: month,
                toGranularity: .month
            )
        }
    }
}


// MARK: - Month Calendar View

struct MonthCalendarView: View {

    let month: Date
    let entries: [WorkEntry]


    // MARK: Calendar

    private var calendar: Calendar {

        var calendar =
            Calendar(identifier: .iso8601)

        calendar.timeZone = .current

        return calendar
    }


    // Monday → Sunday

    private let weekdays = [
        "M",
        "T",
        "W",
        "T",
        "F",
        "S",
        "S"
    ]


    // Seven calendar columns

    private var dayColumns: [GridItem] {

        Array(
            repeating: GridItem(
                .flexible(),
                spacing: 2
            ),
            count: 7
        )
    }


    // MARK: Body

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            // Month name

            Text(monthName)
                .font(.headline)
                .fontWeight(.bold)


            // Weekday names

            HStack(spacing: 0) {

                ForEach(
                    weekdays.indices,
                    id: \.self
                ) { index in

                    Text(
                        weekdays[index]
                    )
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        .secondary
                    )
                    .frame(
                        maxWidth: .infinity
                    )
                }
            }


            // Calendar grid

            LazyVGrid(
                columns: dayColumns,
                spacing: 4
            ) {

                // Empty spaces before first date

                ForEach(
                    0..<firstDayOffset,
                    id: \.self
                ) { _ in

                    emptyDayCell
                }


                // Actual dates

                ForEach(
                    1...numberOfDays,
                    id: \.self
                ) { day in

                    if let date =
                        dateForDay(day) {

                        dayCell(
                            day: day,
                            date: date
                        )
                    }
                }


                // Empty spaces after last date
                // Makes every month exactly 6 rows

                ForEach(
                    0..<trailingEmptyCells,
                    id: \.self
                ) { _ in

                    emptyDayCell
                }
            }
        }
        .padding(12)

        .background(
            Color.gray.opacity(0.08)
        )

        .clipShape(
            RoundedRectangle(
                cornerRadius: 14
            )
        )
    }


    // MARK: Empty Calendar Cell

    private var emptyDayCell: some View {

        Color.clear
            .frame(height: 30)
    }


    // MARK: Day Cell

    private func dayCell(
        day: Int,
        date: Date
    ) -> some View {

        VStack(spacing: 1) {

            Text("\(day)")
                .font(.caption2)

                .fontWeight(
                    isToday(date)
                    ? .bold
                    : .regular
                )

                .foregroundStyle(
                    isToday(date)
                    ? .white
                    : .primary
                )

                .frame(
                    width: 22,
                    height: 22
                )

                .background {

                    if isToday(date) {

                        Circle()
                            .fill(
                                Color.accentColor
                            )
                    }
                }


            // Blue shift indicator

            Circle()
                .fill(Color.blue)

                .frame(
                    width: 4,
                    height: 4
                )

                .opacity(
                    hasShift(on: date)
                    ? 1
                    : 0
                )
        }

        .frame(
            maxWidth: .infinity
        )

        .frame(height: 30)
    }


    // MARK: Shift Check

    private func hasShift(
        on date: Date
    ) -> Bool {

        entries.contains { entry in

            calendar.isDate(
                entry.date,
                inSameDayAs: date
            )
            &&
            entry.startTime != nil
            &&
            entry.endTime != nil
        }
    }


    // MARK: Month Name

    private var monthName: String {

        let formatter =
            DateFormatter()

        formatter.locale =
            Locale.current

        formatter.dateFormat =
            "MMMM"

        return formatter.string(
            from: month
        )
    }


    // MARK: Number Of Days

    private var numberOfDays: Int {

        calendar.range(
            of: .day,
            in: .month,
            for: month
        )?.count ?? 30
    }


    // MARK: First Day Offset

    private var firstDayOffset: Int {

        guard let firstDay =
                calendar.date(
                    from: calendar.dateComponents(
                        [.year, .month],
                        from: month
                    )
                )
        else {
            return 0
        }


        let weekday =
            calendar.component(
                .weekday,
                from: firstDay
            )


        /*
         Apple weekday:
         Sunday    = 1
         Monday    = 2
         Tuesday   = 3
         ...
         Saturday  = 7

         Convert to:
         Monday    = 0
         Tuesday   = 1
         ...
         Sunday    = 6
         */

        return (weekday + 5) % 7
    }


    // MARK: Trailing Empty Cells

    private var trailingEmptyCells: Int {

        // 6 weeks × 7 days
        let totalCells = 42

        let usedCells =
            firstDayOffset
            + numberOfDays

        return max(
            totalCells - usedCells,
            0
        )
    }


    // MARK: Create Date

    private func dateForDay(
        _ day: Int
    ) -> Date? {

        var components =
            calendar.dateComponents(
                [.year, .month],
                from: month
            )

        components.day = day

        return calendar.date(
            from: components
        )
    }


    // MARK: Today

    private func isToday(
        _ date: Date
    ) -> Bool {

        calendar.isDateInToday(
            date
        )
    }
}


// MARK: - Preview

#Preview {

    CalendarView()
        .modelContainer(
            for: WorkEntry.self,
            inMemory: true
        )
}

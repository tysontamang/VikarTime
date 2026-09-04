import SwiftUI
import SwiftData

struct HistoryView: View {

    @Query(
        sort: \WorkEntry.date,
        order: .reverse
    )
    private var entries:
        [WorkEntry]


    private var calendar:
        Calendar {

        var calendar =
            Calendar(
                identifier:
                    .iso8601
            )

        calendar.timeZone =
            .current

        return calendar
    }


    var body: some View {

        NavigationStack {

            List {

                ForEach(
                    monthGroups
                ) { group in

                    NavigationLink {

                        MonthHistoryView(
                            month:
                                group.month,

                            entries:
                                group.entries
                        )

                    } label: {

                        VStack(
                            alignment:
                                .leading,

                            spacing: 4
                        ) {

                            Text(
                                monthText(
                                    group.month
                                )
                            )
                            .font(.headline)


                            Text(
                                totalWorkedText(
                                    group.entries
                                )
                            )
                            .font(
                                .subheadline
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }
                    }
                }
            }

            .navigationTitle(
                "Work History"
            )
        }
    }


    // MARK: - Actual Recorded Entries

    private var recordedEntries:
        [WorkEntry] {

        entries.filter {

            $0.startTime != nil &&
            $0.endTime != nil
        }
    }


    // MARK: - Group By Month

    private var monthGroups:
        [MonthGroup] {

        let grouped =
            Dictionary(
                grouping:
                    recordedEntries
            ) { entry -> Date in

                calendar.date(
                    from:
                        calendar
                            .dateComponents(
                                [
                                    .year,
                                    .month
                                ],

                                from:
                                    entry.date
                            )
                ) ?? entry.date
            }


        return grouped
            .map {
                month,
                entries in

                MonthGroup(
                    month: month,

                    entries:
                        entries.sorted {

                            $0.date <
                            $1.date
                        }
                )
            }

            .sorted {

                $0.month >
                $1.month
            }
    }


    private func monthText(
        _ date: Date
    ) -> String {

        let formatter =
            DateFormatter()

        formatter.dateFormat =
            "MMMM yyyy"


        return formatter.string(
            from: date
        )
    }


    private func totalWorkedText(
        _ entries:
            [WorkEntry]
    ) -> String {

        let minutes =
            entries
                .compactMap {
                    $0.workedMinutes
                }
                .reduce(0, +)


        let hours =
            minutes / 60

        let remainingMinutes =
            minutes % 60


        return "\(hours)h \(remainingMinutes)m worked"
    }
}


// MARK: - Month Group

struct MonthGroup:
    Identifiable {

    let month: Date

    let entries:
        [WorkEntry]


    var id: Date {
        month
    }
}


// MARK: - Month Detail

struct MonthHistoryView: View {

    let month: Date

    let entries:
        [WorkEntry]


    var body: some View {

        List {

            ForEach(entries) {
                entry in

                VStack(
                    alignment:
                        .leading,

                    spacing: 6
                ) {

                    Text(
                        dateText(
                            entry.date
                        )
                    )
                    .font(.headline)


                    HStack {

                        Text(
                            "\(timeText(entry.startTime)) → \(timeText(entry.endTime))"
                        )


                        Spacer()


                        Text(
                            entry.workedText
                        )
                        .fontWeight(
                            .semibold
                        )
                    }


                    Text(
                        "Break: \(entry.breakMinutes) min"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                }

                .padding(
                    .vertical,
                    4
                )
            }
        }

        .navigationTitle(
            monthText
        )
    }


    private var monthText:
        String {

        let formatter =
            DateFormatter()

        formatter.dateFormat =
            "MMMM yyyy"


        return formatter.string(
            from: month
        )
    }


    private func dateText(
        _ date: Date
    ) -> String {

        let formatter =
            DateFormatter()

        formatter.dateFormat =
            "EEEE, d MMM"


        return formatter.string(
            from: date
        )
    }


    private func timeText(
        _ date: Date?
    ) -> String {

        guard let date else {
            return "—"
        }


        let formatter =
            DateFormatter()

        formatter.dateFormat =
            "HH:mm"


        return formatter.string(
            from: date
        )
    }
}


#Preview {

    HistoryView()
        .modelContainer(
            for: WorkEntry.self,
            inMemory: true
        )
}

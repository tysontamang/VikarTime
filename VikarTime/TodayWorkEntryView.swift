import SwiftUI
import SwiftData

struct TodayWorkEntryView: View {

    let entry: WorkEntry?


    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("Today's Work")
                .font(.title2)
                .fontWeight(.bold)


            if let entry {

                VStack(spacing: 0) {

                    WorkTableHeader()

                    TodayWorkRow(
                        entry: entry
                    )
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


// MARK: - Today Row

struct TodayWorkRow: View {

    @Bindable var entry:
        WorkEntry


    var body: some View {

        HStack(spacing: 0) {

            // Date

            dataCell {

                Text(dateText)
                    .font(.caption)
                    .multilineTextAlignment(
                        .center
                    )
            }


            // Start

            dataCell {

                OptionalTimePickerCell(
                    time:
                        $entry.startTime,

                    title:
                        "Start Time"
                )
            }


            // End

            dataCell {

                OptionalTimePickerCell(
                    time:
                        $entry.endTime,

                    title:
                        "End Time"
                )
            }


            // Break

            dataCell {

                BreakPickerCell(
                    breakMinutes:
                        $entry.breakMinutes
                )
            }


            // Worked

            dataCell {

                Text(
                    entry.workedText
                )
                .font(.caption)
                .fontWeight(.bold)
                .minimumScaleFactor(
                    0.7
                )
            }
        }
    }


    private var dateText: String {

        let formatter =
            DateFormatter()

        formatter.locale =
            Locale(
                identifier:
                    "en_DK"
            )

        formatter.dateFormat =
            "dd MMM"

        return formatter.string(
            from: entry.date
        )
    }


    private func dataCell<
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
                        Color.gray
                            .opacity(
                                0.4
                            ),

                        lineWidth:
                            0.5
                    )
            }
    }
}

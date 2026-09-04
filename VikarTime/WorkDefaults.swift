import Foundation
import SwiftUI
import SwiftData


// MARK: - Work Defaults

enum WorkDefaults {

    static let startTime: Date? = nil
    static let endTime: Date? = nil

    static let breakMinutes: Int = 30

    static let monthlyHours: Double = 90
}


// MARK: - Shared Table Header

struct WorkTableHeader: View {

    var body: some View {

        HStack(spacing: 0) {

            headerCell("Date")
            headerCell("Start")
            headerCell("End")
            headerCell("Break")
            headerCell("Worked")
        }
    }

    private func headerCell(
        _ title: String
    ) -> some View {

        Text(title)
            .font(.caption2)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .frame(height: 34)
            .background(
                Color.gray.opacity(0.15)
            )
            .overlay {

                Rectangle()
                    .stroke(
                        Color.gray.opacity(0.4),
                        lineWidth: 0.5
                    )
            }
    }
}


// MARK: - Optional Time Picker

struct OptionalTimePickerCell: View {

    @Environment(\.modelContext)
    private var modelContext

    @Binding var time: Date?

    let title: String

    @State private var showPicker = false
    @State private var temporaryTime = Date()

    private var timeText: String {

        guard let time else {
            return "—"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        return formatter.string(
            from: time
        )
    }

    var body: some View {

        Button {

            temporaryTime = time ?? Date()
            showPicker = true

        } label: {

            Text(timeText)
                .font(.caption)
                .foregroundStyle(
                    time == nil
                    ? .secondary
                    : .primary
                )
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
        }
        .buttonStyle(.plain)

        .sheet(
            isPresented: $showPicker
        ) {

            NavigationStack {

                VStack {

                    DatePicker(
                        "",
                        selection: $temporaryTime,
                        displayedComponents:
                            .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()

                    Spacer()
                }
                .padding()

                .navigationTitle(title)
                .navigationBarTitleDisplayMode(
                    .inline
                )

                .toolbar {

                    ToolbarItem(
                        placement:
                            .cancellationAction
                    ) {

                        Button("Clear") {

                            time = nil

                            try? modelContext.save()

                            showPicker = false
                        }
                    }

                    ToolbarItem(
                        placement:
                            .confirmationAction
                    ) {

                        Button("Done") {

                            time = temporaryTime

                            try? modelContext.save()

                            showPicker = false
                        }
                    }
                }
            }
            .presentationDetents(
                [.medium]
            )
        }
    }
}


// MARK: - Break Picker

struct BreakPickerCell: View {

    @Environment(\.modelContext)
    private var modelContext

    @Binding var breakMinutes: Int

    @State private var showPicker = false

    @State private var temporaryMinutes =
        WorkDefaults.breakMinutes

    var body: some View {

        Button {

            temporaryMinutes = breakMinutes
            showPicker = true

        } label: {

            Text("\(breakMinutes) min")
                .font(.caption)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
        }
        .buttonStyle(.plain)

        .sheet(
            isPresented: $showPicker
        ) {

            NavigationStack {

                VStack {

                    Picker(
                        "Break Time",
                        selection:
                            $temporaryMinutes
                    ) {

                        ForEach(
                            0...180,
                            id: \.self
                        ) { minute in

                            Text(
                                "\(minute) min"
                            )
                            .tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()

                    Spacer()
                }
                .padding()

                .navigationTitle(
                    "Break Time"
                )

                .navigationBarTitleDisplayMode(
                    .inline
                )

                .toolbar {

                    ToolbarItem(
                        placement:
                            .cancellationAction
                    ) {

                        Button("Cancel") {
                            showPicker = false
                        }
                    }

                    ToolbarItem(
                        placement:
                            .confirmationAction
                    ) {

                        Button("Done") {

                            breakMinutes =
                                temporaryMinutes

                            try? modelContext.save()

                            showPicker = false
                        }
                    }
                }
            }
            .presentationDetents(
                [.medium]
            )
        }
    }
}

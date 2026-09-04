import Foundation
import SwiftData

@Model
final class WorkEntry {

    var id: UUID

    var date: Date

    var startTime: Date?

    var endTime: Date?

    var breakMinutes: Int
    
    var isWeekend: Bool {

        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current

        let weekday = calendar.component(
            .weekday,
            from: date
        )

        return weekday == 1 || weekday == 7
    }

    init(
        id: UUID = UUID(),
        date: Date,
        startTime: Date? =
            WorkDefaults.startTime,
        endTime: Date? =
            WorkDefaults.endTime,
        breakMinutes: Int =
            WorkDefaults.breakMinutes
    ) {

        self.id = id
        self.date = date

        self.startTime = startTime
        self.endTime = endTime

        self.breakMinutes =
            breakMinutes
    }


    // MARK: - Worked Minutes

    var workedMinutes: Int? {

        guard
            let startTime,
            let endTime
        else {
            return nil
        }

        var calendar =
            Calendar(identifier: .iso8601)

        calendar.timeZone = .current


        let startComponents =
            calendar.dateComponents(
                [.hour, .minute],
                from: startTime
            )

        let endComponents =
            calendar.dateComponents(
                [.hour, .minute],
                from: endTime
            )


        guard
            let startHour =
                startComponents.hour,

            let startMinute =
                startComponents.minute,

            let endHour =
                endComponents.hour,

            let endMinute =
                endComponents.minute,

            let start =
                calendar.date(
                    bySettingHour:
                        startHour,

                    minute:
                        startMinute,

                    second: 0,

                    of: date
                ),

            var end =
                calendar.date(
                    bySettingHour:
                        endHour,

                    minute:
                        endMinute,

                    second: 0,

                    of: date
                )

        else {
            return nil
        }


        // Overnight shift:
        // 21:50 -> 05:50

        if end <= start {

            end =
                calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: end
                ) ?? end
        }


        let totalMinutes =
            Int(
                end.timeIntervalSince(
                    start
                ) / 60
            )


        return max(
            totalMinutes -
            breakMinutes,
            0
        )
    }


    // MARK: - Worked Text

    var workedText: String {

        guard let workedMinutes else {
            return "—"
        }

        let hours =
            workedMinutes / 60

        let minutes =
            workedMinutes % 60

        return "\(hours)h\(String(format: "%02d", minutes))m"
    }
}

import SwiftUI

struct ProfileView: View {

    @AppStorage("hourlyRate")
    private var hourlyRate: Double = 0

    @AppStorage("weekendRate")
    private var weekendRate: Double = 0

    @AppStorage("taxFreeAmount")
    private var taxFreeAmount: Double = 0

    var body: some View {

        NavigationStack {

            Form {

                Section("Salary Settings") {

                    HStack {

                        Text("Hourly Rate")

                        Spacer()

                        TextField(
                            "0",
                            value: $hourlyRate,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)

                        Text("DKK")
                            .foregroundStyle(.secondary)
                    }


                    HStack {

                        Text("Weekend Rate")

                        Spacer()

                        TextField(
                            "0",
                            value: $weekendRate,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)

                        Text("DKK")
                            .foregroundStyle(.secondary)
                    }


                    HStack {

                        Text("Tax-Free Amount")

                        Spacer()

                        TextField(
                            "0",
                            value: $taxFreeAmount,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)

                        Text("DKK")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

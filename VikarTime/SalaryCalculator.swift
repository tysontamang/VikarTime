import Foundation

struct SalaryCalculator {

    let hourlyRate: Double
    let weekendRate: Double
    let taxFreeAmount: Double


    // MARK: - Salary Before Tax

    func salaryBeforeTax(
        totalWorkedMinutes: Int,
        weekendWorkedMinutes: Int
    ) -> Double {

        let totalWorkedHours =
            Double(totalWorkedMinutes) / 60.0

        let weekendWorkedHours =
            Double(weekendWorkedMinutes) / 60.0


        let normalSalary =
            totalWorkedHours * hourlyRate

        let weekendSupplement =
            weekendWorkedHours * weekendRate


        return normalSalary + weekendSupplement
    }


    // MARK: - 8% Tax

    func eightPercentTax(
        totalWorkedMinutes: Int,
        weekendWorkedMinutes: Int
    ) -> Double {

        let beforeTax = salaryBeforeTax(
            totalWorkedMinutes: totalWorkedMinutes,
            weekendWorkedMinutes: weekendWorkedMinutes
        )

        return beforeTax * 0.08
    }


    // MARK: - After 8% Tax

    func afterEightPercentTax(
        totalWorkedMinutes: Int,
        weekendWorkedMinutes: Int
    ) -> Double {

        let beforeTax = salaryBeforeTax(
            totalWorkedMinutes: totalWorkedMinutes,
            weekendWorkedMinutes: weekendWorkedMinutes
        )

        let eightTax = eightPercentTax(
            totalWorkedMinutes: totalWorkedMinutes,
            weekendWorkedMinutes: weekendWorkedMinutes
        )

        return beforeTax - eightTax
    }


    // MARK: - After Tax-Free Amount

    func afterTaxFreeAmount(
        totalWorkedMinutes: Int,
        weekendWorkedMinutes: Int
    ) -> Double {

        let afterEightTax =
            afterEightPercentTax(
                totalWorkedMinutes: totalWorkedMinutes,
                weekendWorkedMinutes: weekendWorkedMinutes
            )

        return afterEightTax - taxFreeAmount
    }


    // MARK: - 38% Tax

    func thirtyEightPercentTax(
        totalWorkedMinutes: Int,
        weekendWorkedMinutes: Int
    ) -> Double {

        let taxableAmount =
            afterTaxFreeAmount(
                totalWorkedMinutes: totalWorkedMinutes,
                weekendWorkedMinutes: weekendWorkedMinutes
            )

        let calculatedTax =
            taxableAmount * 0.38

        // Never subtract negative 38% tax
        return max(calculatedTax, 0)
    }


    // MARK: - Final Salary

    func finalSalary(
        totalWorkedMinutes: Int,
        weekendWorkedMinutes: Int
    ) -> Double {

        let beforeTax =
            salaryBeforeTax(
                totalWorkedMinutes: totalWorkedMinutes,
                weekendWorkedMinutes: weekendWorkedMinutes
            )

        let eightTax =
            eightPercentTax(
                totalWorkedMinutes: totalWorkedMinutes,
                weekendWorkedMinutes: weekendWorkedMinutes
            )

        let thirtyEightTax =
            thirtyEightPercentTax(
                totalWorkedMinutes: totalWorkedMinutes,
                weekendWorkedMinutes: weekendWorkedMinutes
            )

        return beforeTax
            - eightTax
            - thirtyEightTax
    }
}

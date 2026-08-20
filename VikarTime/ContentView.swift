import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {

            Image(systemName: "clock.fill")
                .font(.system(size: 60))

            Text("VikarTime")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Manage your shifts and working hours")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

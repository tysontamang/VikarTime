import SwiftUI
import SwiftData

struct MainTabView: View {

    var body: some View {

        TabView {

            HomeView()
                .tabItem {
                    Label(
                        "Home",
                        systemImage: "house.fill"
                    )
                }

            HistoryView()
                .tabItem {
                    Label(
                        "History",
                        systemImage: "clock.arrow.circlepath"
                    )
                }

            CalendarView()
                .tabItem {
                    Label(
                        "Calendar",
                        systemImage: "calendar"
                    )
                }

            ProfileView()
                .tabItem {
                    Label(
                        "Profile",
                        systemImage: "person.fill"
                    )
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(
            for: WorkEntry.self,
            inMemory: true
        )
}

import SwiftUI

struct ContentView: View {
    @StateObject private var drinkStore = DrinkStore()
    @EnvironmentObject var shortcutManager: ShortcutManager
    @State private var triggerAlcoholAdd = false
    @State private var triggerCaffeineAdd = false

    @State private var showingUserProfile = false
    @State private var showingHistory = false

    let tabBarHeight: CGFloat = 83
    let buttonHeight: CGFloat = 55

    /// Computes the current drink type based on the selected tab (0: alcohol, 1: caffeine)
    private var currentDrinkType: DrinkType {
        shortcutManager.shouldNavigateToTab == 1 ? .caffeine : .alcohol
    }

    var body: some View {
        ZStack {
            TabView(selection: Binding(
                get: { shortcutManager.shouldNavigateToTab },
                set: { shortcutManager.shouldNavigateToTab = $0 }
            )) {
                AlcoholView(
                    drinkStore: drinkStore,
                    triggerAdd: $triggerAlcoholAdd
                )
                .tabItem {
                    Image(systemName: "wineglass")
                    Text(NSLocalizedString("Alcohol", comment: ""))
                }
                .tag(0)

                CaffeineView(
                    drinkStore: drinkStore,
                    triggerAdd: $triggerCaffeineAdd
                )
                .tabItem {
                    Image(systemName: "cup.and.saucer")
                    Text(NSLocalizedString("Caffeine", comment: ""))
                }
                .tag(1)
            }
            .accentColor(.red)
            .sheet(isPresented: Binding(
                get: { shortcutManager.shouldShowDrinkEntry },
                set: {
                    shortcutManager.shouldShowDrinkEntry = $0
                    if !$0 {
                        shortcutManager.clearShortcut()
                    }
                }
            )) {
                NavigationView {
                    DrinkEntryView(drinkStore: drinkStore, drinkType: shortcutManager.drinkEntryType)
                }
            }

            // Overlay floating buttons center-aligned to the TabView bar
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        showingHistory = true
                    }) {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: buttonHeight, height: buttonHeight)
                            .overlay(
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.primary) // Adapt to light/dark mode
                            )
                            .shadow(color: Color.primary.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .accessibilityLabel(Text(NSLocalizedString("Edit", comment: "")))
                    .padding(.leading, 40)

                    Spacer()

                    Button(action: {
                        showingUserProfile = true
                    }) {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: buttonHeight, height: buttonHeight)
                            .overlay(
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.primary) // Adapt to light/dark mode
                            )
                            .shadow(color: Color.primary.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .accessibilityLabel(Text(NSLocalizedString("Me", comment: "")))
                    .padding(.trailing, 40)
                }
                .padding(.bottom, (tabBarHeight / 2) - (buttonHeight / 2)-23) // << this is 14pt
            }
        }
        .sheet(isPresented: $showingUserProfile) {
            UserProfileView(drinkStore: drinkStore)
        }
        .sheet(isPresented: $showingHistory) {
            DrinkHistoryView(drinkStore: drinkStore, drinkType: currentDrinkType)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ShortcutManager())
            .preferredColorScheme(.dark) // Preview in dark mode as well
        ContentView()
            .environmentObject(ShortcutManager())
            .preferredColorScheme(.light) // Preview in light mode
    }
}

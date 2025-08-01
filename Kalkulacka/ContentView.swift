import SwiftUI

struct ContentView: View {
    @StateObject private var drinkStore = DrinkStore()
    @EnvironmentObject var shortcutManager: ShortcutManager
    @State private var triggerAlcoholAdd = false
    @State private var triggerCaffeineAdd = false

    var body: some View {
        TabView(selection: Binding(
            get: { shortcutManager.shouldNavigateToTab },
            set: { shortcutManager.shouldNavigateToTab = $0 }
        )) {
            AlcoholView(drinkStore: drinkStore, triggerAdd: $triggerAlcoholAdd)
                .tabItem {
                    Image(systemName: "wineglass")
                    Text("Alcohol")
                }
                .tag(0)
            CaffeineView(drinkStore: drinkStore, triggerAdd: $triggerCaffeineAdd)
                .tabItem {
                    Image(systemName: "cup.and.saucer")
                    Text("Caffeine")
                }
                .tag(1)
        }
        .accentColor(.red)
        .sheet(isPresented: Binding(
            get: { shortcutManager.shouldShowDrinkEntry },
            set: { 
                shortcutManager.shouldShowDrinkEntry = $0
                if !$0 {
                    // Clear the shortcut when the sheet is dismissed
                    shortcutManager.clearShortcut()
                }
            }
        )) {
            NavigationView {
                DrinkEntryView(drinkStore: drinkStore, drinkType: shortcutManager.drinkEntryType)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 

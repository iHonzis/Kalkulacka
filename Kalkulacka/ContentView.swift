import SwiftUI

struct ContentView: View {
    @StateObject private var drinkStore = DrinkStore()
    @State private var triggerAlcoholAdd = false
    @State private var triggerCaffeineAdd = false
    @State private var lastHandledShortcut: String? = nil
    @State private var selectedTab = 0 // 0: Alcohol, 1: Caffeine
    // Shortcut handling is currently disabled/hidden - TODO

    var body: some View {
        TabView(selection: $selectedTab) {
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 

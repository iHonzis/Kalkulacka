import SwiftUI

struct AlcoholView: View {
    @ObservedObject var drinkStore: DrinkStore
    @Binding var triggerAdd: Bool
    @State private var showingAddDrink = false
    @State private var showingUserProfile = false
    @State private var showingHistory = false
    
    // Timer to refresh the view every minute
    @State private var now = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private let maxStandardDrinks = 4.0 // Recommended daily limit
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack { // Main container
                        if geometry.size.width > geometry.size.height {
                            // Landscape Layout
                            HStack(alignment: .top, spacing: 30) {
                                VStack(spacing: 30) {
                                    activityRing
                                    addDrinkButton
                                    Spacer()
                                }
                                .frame(width: geometry.size.width / 2.5)
                                
                                VStack(spacing: 30) {
                                    bacDisplay
                                    soberTimeDisplay
                                }
                            }
                        } else {
                            // Portrait Layout
                            VStack(spacing: 30) {
                                activityRing
                                bacDisplay
                                addDrinkButton
                                soberTimeDisplay
                            }
                        }
                        
                        // Hidden navigation link, shared by both layouts
                        historyLink
                    }
                    .padding()
                }
                .refreshable {
                    self.now = Date()
                }
            }
            .navigationTitle("Alcohol Tracker")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Edit") {
                        showingHistory = true
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Me") {
                        showingUserProfile = true
                    }
                    .foregroundColor(.red)
                }
            }
            .sheet(isPresented: $showingUserProfile) {
                UserProfileView(drinkStore: drinkStore)
            }
            .sheet(isPresented: $showingAddDrink) {
                DrinkEntryView(drinkStore: drinkStore, drinkType: .alcohol)
            }
            .onChange(of: triggerAdd) { newValue in
                if newValue {
                    showingAddDrink = true
                    triggerAdd = false
                }
            }
        }
        .onReceive(timer) { input in
            self.now = input
        }
    }
    
    // MARK: - Reusable View Components
    
    private var activityRing: some View {
        VStack(spacing: 16) {
            ActivityRingView(
                progress: drinkStore.getTotalStandardDrinks(),
                maxValue: maxStandardDrinks,
                color: ringColor(for: drinkStore.getTotalStandardDrinks()),
                size: 150
            )
            
            Text("Standard Drinks")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.top, 20)
    }
    
    private var bacDisplay: some View {
        HStack(spacing: 20) {
            VStack {
                Text("BAC")
                    .font(.headline)
                Text(String(format: "%.2f", drinkStore.calculateCurrentBAC()))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(bacColor(drinkStore.calculateCurrentBAC()))
                Text("‰")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                Text("Drinks")
                    .font(.headline)
                Text("\(drinkStore.getTodayDrinks(for: .alcohol).count)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                Text("today")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
    
    private var addDrinkButton: some View {
        Button(action: {
            showingAddDrink = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Add_drink")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(12)
        }
    }
    
    private var soberTimeDisplay: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("when_off")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(drinkStore.getSoberTimeString())
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            Text("alc_disclaimer")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(UIColor.systemGray))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 8)
        }
    }
    
    private var historyLink: some View {
        NavigationLink(destination: DrinkHistoryView(drinkStore: drinkStore, drinkType: .alcohol), isActive: $showingHistory) {
            EmptyView()
        }
    }
    
    private func ringColor(for drinks: Double) -> Color {
        let percentage = drinks / maxStandardDrinks
        switch percentage {
        case 0..<0.5:
            return .green
        case 0.5..<0.8:
            return .yellow
        default:
            return .red
        }
    }
    
    private func bacColor(_ bac: Double) -> Color {
        switch bac {
        case 0.0..<0.2:
            return .green
        case 0.2..<0.5:
            return .yellow
        case 0.5..<0.8:
            return .orange
        default:
            return .red
        }
    }
}

struct AlcoholView_Previews: PreviewProvider {
    static var previews: some View {
        AlcoholView(drinkStore: DrinkStore(), triggerAdd: .constant(false))
    }
} 

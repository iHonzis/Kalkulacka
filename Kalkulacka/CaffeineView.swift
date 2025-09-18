import SwiftUI
// Add this import for language manager for future
import Combine

struct CaffeineView: View {
    @ObservedObject var drinkStore: DrinkStore
    @Binding var triggerAdd: Bool
    @State private var showingAddDrink = false
    @State private var showingUserProfile = false
    @State private var showingHistory = false
    
    // Timer to refresh the view every minute
    @State private var now = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private let maxCaffeine = 400.0 // Recommended daily limit in mg
    
    var body: some View {
        NavigationStack {
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
                                    cleanTimeDisplay
                                    todaySummary
                                }
                            }
                        } else {
                            // Portrait Layout
                            VStack(spacing: 30) {
                                activityRing
                                cleanTimeDisplay
                                addDrinkButton
                                todaySummary
                            }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    self.now = Date()
                }
            }
            .navigationTitle(NSLocalizedString("title_caffeine", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("Edit", comment: "")) {
                        showingHistory = true
                    }
                    .foregroundColor(.orange)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Me", comment: "")) {
                        showingUserProfile = true
                    }
                    .foregroundColor(.orange)
                }
            }
            .sheet(isPresented: $showingUserProfile) {
                UserProfileView(drinkStore: drinkStore)
            }
            .sheet(isPresented: $showingAddDrink) {
                DrinkEntryView(drinkStore: drinkStore, drinkType: .caffeine)
            }
            .onChange(of: triggerAdd) { oldValue, newValue in
                if newValue {
                    showingAddDrink = true
                    triggerAdd = false
                }
            }
            // NEW: Replace deprecated NavigationLink with navigationDestination
            .navigationDestination(isPresented: $showingHistory) {
                DrinkHistoryView(drinkStore: drinkStore, drinkType: .caffeine)
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
                progress: drinkStore.getTotalCaffeine(),
                maxValue: maxCaffeine,
                color: .orange,
                size: 150
            )
            
            Text(NSLocalizedString("Caffeine_(mg)", comment: ""))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.top, 20)
    }
    
    private var cleanTimeDisplay: some View {
        VStack(spacing: 4) {
            Text(NSLocalizedString("when_off", comment: ""))
                .font(.headline)
                .foregroundColor(.primary)
            Text(drinkStore.getCleanTimeString())
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
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
                Text(NSLocalizedString("Add_drink", comment: ""))
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.orange)
            .cornerRadius(12)
        }
    }
    
    private var todaySummary: some View {
        VStack(spacing: 0){
            VStack(spacing: 8) {
                Text(NSLocalizedString("summary_title", comment: ""))
                    .font(.headline)
                    .foregroundColor(.primary)
                HStack(spacing: 20) {
                    VStack {
                        Text("\(String(format: "%.0f", drinkStore.calculateCurrentCaffeine()))")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Text(NSLocalizedString("mg_active", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    VStack {
                        Text("\(drinkStore.getTodayDrinks(for: .caffeine).count)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Text(NSLocalizedString("drinks", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            Text(NSLocalizedString("caffeine_disclaimer", comment: ""))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(UIColor.systemGray))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 8)
        }
    }
}

struct CaffeineView_Previews: PreviewProvider {
    static var previews: some View {
        CaffeineView(drinkStore: DrinkStore(), triggerAdd: .constant(false))
    }
} 


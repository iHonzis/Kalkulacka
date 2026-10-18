import SwiftUI
import Combine

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
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack { // Main container
                        if geometry.size.width > geometry.size.height {
                            // Landscape Layout (clear of central hinge when horizontally partially unfolded)
                            let isDuo = DeviceLayoutHelper.isIPhoneDuo
                            let centerHingeGap: CGFloat = isDuo ? 50 : 30
                            let columnWidth = max(0, (geometry.size.width - centerHingeGap - 32) / 2)
                            let boxMaxWidth: CGFloat = min(columnWidth, 360)

                            HStack(alignment: .top, spacing: centerHingeGap) {
                                VStack(spacing: 24) {
                                    activityRing
                                    addDrinkButton
                                    Spacer()
                                }
                                .frame(width: columnWidth)
                                
                                VStack(spacing: 20) {
                                    bacDisplay
                                        .frame(maxWidth: boxMaxWidth)
                                    soberTimeDisplay
                                        .frame(maxWidth: boxMaxWidth)
                                }
                                .frame(width: columnWidth)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            // Portrait Layout
                            VStack(spacing: 30) {
                                activityRing
                                bacDisplay
                                    .frame(maxWidth: min(geometry.size.width - 32, 420))
                                addDrinkButton
                                    .frame(maxWidth: min(geometry.size.width - 32, 420))
                                soberTimeDisplay
                                    .frame(maxWidth: min(geometry.size.width - 32, 420))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        // No hidden navigation link needed
                    }
                    .padding()
                }
                .refreshable {
                    self.now = Date()
                }
                .toolbar {
                    if DeviceLayoutHelper.isIPhoneDuoFolded(size: geometry.size) {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showingHistory = true
                            }) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .accessibilityLabel(Text(NSLocalizedString("Edit", comment: "")))
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showingUserProfile = true
                            }) {
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .accessibilityLabel(Text(NSLocalizedString("Me", comment: "")))
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("Alcohol Tracker", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingUserProfile) {
                UserProfileView(drinkStore: drinkStore)
            }
            .sheet(isPresented: $showingAddDrink) {
                NavigationStack {
                    DrinkEntryView(drinkStore: drinkStore, drinkType: .alcohol)
                }
            }
            .navigationDestination(isPresented: $showingHistory) {
                DrinkHistoryView(drinkStore: drinkStore, drinkType: .alcohol)
            }
            .onChange(of: triggerAdd) { oldValue, newValue in
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
            
            Text(NSLocalizedString("Standard Drinks", comment: ""))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.top, 20)
    }
    
    private var bacDisplay: some View {
        HStack(spacing: 20) {
            VStack {
                Text(NSLocalizedString("BAC", comment: ""))
                    .font(.headline)
                Text(String(format: "%.2f", drinkStore.calculateCurrentBAC()))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(bacColor(drinkStore.calculateCurrentBAC()))
                Text("‰")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                Text(NSLocalizedString("Drinks", comment: ""))
                    .font(.headline)
                Text("\(drinkStore.getTodayDrinks(for: .alcohol).count)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                Text(NSLocalizedString("today", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            Color(UIColor.systemGray5),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
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
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.red)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 4)
        }
    }
    
    private var soberTimeDisplay: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text(NSLocalizedString("when_off", comment: ""))
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(drinkStore.getSoberTimeString())
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                Color(UIColor.systemGray5),
                in: RoundedRectangle(cornerRadius: 28, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            Text(NSLocalizedString("alc_disclaimer", comment: ""))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(UIColor.systemGray))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 8)
        }
    }
    
    // Removed deprecated historyLink
    
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

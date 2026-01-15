import SwiftUI

struct DrinkEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var drinkStore: DrinkStore
    @ObservedObject private var drinksService = PopularDrinksService.shared
    
    let drinkType: DrinkType
    
    // State for custom entry
    @State private var drinkName = ""
    @State private var amount = ""
    @State private var unit = "ml"
    @State private var alcoholPercentage = ""
    @State private var caffeineContent = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var isRefreshing = false
    
    // State for segmented picker
    @State private var selectedTab = 0
    private let tabs = [NSLocalizedString("Popular", comment: ""), NSLocalizedString("Custom", comment: "")]
    
    private var popularDrinks: [PopularDrinkData] {
        drinksService.getPopularDrinks(for: drinkType)
    }
    private let units = ["ml", "oz", "cl", "fl oz"]
    
    var body: some View {
        VStack {
            if !popularDrinks.isEmpty {
                Picker(NSLocalizedString("drink_type", comment: ""), selection: $selectedTab) {
                    ForEach(0..<tabs.count, id: \ .self) { index in
                        Text(tabs[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            
            if selectedTab == 1 || popularDrinks.isEmpty {
                // Custom Drink Form
                Form {
                    Section(NSLocalizedString("Drink Details", comment: "")) {
                        TextField(NSLocalizedString("Drink name", comment: ""), text: $drinkName)
                        
                        HStack {
                            TextField(NSLocalizedString("Amount", comment: ""), text: $amount)
                                .keyboardType(.decimalPad)
                            
                            Picker(NSLocalizedString("Unit", comment: ""), selection: $unit) {
                                ForEach(units, id: \.self) { unit in
                                    Text(unit).tag(unit)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    
                    if drinkType == .alcohol {
                        Section(NSLocalizedString("Alcohol Content", comment: "")) {
                            HStack {
                                TextField(NSLocalizedString("Alcohol %", comment: ""), text: $alcoholPercentage)
                                    .keyboardType(.decimalPad)
                                Text("%")
                            }
                        }
                    }
                    
                    if drinkType == .caffeine {
                        Section(NSLocalizedString("Caffeine Content", comment: "")) {
                            HStack {
                                TextField(NSLocalizedString("Caffeine", comment: ""), text: $caffeineContent)
                                    .keyboardType(.decimalPad)
                                Text("mg")
                            }
                        }
                    }
                    
                    Section {
                        Button(NSLocalizedString("Add Drink", comment: "")) {
                            addCustomDrink()
                        }
                        .disabled(drinkName.isEmpty || amount.isEmpty)
                    }
                }
            } else {
                // Popular Drinks View
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                        ForEach(popularDrinks) { drinkData in
                            PopularDrinkButton(drink: drinkData, action: addPopularDrink)
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await refreshDrinks()
                }
            }
        }
        .navigationTitle("\(NSLocalizedString("Add", comment: "")) \(NSLocalizedString(drinkType.rawValue, comment: ""))")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(NSLocalizedString("Cancel", comment: "")) {
                    dismiss()
                }
            }
        }
        .alert(NSLocalizedString("Validation Error", comment: ""), isPresented: $showingError) {
            Button(NSLocalizedString("OK", comment: "")) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Refresh drinks when view appears (if Convex enabled and cache expired)
            Task {
                await drinksService.refreshIfNeeded()
            }
        }
        .onChange(of: drinksService.drinks.count) { oldCount, newCount in
            print("🔄 DrinkEntryView: Drinks count changed from \(oldCount) to \(newCount)")
            // Force view update
        }
    }
    
    private func refreshDrinks() async {
        isRefreshing = true
        await drinksService.forceRefresh()
        isRefreshing = false
    }
    
    private func addPopularDrink(_ popularDrink: PopularDrinkData) {
        let drink = Drink(
            type: popularDrink.drinkType,
            name: popularDrink.name,
            amount: popularDrink.volume,
            unit: "ml",
            alcoholPercentage: popularDrink.alcoholPercentage,
            caffeineContent: popularDrink.caffeineContent
        )
        
        if let error = drinkStore.addDrink(drink) {
            errorMessage = error
            showingError = true
        } else {
            dismiss()
        }
    }
    
    private func addCustomDrink() {
        guard let amountValue = Double(amount) else { 
            errorMessage = NSLocalizedString("Please enter a valid amount", comment: "")
            showingError = true
            return 
        }
        
        let drink: Drink
        
        if drinkType == .alcohol {
            let alcoholPercentageValue = Double(alcoholPercentage) ?? 0
            drink = Drink(
                type: .alcohol,
                name: drinkName,
                amount: amountValue,
                unit: unit,
                alcoholPercentage: alcoholPercentageValue
            )
        } else {
            let caffeineValue = Double(caffeineContent) ?? 0
            drink = Drink(
                type: .caffeine,
                name: drinkName,
                amount: amountValue,
                unit: unit,
                caffeineContent: caffeineValue
            )
        }
        
        if let error = drinkStore.addDrink(drink) {
            errorMessage = error
            showingError = true
        } else {
            dismiss()
        }
    }
}

struct PopularDrinkButton: View {
    let drink: PopularDrinkData
    let action: (PopularDrinkData) -> Void
    
    var body: some View {
        Button(action: {
            action(drink)
        }) {
            VStack {
                Image(drink.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(drink.name)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .padding(5)
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct DrinkEntryView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkEntryView(drinkStore: DrinkStore(), drinkType: .caffeine)
    }
} 

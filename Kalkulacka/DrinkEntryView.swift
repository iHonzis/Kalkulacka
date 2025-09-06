import SwiftUI

struct PopularDrinkData: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let volume: Double // in ml
    let drinkType: DrinkType
    var alcoholPercentage: Double? // in %
    var caffeineContent: Double? // in mg
}

struct DrinkEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var drinkStore: DrinkStore
    
    let drinkType: DrinkType
    
    // State for custom entry
    @State private var drinkName = ""
    @State private var amount = ""
    @State private var unit = "ml"
    @State private var alcoholPercentage = ""
    @State private var caffeineContent = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    // State for segmented picker
    @State private var selectedTab = 0
    private let tabs = [NSLocalizedString("Popular", comment: ""), NSLocalizedString("Custom", comment: "")]
    
    private let popularDrinks: [PopularDrinkData]
    private let units = ["ml", "oz", "cl", "fl oz"]
    
    init(drinkStore: DrinkStore, drinkType: DrinkType) {
        self.drinkStore = drinkStore
        self.drinkType = drinkType
        
        let allPopularDrinks: [PopularDrinkData] = [
            // Alcohol
            .init(name: NSLocalizedString("Beer 10º", comment: ""), imageName: "gambrinus", volume: 500, drinkType: .alcohol, alcoholPercentage: 4.1),
            .init(name: NSLocalizedString("Beer 11º", comment: ""), imageName: "kozel", volume: 500, drinkType: .alcohol, alcoholPercentage: 4.6),
            .init(name: NSLocalizedString("Beer 12º", comment: ""), imageName: "radegast", volume: 500, drinkType: .alcohol, alcoholPercentage: 5.1),
            .init(name: NSLocalizedString("Wine Glass", comment: ""), imageName: "wine_glass", volume: 200, drinkType: .alcohol, alcoholPercentage: 14.0),
            .init(name: NSLocalizedString("Wine Bottle", comment: ""), imageName: "wine_bottle", volume: 750, drinkType: .alcohol, alcoholPercentage: 14.0),
            .init(name: NSLocalizedString("Vodka", comment: ""), imageName: "vodka", volume: 40, drinkType: .alcohol, alcoholPercentage: 40.0),
            .init(name: NSLocalizedString("Champagne", comment: ""), imageName: "champagne", volume: 150, drinkType: .alcohol, alcoholPercentage: 11.0),
            .init(name: NSLocalizedString("Cider", comment: ""), imageName: "cider", volume: 400, drinkType: .alcohol, alcoholPercentage: 4.5),
            .init(name: NSLocalizedString("Absinth", comment: ""), imageName: "absinth", volume: 40, drinkType: .alcohol, alcoholPercentage: 70.0),
            .init(name: NSLocalizedString("Gin Tonic", comment: ""), imageName: "gin_tonic", volume: 250, drinkType: .alcohol, alcoholPercentage: 11.0),
            .init(name: NSLocalizedString("Moscow Mule", comment: ""), imageName: "moscow_mule", volume: 200, drinkType: .alcohol, alcoholPercentage: 10.0),
            .init(name: NSLocalizedString("Cuba Libre", comment: ""), imageName: "cuba_libre", volume: 200, drinkType: .alcohol, alcoholPercentage: 11.0),
            .init(name: NSLocalizedString("Mojito", comment: ""), imageName: "mojito", volume: 250, drinkType: .alcohol, alcoholPercentage: 9.0),
            .init(name: NSLocalizedString("Whiskey", comment: ""), imageName: "whiskey", volume: 40, drinkType: .alcohol, alcoholPercentage: 45.0),
            .init(name: NSLocalizedString("Rum", comment: ""), imageName: "rum", volume: 40, drinkType: .alcohol, alcoholPercentage: 40.0),
            .init(name: NSLocalizedString("Green", comment: ""), imageName: "green", volume: 40, drinkType: .alcohol, alcoholPercentage: 20.0),
            .init(name: NSLocalizedString("Jägermeister", comment: ""), imageName: "jager", volume: 40, drinkType: .alcohol, alcoholPercentage: 35.0),
            .init(name: NSLocalizedString("B Lemond", comment: ""), imageName: "lemond", volume: 40, drinkType: .alcohol, alcoholPercentage: 20.0),
            
            // Caffeine
            .init(name: NSLocalizedString("Red Bull", comment: ""), imageName: "red_bull", volume: 250, drinkType: .caffeine, caffeineContent: 80),
            .init(name: NSLocalizedString("Monster", comment: ""), imageName: "monster", volume: 500, drinkType: .caffeine, caffeineContent: 160),
            .init(name: NSLocalizedString("Monster Ultra", comment: ""), imageName: "monster_ultra", volume: 500, drinkType: .caffeine, caffeineContent: 150),
            .init(name: NSLocalizedString("Crazy Wolf", comment: ""), imageName: "crazy_wolf", volume: 500, drinkType: .caffeine, caffeineContent: 150),
            .init(name: NSLocalizedString("Tiger", comment: ""), imageName: "tiger", volume: 250, drinkType: .caffeine, caffeineContent: 80),
            .init(name: NSLocalizedString("Rockstar", comment: ""), imageName: "rockstar", volume: 500, drinkType: .caffeine, caffeineContent: 160),
            .init(name: NSLocalizedString("Big Shock", comment: ""), imageName: "big_shock", volume: 500, drinkType: .caffeine, caffeineContent: 160),
            .init(name: NSLocalizedString("Espresso", comment: ""), imageName: "espresso", volume: 30, drinkType: .caffeine, caffeineContent: 70),
            .init(name: NSLocalizedString("Double Espresso", comment: ""), imageName: "double_espresso", volume: 60, drinkType: .caffeine, caffeineContent: 140),
            .init(name: NSLocalizedString("Cappuccino", comment: ""), imageName: "cappuccino", volume: 170, drinkType: .caffeine, caffeineContent: 70),
            .init(name: NSLocalizedString("Caffe Latte", comment: ""), imageName: "latte", volume: 220, drinkType: .caffeine, caffeineContent: 70),
            .init(name: NSLocalizedString("Flat White", comment: ""), imageName: "flat_white", volume: 170, drinkType: .caffeine, caffeineContent: 100),
            .init(name: NSLocalizedString("Green Tea", comment: ""), imageName: "greeen", volume: 300, drinkType: .caffeine, caffeineContent: 40),
            .init(name: NSLocalizedString("Black Tea", comment: ""), imageName: "black", volume: 300, drinkType: .caffeine, caffeineContent: 70),
            .init(name: NSLocalizedString("Americano", comment: ""), imageName: "kafe", volume: 200, drinkType: .caffeine, caffeineContent: 71)
        ]
        
        self.popularDrinks = allPopularDrinks.filter { $0.drinkType == drinkType }
    }
    
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
            }
        }
        .navigationTitle("\(NSLocalizedString("Add", comment: "")) \(drinkType.rawValue)")
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

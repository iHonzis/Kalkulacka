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
    
    // State for segmented picker
    @State private var selectedTab = 0
    private let tabs = ["Popular", "Custom"]
    
    private let popularDrinks: [PopularDrinkData]
    private let units = ["ml", "oz", "cl", "fl oz"]
    
    init(drinkStore: DrinkStore, drinkType: DrinkType) {
        self.drinkStore = drinkStore
        self.drinkType = drinkType
        
        let allPopularDrinks: [PopularDrinkData] = [
            // Alcohol
            .init(name: "Beer 10º", imageName: "gambrinus", volume: 500, drinkType: .alcohol, alcoholPercentage: 4.1),
            .init(name: "Beer 11º", imageName: "kozel", volume: 500, drinkType: .alcohol, alcoholPercentage: 4.6),
            .init(name: "Beer 12º", imageName: "radegast", volume: 500, drinkType: .alcohol, alcoholPercentage: 5.1),
            .init(name: "Wine Glass", imageName: "wine_glass", volume: 200, drinkType: .alcohol, alcoholPercentage: 14.0),
            .init(name: "Wine Bottle", imageName: "wine_bottle", volume: 750, drinkType: .alcohol, alcoholPercentage: 14.0),
            .init(name: "Vodka", imageName: "vodka", volume: 40, drinkType: .alcohol, alcoholPercentage: 40.0),
            .init(name: "Champagne", imageName: "champagne", volume: 150, drinkType: .alcohol, alcoholPercentage: 11.0),
            .init(name: "Cider", imageName: "cider", volume: 400, drinkType: .alcohol, alcoholPercentage: 4.5),
            .init(name: "Absinth", imageName: "absinth", volume: 40, drinkType: .alcohol, alcoholPercentage: 70.0),
            .init(name: "Gin Tonic", imageName: "gin_tonic", volume: 250, drinkType: .alcohol, alcoholPercentage: 11.0),
            .init(name: "Moscow Mule", imageName: "moscow_mule", volume: 200, drinkType: .alcohol, alcoholPercentage: 10.0),
            .init(name: "Cuba Libre", imageName: "cuba_libre", volume: 200, drinkType: .alcohol, alcoholPercentage: 11.0),
            .init(name: "Mojito", imageName: "mojito", volume: 250, drinkType: .alcohol, alcoholPercentage: 9.0),
            .init(name: "Whiskey", imageName: "whiskey", volume: 40, drinkType: .alcohol, alcoholPercentage: 45.0),
            .init(name: "Rum", imageName: "rum", volume: 40, drinkType: .alcohol, alcoholPercentage: 40.0),
            .init(name: "Green", imageName: "green", volume: 40, drinkType: .alcohol, alcoholPercentage: 20.0),
            .init(name: "Jägermeister", imageName: "jager", volume: 40, drinkType: .alcohol, alcoholPercentage: 35.0),
            .init(name: "B Lemond", imageName: "lemond", volume: 40, drinkType: .alcohol, alcoholPercentage: 20.0),
            
            // Caffeine
            .init(name: "Red Bull", imageName: "red_bull", volume: 250, drinkType: .caffeine, caffeineContent: 80),
            .init(name: "Monster", imageName: "monster", volume: 500, drinkType: .caffeine, caffeineContent: 160),
            .init(name: "Monster Ultra", imageName: "monster_ultra", volume: 500, drinkType: .caffeine, caffeineContent: 150),
            .init(name: "Crazy Wolf", imageName: "crazy_wolf", volume: 500, drinkType: .caffeine, caffeineContent: 150),
            .init(name: "Tiger", imageName: "tiger", volume: 250, drinkType: .caffeine, caffeineContent: 80),
            .init(name: "Rockstar", imageName: "rockstar", volume: 500, drinkType: .caffeine, caffeineContent: 160),
            .init(name: "Big Shock", imageName: "big_shock", volume: 500, drinkType: .caffeine, caffeineContent: 160),
            .init(name: "Espresso", imageName: "espresso", volume: 30, drinkType: .caffeine, caffeineContent: 70),
            .init(name: "Double Espresso", imageName: "double_espresso", volume: 60, drinkType: .caffeine, caffeineContent: 140),
            .init(name: "Cappuccino", imageName: "cappuccino", volume: 170, drinkType: .caffeine, caffeineContent: 70),
            .init(name: "Caffe Latte", imageName: "latte", volume: 220, drinkType: .caffeine, caffeineContent: 70),
            .init(name: "Flat White", imageName: "flat_white", volume: 170, drinkType: .caffeine, caffeineContent: 100),
            .init(name: "Green Tea", imageName: "greeen", volume: 300, drinkType: .caffeine, caffeineContent: 40),
            .init(name: "Black Tea", imageName: "black", volume: 300, drinkType: .caffeine, caffeineContent: 70),
            .init(name: "Americano", imageName: "kafe", volume: 200, drinkType: .caffeine, caffeineContent: 71)
        ]
        
        self.popularDrinks = allPopularDrinks.filter { $0.drinkType == drinkType }
    }
    
    var body: some View {
        VStack {
            if !popularDrinks.isEmpty {
                Picker("Drink Type", selection: $selectedTab) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Text(tabs[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            
            if selectedTab == 1 || popularDrinks.isEmpty {
                // Custom Drink Form
                Form {
                    Section("Drink Details") {
                        TextField("Drink name", text: $drinkName)
                        
                        HStack {
                            TextField("Amount", text: $amount)
                                .keyboardType(.decimalPad)
                            
                            Picker("Unit", selection: $unit) {
                                ForEach(units, id: \.self) { unit in
                                    Text(unit).tag(unit)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    
                    if drinkType == .alcohol {
                        Section("Alcohol Content") {
                            HStack {
                                TextField("Alcohol %", text: $alcoholPercentage)
                                    .keyboardType(.decimalPad)
                                Text("%")
                            }
                        }
                    }
                    
                    if drinkType == .caffeine {
                        Section("Caffeine Content") {
                            HStack {
                                TextField("Caffeine", text: $caffeineContent)
                                    .keyboardType(.decimalPad)
                                Text("mg")
                            }
                        }
                    }
                    
                    Section {
                        Button("Add Drink") {
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
        .navigationTitle("Add \(drinkType.rawValue)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
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
        drinkStore.addDrink(drink)
        dismiss()
    }
    
    private func addCustomDrink() {
        guard let amountValue = Double(amount) else { return }
        
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
        
        drinkStore.addDrink(drink)
        dismiss()
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

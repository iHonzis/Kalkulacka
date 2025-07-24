import SwiftUI

struct DrinkHistoryView: View {
    @ObservedObject var drinkStore: DrinkStore
    let drinkType: DrinkType
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var showingTimePicker = false
    @State private var selectedDrink: Drink?
    @State private var selectedTime = Date()
    
    var body: some View {
        List {
            let drinks = drinkStore.getDrinks(for: drinkType)
            
            if drinks.isEmpty {
                Text("No \(drinkType.rawValue.lowercased()) drinks recorded.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                let groupedDrinks = Dictionary(grouping: drinks) { drink in
                    Calendar.current.startOfDay(for: drink.timestamp)
                }
                
                let sortedDates = groupedDrinks.keys.sorted(by: >)
                
                ForEach(sortedDates, id: \.self) { date in
                    Section(header: Text(date, style: .date)) {
                        ForEach(groupedDrinks[date]!.sorted(by: { $0.timestamp > $1.timestamp })) { drink in
                            DrinkHistoryRow(drink: drink)
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button("Edit Time") {
                                        selectedDrink = drink
                                        selectedTime = drink.timestamp
                                        showingTimePicker = true
                                    }
                                    .tint(.blue)
                                }
                        }
                        .onDelete { offsets in
                            deleteDrink(in: groupedDrinks[date]!, at: offsets)
                        }
                    }
                }
            }
            
            if !drinks.isEmpty {
                Section {
                    Button("Delete All \(drinkType.rawValue)s") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("\(drinkType.rawValue) History")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !drinkStore.getDrinks(for: drinkType).isEmpty {
                    EditButton()
                        .foregroundColor(drinkType.color)
                }
            }
        }
        .alert("Are you sure?", isPresented: $showingDeleteAlert) {
            Button("Delete All", role: .destructive) {
                drinkStore.removeAllDrinks(for: drinkType)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all \(drinkStore.getDrinks(for: drinkType).count) recorded \(drinkType.rawValue.lowercased()) drinks.")
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(
                selectedTime: $selectedTime,
                drinkName: selectedDrink?.name ?? "",
                onSave: {
                    if let drink = selectedDrink {
                        drinkStore.updateDrinkTimestamp(drink, newTimestamp: selectedTime)
                    }
                    showingTimePicker = false
                },
                onCancel: {
                    showingTimePicker = false
                }
            )
        }
    }
    
    private func deleteDrink(in group: [Drink], at offsets: IndexSet) {
        let sortedGroup = group.sorted(by: { $0.timestamp > $1.timestamp })
        for index in offsets {
            let drinkToDelete = sortedGroup[index]
            drinkStore.removeDrink(drinkToDelete)
        }
    }
}

struct DrinkHistoryRow: View {
    let drink: Drink
    
    var body: some View {
        HStack {
            Image(systemName: drink.type.icon)
                .foregroundColor(drink.type.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(drink.name)
                    .font(.headline)
                
                HStack {
                    Text("\(String(format: "%.1f", drink.amount)) \(drink.unit)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if drink.type == .alcohol, let alcoholPercentage = drink.alcoholPercentage {
                        Text("• \(String(format: "%.1f", alcoholPercentage))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if drink.type == .caffeine, let caffeineContent = drink.caffeineContent {
                        Text("• \(String(format: "%.0f", caffeineContent))mg")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if drink.type == .alcohol {
                    Text("\(String(format: "%.1f", drink.standardDrinks)) std")
                        .font(.caption)
                        .foregroundColor(drink.type.color)
                } else if drink.type == .caffeine, let caffeineContent = drink.caffeineContent {
                    Text("\(String(format: "%.0f", caffeineContent))mg")
                        .font(.caption)
                        .foregroundColor(drink.type.color)
                }
                
                Text(drink.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TimePickerSheet: View {
    @Binding var selectedTime: Date
    let drinkName: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Edit Time for \(drinkName)")
                    .font(.headline)
                    .padding(.top)
                
                DatePicker(
                    "Time",
                    selection: $selectedTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                
                Spacer()
            }
            .navigationTitle("Edit Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct DrinkHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DrinkHistoryView(drinkStore: DrinkStore(), drinkType: .alcohol)
        }
    }
} 
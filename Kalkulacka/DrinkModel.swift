    extension Gender {
        // Alcohol elimination rate in g/kg/hr
        var alcoholEliminationRate: Double {
            switch self {
            case .male:
                return 0.1
            case .female:
                return 0.085
            }
        }
    }
import Foundation
import SwiftUI

enum DrinkType: String, CaseIterable, Codable {
    case alcohol = "Alcohol"
    case caffeine = "Caffeine"
    
    var color: Color {
        switch self {
        case .alcohol:
            return .red
        case .caffeine:
            return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .alcohol:
            return "wineglass"
        case .caffeine:
            return "cup.and.saucer"
        }
    }
}

enum Gender: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
    //case other = "Other"
    
    var distributionFactor: Double {
        switch self {
        case .male:
            return 0.68
        case .female:
            return 0.55
        //case .other:
            //return 0.61 // Average of male and female
        }
    }
    
    var localizedName: String {
        switch self {
        case .male:
            return NSLocalizedString("Male", comment: "")
        case .female:
            return NSLocalizedString("Female", comment: "")
        }
    }
}

struct UserProfile: Codable {
    var age: Int = 25
    var gender: Gender = .male
    var weight: Double = 70.0 // in kg
    var height: Double = 170.0 // in cm
    
    var bmi: Double {
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }

    // Alcohol distribution factor (Widmark r) using BMI, per Searle (2014):
    var alcoholDistributionFactor: Double {
        switch gender {
        case .male:
            return 1.0181 - 0.01213 * bmi
        case .female:
            return 0.9367 - 0.01240 * bmi
        }
    }
}

struct Drink: Identifiable, Codable {
    let id: UUID
    let type: DrinkType
    let name: String
    let amount: Double
    let unit: String
    let timestamp: Date
    
    // Alcohol properties
    var alcoholPercentage: Double?
    var alcoholGrams: Double {
        guard let alcoholPercentage = alcoholPercentage else { return 0 }

        let amountInML: Double
        switch unit.lowercased() {
        case "oz", "fl oz":
            amountInML = amount * 29.5735
        case "cl":
            amountInML = amount * 10
        default:
            amountInML = amount
        }

        return amountInML * (alcoholPercentage / 100.0) * 0.789
    }

    var standardDrinks: Double {
        // 1 standard drink = 14g of pure alcohol.
        return alcoholGrams / 14.0
    }
    
    // Caffeine properties
    var caffeineContent: Double? // in mg
    
    init(type: DrinkType, name: String, amount: Double, unit: String, alcoholPercentage: Double? = nil, caffeineContent: Double? = nil) {
        self.id = UUID()
        self.type = type
        self.name = name
        self.amount = amount
        self.unit = unit
        self.timestamp = Date()
        self.alcoholPercentage = alcoholPercentage
        self.caffeineContent = caffeineContent
    }
    
    init(id: UUID, type: DrinkType, name: String, amount: Double, unit: String, timestamp: Date, alcoholPercentage: Double? = nil, caffeineContent: Double? = nil) {
        self.id = id
        self.type = type
        self.name = name
        self.amount = amount
        self.unit = unit
        self.timestamp = timestamp
        self.alcoholPercentage = alcoholPercentage
        self.caffeineContent = caffeineContent
    }
}

class DrinkStore: ObservableObject {
    @Published var drinks: [Drink] = []
    @Published var userProfile: UserProfile = UserProfile()
    
    private let userDefaults = UserDefaults.standard
    private let drinksKey = "SavedDrinks"
    private let profileKey = "UserProfile"
    
    // Validation constants
    private let maxDrinkSizeML = 2500.0 // Maximum drink size in ml
    private let maxAlcoholPercentage = 100.0 // Maximum alcohol percentage
    private let maxCaffeineContent = 250.0 // Maximum caffeine content in mg
    
    init() {
        loadDrinks()
        loadUserProfile()
    }
    
    // MARK: - Validation Functions
    
    /// Validates drink size based on unit and returns error message if invalid
    func validateDrinkSize(amount: Double, unit: String) -> String? {
        let amountInML = convertToML(amount: amount, unit: unit)
        
        if amountInML > maxDrinkSizeML {
            let maxInUnit = convertFromML(amount: maxDrinkSizeML, unit: unit)
            return "Drink size cannot exceed \(String(format: "%.0f", maxInUnit)) \(unit)"
        }
        
        if amountInML <= 0 {
            return NSLocalizedString("Drink size must be greater than 0", comment: "")
        }
        
        return nil
    }
    
    /// Validates alcohol percentage and returns error message if invalid
    func validateAlcoholPercentage(_ percentage: Double) -> String? {
        if percentage > maxAlcoholPercentage {
            return NSLocalizedString("Alcohol percentage cannot exceed %@%", comment: "").replacingOccurrences(of: "%@", with: String(format: "%.0f", maxAlcoholPercentage))
        }
        
        if percentage < 0 {
            return NSLocalizedString("Alcohol percentage cannot be negative", comment: "")
        }
        
        return nil
    }
    
    /// Validates caffeine content and returns error message if invalid
    func validateCaffeineContent(_ caffeine: Double) -> String? {
        if caffeine > maxCaffeineContent {
            return NSLocalizedString("Caffeine content cannot exceed %@mg", comment: "").replacingOccurrences(of: "%@", with: String(format: "%.0f", maxCaffeineContent))
        }
        
        if caffeine < 0 {
            return NSLocalizedString("Caffeine content cannot be negative", comment: "")
        }
        
        return nil
    }
    
    /// Converts amount to milliliters for validation
    private func convertToML(amount: Double, unit: String) -> Double {
        switch unit.lowercased() {
        case "ml":
            return amount
        case "oz":
            return amount * 29.5735 // 1 oz = 29.5735 ml
        case "cl":
            return amount * 10 // 1 cl = 10 ml
        case "fl oz":
            return amount * 29.5735 // 1 fl oz = 29.5735 ml
        default:
            return amount // Default to ml if unit not recognized
        }
    }
    
    /// Converts amount from milliliters to specified unit
    private func convertFromML(amount: Double, unit: String) -> Double {
        switch unit.lowercased() {
        case "ml":
            return amount
        case "oz":
            return amount / 29.5735
        case "cl":
            return amount / 10
        case "fl oz":
            return amount / 29.5735
        default:
            return amount
        }
    }
    
    func addDrink(_ drink: Drink) -> String? {
        // Validate drink size
        if let sizeError = validateDrinkSize(amount: drink.amount, unit: drink.unit) {
            return sizeError
        }
        
        // Validate alcohol percentage if applicable
        if drink.type == .alcohol, let alcoholPercentage = drink.alcoholPercentage {
            if let alcoholError = validateAlcoholPercentage(alcoholPercentage) {
                return alcoholError
            }
        }
        
        // Validate caffeine content if applicable
        if drink.type == .caffeine, let caffeineContent = drink.caffeineContent {
            if let caffeineError = validateCaffeineContent(caffeineContent) {
                return caffeineError
            }
        }
        
        drinks.append(drink)
        saveDrinks()
        return nil // No error
    }
    
    func removeDrink(_ drink: Drink) {
        drinks.removeAll { $0.id == drink.id }
        saveDrinks()
    }
    
    func duplicateDrink(_ drink: Drink) {
        let duplicatedDrink = Drink(
            id: UUID(),
            type: drink.type,
            name: drink.name,
            amount: drink.amount,
            unit: drink.unit,
            timestamp: Date(),
            alcoholPercentage: drink.alcoholPercentage,
            caffeineContent: drink.caffeineContent
        )
        drinks.append(duplicatedDrink)
        saveDrinks()
    }
    
    func removeAllDrinks(for type: DrinkType) {
        drinks.removeAll { $0.type == type }
        saveDrinks()
    }
    
    func updateDrinkTimestamp(_ drink: Drink, newTimestamp: Date) {
        if let index = drinks.firstIndex(where: { $0.id == drink.id }) {
            // Create a new drink with the updated timestamp
            let updatedDrink = Drink(
                id: drink.id,
                type: drink.type,
                name: drink.name,
                amount: drink.amount,
                unit: drink.unit,
                timestamp: newTimestamp,
                alcoholPercentage: drink.alcoholPercentage,
                caffeineContent: drink.caffeineContent
            )
            drinks[index] = updatedDrink
            saveDrinks()
        }
    }
    
    func updateUserProfile(_ profile: UserProfile) {
        userProfile = profile
        saveUserProfile()
    }
    
    func getDrinks(for type: DrinkType, in dateRange: DateInterval? = nil) -> [Drink] {
        let filtered = drinks.filter { $0.type == type }
        if let dateRange = dateRange {
            return filtered.filter { drink in
                dateRange.contains(drink.timestamp)
            }
        }
        return filtered
    }
    
    func getTodayDrinks(for type: DrinkType) -> [Drink] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let dateRange = DateInterval(start: today, end: tomorrow)
        
        return getDrinks(for: type, in: dateRange)
    }
    
    func getTotalStandardDrinks() -> Double {
        return activeAlcoholGrams() / 14.0
    }
    
    func getTotalCaffeine() -> Double {
        let todayCaffeine = getTodayDrinks(for: .caffeine)
        return todayCaffeine.reduce(0) { $0 + ($1.caffeineContent ?? 0) }
    }
    
    // Kept for non-alcohol callers that need a rolling time window.
    func getRecentDrinks(for type: DrinkType, hours: Double = 24) -> [Drink] {
        let now = Date()
        let from = now.addingTimeInterval(-hours * 3600)
        
        return drinks.filter { $0.type == type && $0.timestamp >= from }
    }
    
    // Blood Alcohol Content calculation in Promile (‰)
    func calculateCurrentBAC() -> Double {
        let totalRemainingAlcoholGrams = remainingAlcoholGrams()
        guard totalRemainingAlcoholGrams > 0 else { return 0.0 }

        let bodyWeightInGrams = userProfile.weight * 1000
        let distributionFactor = userProfile.alcoholDistributionFactor
        let bac = (totalRemainingAlcoholGrams / (bodyWeightInGrams * distributionFactor)) * 1000
        return max(0, bac)
    }
    
    // Calculate caffeine half-life based on age using the provided formula
    private func caffeineHalfLife(for age: Int) -> Double {
        // T1/2(V) ≈ 5 * (1.008)^(V-20)
        return 5.0 * pow(1.008, Double(age - 20))
    }

    // Calculate current caffeine level using exponential decay (first-order kinetics)
    func calculateCurrentCaffeine() -> Double {
        return caffeineLevel(at: Date())
    }

    // Calculate when user will be clean (Caffeine < 5mg) using exponential decay
    func calculateCleanTime() -> Date? {
        let now = Date()
        guard caffeineLevel(at: now) > 5 else { return nil }

        var lowerBound = now
        var upperBound = now.addingTimeInterval(24 * 3600)
        while caffeineLevel(at: upperBound) > 5 {
            upperBound = upperBound.addingTimeInterval(24 * 3600)
        }

        for _ in 0..<60 {
            let midpoint = lowerBound.addingTimeInterval(upperBound.timeIntervalSince(lowerBound) / 2)
            if caffeineLevel(at: midpoint) > 5 {
                lowerBound = midpoint
            } else {
                upperBound = midpoint
            }
        }

        return upperBound
    }

    private func caffeineLevel(at date: Date) -> Double {
        let halfLife = caffeineHalfLife(for: userProfile.age)
        let decayConstant = log(2) / halfLife

        let totalCaffeine = drinks
            .filter { $0.type == .caffeine && $0.timestamp <= date }
            .reduce(0.0) { total, drink in
                guard let caffeine = drink.caffeineContent else { return total }
                let hoursElapsed = date.timeIntervalSince(drink.timestamp) / 3600.0
                return total + caffeine * exp(-decayConstant * hoursElapsed)
            }

        return max(0, totalCaffeine)
    }

    // Format clean time for display
    func getCleanTimeString() -> String {
        guard let cleanTime = calculateCleanTime() else {
            return NSLocalizedString("Empty", comment: "")
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short

        return formatter.string(from: cleanTime)
    }
    
    // Calculate when user will be sober (BAC < 0.2‰)
    func calculateSoberTime() -> Date? {
        let remainingAlcohol = remainingAlcoholGrams()
        guard remainingAlcohol > 0 else { return nil }

        let eliminationRate = userProfile.weight * userProfile.gender.alcoholEliminationRate
        guard eliminationRate > 0 else { return nil }

        let hoursToSober = remainingAlcohol / eliminationRate
        return Date().addingTimeInterval(hoursToSober * 3600)
    }

    private func remainingAlcoholGrams(at date: Date = Date()) -> Double {
        let alcoholDrinks = drinks
            .filter { $0.type == .alcohol && $0.timestamp <= date }
            .sorted { $0.timestamp < $1.timestamp }
        let eliminationRate = userProfile.weight * userProfile.gender.alcoholEliminationRate

        var remainingAlcohol = 0.0
        var previousTimestamp: Date?

        for drink in alcoholDrinks {
            if let previousTimestamp = previousTimestamp {
                let hoursSincePreviousDrink = max(0, drink.timestamp.timeIntervalSince(previousTimestamp) / 3600.0)
                remainingAlcohol = max(0, remainingAlcohol - eliminationRate * hoursSincePreviousDrink)
            }

            remainingAlcohol += drink.alcoholGrams
            previousTimestamp = drink.timestamp
        }

        if let previousTimestamp = previousTimestamp {
            let hoursSinceLastDrink = max(0, date.timeIntervalSince(previousTimestamp) / 3600.0)
            remainingAlcohol = max(0, remainingAlcohol - eliminationRate * hoursSinceLastDrink)
        }

        return remainingAlcohol
    }

    private func activeAlcoholGrams(at date: Date = Date()) -> Double {
        let alcoholDrinks = drinks
            .filter { $0.type == .alcohol && $0.timestamp <= date }
            .sorted { $0.timestamp < $1.timestamp }
        let eliminationRate = userProfile.weight * userProfile.gender.alcoholEliminationRate

        var remainingAlcohol = 0.0
        var activeAlcohol = 0.0
        var previousTimestamp: Date?

        for drink in alcoholDrinks {
            if let previousTimestamp = previousTimestamp {
                let hoursSincePreviousDrink = max(0, drink.timestamp.timeIntervalSince(previousTimestamp) / 3600.0)
                remainingAlcohol -= eliminationRate * hoursSincePreviousDrink

                if remainingAlcohol <= 0 {
                    activeAlcohol = 0
                }
                remainingAlcohol = max(0, remainingAlcohol)
            }

            remainingAlcohol += drink.alcoholGrams
            activeAlcohol += drink.alcoholGrams
            previousTimestamp = drink.timestamp
        }

        if let previousTimestamp = previousTimestamp {
            let hoursSinceLastDrink = max(0, date.timeIntervalSince(previousTimestamp) / 3600.0)
            remainingAlcohol -= eliminationRate * hoursSinceLastDrink

            if remainingAlcohol <= 0 {
                return 0
            }
        }

        return activeAlcohol
    }
    
    // Format sober time for display
    func getSoberTimeString() -> String {
        guard let soberTime = calculateSoberTime() else {
            return NSLocalizedString("Already sober", comment: "")
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        
        return formatter.string(from: soberTime)
    }
    
    private func saveDrinks() {
        if let encoded = try? JSONEncoder().encode(drinks) {
            userDefaults.set(encoded, forKey: drinksKey)
        }
    }
    
    private func loadDrinks() {
        if let data = userDefaults.data(forKey: drinksKey),
           let decoded = try? JSONDecoder().decode([Drink].self, from: data) {
            drinks = decoded
        }
    }
    
    private func saveUserProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            userDefaults.set(encoded, forKey: profileKey)
        }
    }
    
    private func loadUserProfile() {
        if let data = userDefaults.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
    }
} 

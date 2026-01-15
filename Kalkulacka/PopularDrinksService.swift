import Foundation
#if canImport(ConvexMobile)
import ConvexMobile
#endif

// Struct to match Convex database schema
struct ConvexDrink: Codable {
    let _id: String
    let name: String
    let imageName: String
    let volume: Double
    let drinkType: String
    let alcoholPercentage: Double?
    let caffeineContent: Double?
}

struct PopularDrinkData: Identifiable, Codable {
    let id: UUID
    let name: String
    let imageName: String
    let volume: Double // in ml
    let drinkType: DrinkType
    var alcoholPercentage: Double? // in %
    var caffeineContent: Double? // in mg
    
    init(id: UUID = UUID(), name: String, imageName: String, volume: Double, drinkType: DrinkType, alcoholPercentage: Double? = nil, caffeineContent: Double? = nil) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.volume = volume
        self.drinkType = drinkType
        self.alcoholPercentage = alcoholPercentage
        self.caffeineContent = caffeineContent
    }
}

class PopularDrinksService: ObservableObject {
    static let shared = PopularDrinksService()
    
    @Published private(set) var drinks: [PopularDrinkData] = [] {
        didSet {
            print("📊 Drinks array updated: \(drinks.count) drinks")
            if let sample = drinks.first(where: { $0.name.contains("Coca") || $0.name.contains("Pepsi") || $0.name.contains("Kofola") }) {
                print("📊 Sample drink in array: \(sample.name) - Volume: \(sample.volume)ml")
            }
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let cachedDrinksKey = "CachedPopularDrinks"
    private let lastUpdateKey = "LastDrinksUpdate"
    
    // Cache expiration: 24 hours (change to shorter for testing, e.g., 60 seconds)
    private let cacheExpirationInterval: TimeInterval = 24 * 60 * 60
    
    // For testing: set to true to always fetch on app launch (ignores cache)
    private let alwaysFetchOnLaunch = false
    
    private init() {
        // Priority order: 1) Cached Convex data, 2) Built-in drinks (fallback)
        // Note: Fresh Convex fetch happens on app launch via refreshIfNeeded()
        
        if let data = userDefaults.data(forKey: cachedDrinksKey),
           let decoded = try? JSONDecoder().decode([PopularDrinkData].self, from: data),
           !decoded.isEmpty {
            // Use cached Convex data (highest priority after fresh fetch)
            drinks = decoded
            print("🍹 Loaded \(decoded.count) drinks from cache (Convex data)")
        } else {
            // No cache, use built-in drinks as fallback
            drinks = builtInDrinks
            saveCachedDrinks()
            print("🍹 Loaded \(builtInDrinks.count) built-in drinks (no cache available)")
        }
    }
    
    /// Returns all popular drinks filtered by type
    func getPopularDrinks(for drinkType: DrinkType) -> [PopularDrinkData] {
        return drinks.filter { $0.drinkType == drinkType }
    }
    
    /// Returns all popular drinks
    var allPopularDrinks: [PopularDrinkData] {
        return drinks
    }
    
    // MARK: - Caching
    
    /// Loads cached drinks from UserDefaults
    private func loadCachedDrinks() {
        guard let data = userDefaults.data(forKey: cachedDrinksKey),
              let decoded = try? JSONDecoder().decode([PopularDrinkData].self, from: data) else {
            return
        }
        drinks = decoded
    }
    
    /// Saves drinks to UserDefaults cache
    private func saveCachedDrinks() {
        if let encoded = try? JSONEncoder().encode(drinks) {
            userDefaults.set(encoded, forKey: cachedDrinksKey)
            userDefaults.set(Date(), forKey: lastUpdateKey)
        }
    }
    
    /// Updates drinks from external source (e.g., Convex) and caches them
    func updateDrinks(_ newDrinks: [PopularDrinkData]) {
        print("📦 Updating drinks: \(newDrinks.count) drinks received")
        // Log a sample drink to verify data
        if let sampleDrink = newDrinks.first(where: { $0.name.contains("Coca") || $0.name.contains("Pepsi") || $0.name.contains("Kofola") }) {
            print("📦 Sample drink: \(sampleDrink.name) - Volume: \(sampleDrink.volume)ml")
        }
        
        drinks = newDrinks
        saveCachedDrinks()
        print("✅ Drinks updated and cached. Total: \(drinks.count)")
    }
    
    /// Clears the cache and reloads from built-in drinks
    /// Useful when you've updated built-in drinks and want to see them immediately
    func clearCacheAndReload() {
        userDefaults.removeObject(forKey: cachedDrinksKey)
        userDefaults.removeObject(forKey: lastUpdateKey)
        drinks = builtInDrinks
        saveCachedDrinks()
    }
    
    /// Checks if cache is expired
    var isCacheExpired: Bool {
        guard let lastUpdate = userDefaults.object(forKey: lastUpdateKey) as? Date else {
            return true
        }
        return Date().timeIntervalSince(lastUpdate) > cacheExpirationInterval
    }
    
    // MARK: - Built-in Fallback Drinks
    
    /// Built-in drinks that ship with the app (fallback when offline or no cache)
    private var builtInDrinks: [PopularDrinkData] {
        [
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
            .init(name: NSLocalizedString("Americano", comment: ""), imageName: "kafe", volume: 200, drinkType: .caffeine, caffeineContent: 71),
            .init(name: NSLocalizedString("Coca-Cola", comment: ""), imageName: "coca_cola", volume: 500, drinkType: .caffeine, caffeineContent: 48),
            .init(name: NSLocalizedString("Pepsi", comment: ""), imageName: "pepsi", volume: 500, drinkType: .caffeine, caffeineContent: 54),
            .init(name: NSLocalizedString("Kofola", comment: ""), imageName: "kofola", volume: 500, drinkType: .caffeine, caffeineContent: 75)
        ]
    }
    
    // MARK: - Convex Integration
    
    /// Fetches drinks from Convex backend (requires internet)
    /// Priority 1: Fresh Convex data (this function)
    /// Falls back to cached data if fetch fails (cached is priority 2)
    /// Built-in drinks are last resort (priority 3)
    func fetchDrinksFromConvex() async {
        // Only fetch if Convex is enabled
        guard ConvexConfig.isEnabled else {
            print("⚠️ Convex is disabled - using cached/built-in drinks")
            return
        }
        
        print("🔄 Fetching fresh data from Convex (Priority 1)...")
        
        #if canImport(ConvexMobile)
        guard let _ = URL(string: ConvexConfig.deploymentURL) else {
            print("❌ Invalid Convex deployment URL: \(ConvexConfig.deploymentURL)")
            return
        }
        
        // Create Convex client
        let client = ConvexClient(deploymentUrl: ConvexConfig.deploymentURL)
        
        do {
            print("🌐 Starting fetch from Convex...")
            
            // Subscribe to the query and get the first value
            let publisher = client.subscribe(to: "popularDrinks:getAllDrinks", yielding: [ConvexDrink].self)
                .replaceError(with: [])
                .values
            
            // Wait for the first result
            for await convexDrinks in publisher {
                print("🌐 Got data from Convex: \(convexDrinks.count) drinks")
                
                // If empty result (likely offline/error), fall back to cached or built-in
                if convexDrinks.isEmpty {
                    print("⚠️ Received empty result from Convex (likely offline)")
                    await fallbackToLocalData()
                    break
                }
                
                // Convert ConvexDrink to PopularDrinkData
                let convertedDrinks = convexDrinks.map { convexDrink in
                    PopularDrinkData(
                        id: UUID(),
                        name: convexDrink.name,
                        imageName: convexDrink.imageName,
                        volume: convexDrink.volume,
                        drinkType: convexDrink.drinkType == "alcohol" ? .alcohol : .caffeine,
                        alcoholPercentage: convexDrink.alcoholPercentage,
                        caffeineContent: convexDrink.caffeineContent
                    )
                }
                
                // Update drinks on main thread (Priority 1: Fresh Convex data)
                await MainActor.run {
                    print("✅ Successfully fetched \(convertedDrinks.count) drinks from Convex (Priority 1)")
                    self.updateDrinks(convertedDrinks)
                    // Force UI update
                    objectWillChange.send()
                }
                
                // Break after getting first result
                break
            }
        } catch {
            // Fetch failed - fall back to cached data (Priority 2)
            print("❌ Failed to fetch from Convex: \(error.localizedDescription)")
            await fallbackToLocalData()
        }
        #else
        print("⚠️ ConvexMobile package not found!")
        print("⚠️ Please add Convex Swift package in Xcode:")
        print("⚠️ File → Add Package Dependencies → https://github.com/get-convex/convex-swift")
        print("⚠️ Select ConvexMobile product")
        
        // Fall back to local data
        await fallbackToLocalData()
        #endif
    }
    
    /// Fallback to cached or built-in drinks when Convex fetch fails
    private func fallbackToLocalData() async {
        print("📦 Falling back to local data...")
        
        // Try to reload from cache (Priority 2)
        if let data = userDefaults.data(forKey: cachedDrinksKey),
           let decoded = try? JSONDecoder().decode([PopularDrinkData].self, from: data),
           !decoded.isEmpty {
            await MainActor.run {
                self.drinks = decoded
                print("✅ Using cached Convex data (Priority 2): \(decoded.count) drinks")
                objectWillChange.send()
            }
        } else {
            // No cache - use built-in (Priority 3)
            await MainActor.run {
                self.drinks = builtInDrinks
                self.saveCachedDrinks() // Cache the built-in drinks for next time
                print("✅ Using built-in drinks (Priority 3): \(builtInDrinks.count) drinks")
                objectWillChange.send()
            }
        }
    }
    
    /// Attempts to refresh drinks from Convex if cache is expired
    /// Priority: 1) Fresh Convex fetch, 2) Cached data, 3) Built-in
    func refreshIfNeeded() async {
        // Always try to fetch fresh data if Convex is enabled (best data source)
        if ConvexConfig.isEnabled {
            if alwaysFetchOnLaunch {
                print("🔄 Always fetch enabled - fetching fresh from Convex...")
                await fetchDrinksFromConvex()
            } else if isCacheExpired {
                print("🔄 Cache expired - fetching fresh from Convex...")
                await fetchDrinksFromConvex()
            } else {
                let lastUpdate = userDefaults.object(forKey: lastUpdateKey) as? Date
                let hoursSinceUpdate = lastUpdate.map { Date().timeIntervalSince($0) / 3600 } ?? 0
                print("✅ Using cached Convex data (updated \(String(format: "%.1f", hoursSinceUpdate)) hours ago)")
                print("💡 Pull down to refresh for latest data")
            }
        } else {
            print("ℹ️ Convex disabled - using built-in drinks")
        }
    }
    
    /// Force refresh from Convex (ignores cache, highest priority)
    func forceRefresh() async {
        print("🔄 Force refreshing from Convex (highest priority - ignoring cache)...")
        await fetchDrinksFromConvex()
    }
}


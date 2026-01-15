import { mutation } from "./_generated/server";

// Seed script to populate initial drinks data
// Run this once after setting up your Convex backend
export const seedDrinks = mutation({
  handler: async (ctx) => {
    const drinks = [
      // Alcohol
      {
        name: "Beer 10º",
        imageName: "gambrinus",
        volume: 500,
        drinkType: "alcohol" as const,
        alcoholPercentage: 4.1,
      },
      {
        name: "Beer 11º",
        imageName: "kozel",
        volume: 500,
        drinkType: "alcohol" as const,
        alcoholPercentage: 4.6,
      },
      {
        name: "Beer 12º",
        imageName: "radegast",
        volume: 500,
        drinkType: "alcohol" as const,
        alcoholPercentage: 5.1,
      },
      {
        name: "Wine Glass",
        imageName: "wine_glass",
        volume: 200,
        drinkType: "alcohol" as const,
        alcoholPercentage: 14.0,
      },
      {
        name: "Wine Bottle",
        imageName: "wine_bottle",
        volume: 750,
        drinkType: "alcohol" as const,
        alcoholPercentage: 14.0,
      },
      {
        name: "Vodka",
        imageName: "vodka",
        volume: 40,
        drinkType: "alcohol" as const,
        alcoholPercentage: 40.0,
      },
      {
        name: "Champagne",
        imageName: "champagne",
        volume: 150,
        drinkType: "alcohol" as const,
        alcoholPercentage: 11.0,
      },
      {
        name: "Cider",
        imageName: "cider",
        volume: 400,
        drinkType: "alcohol" as const,
        alcoholPercentage: 4.5,
      },
      {
        name: "Absinth",
        imageName: "absinth",
        volume: 40,
        drinkType: "alcohol" as const,
        alcoholPercentage: 70.0,
      },
      {
        name: "Gin Tonic",
        imageName: "gin_tonic",
        volume: 250,
        drinkType: "alcohol" as const,
        alcoholPercentage: 11.0,
      },
      {
        name: "Moscow Mule",
        imageName: "moscow_mule",
        volume: 200,
        drinkType: "alcohol" as const,
        alcoholPercentage: 10.0,
      },
      {
        name: "Cuba Libre",
        imageName: "cuba_libre",
        volume: 200,
        drinkType: "alcohol" as const,
        alcoholPercentage: 11.0,
      },
      {
        name: "Mojito",
        imageName: "mojito",
        volume: 250,
        drinkType: "alcohol" as const,
        alcoholPercentage: 9.0,
      },
      {
        name: "Whiskey",
        imageName: "whiskey",
        volume: 40,
        drinkType: "alcohol" as const,
        alcoholPercentage: 45.0,
      },
      {
        name: "Rum",
        imageName: "rum",
        volume: 40,
        drinkType: "alcohol" as const,
        alcoholPercentage: 40.0,
      },
      {
        name: "Green",
        imageName: "green",
        volume: 40,
        drinkType: "alcohol" as const,
        alcoholPercentage: 20.0,
      },
      {
        name: "Jägermeister",
        imageName: "jager",
        volume: 40,
        drinkType: "alcohol" as const,
        alcoholPercentage: 35.0,
      },
      {
        name: "B Lemond",
        imageName: "lemond",
        volume: 40,
        drinkType: "alcohol" as const,
        alcoholPercentage: 20.0,
      },
      // Caffeine
      {
        name: "Red Bull",
        imageName: "red_bull",
        volume: 250,
        drinkType: "caffeine" as const,
        caffeineContent: 80,
      },
      {
        name: "Monster",
        imageName: "monster",
        volume: 500,
        drinkType: "caffeine" as const,
        caffeineContent: 160,
      },
      {
        name: "Monster Ultra",
        imageName: "monster_ultra",
        volume: 500,
        drinkType: "caffeine" as const,
        caffeineContent: 150,
      },
      {
        name: "Crazy Wolf",
        imageName: "crazy_wolf",
        volume: 500,
        drinkType: "caffeine" as const,
        caffeineContent: 150,
      },
      {
        name: "Tiger",
        imageName: "tiger",
        volume: 250,
        drinkType: "caffeine" as const,
        caffeineContent: 80,
      },
      {
        name: "Rockstar",
        imageName: "rockstar",
        volume: 500,
        drinkType: "caffeine" as const,
        caffeineContent: 160,
      },
      {
        name: "Big Shock",
        imageName: "big_shock",
        volume: 500,
        drinkType: "caffeine" as const,
        caffeineContent: 160,
      },
      {
        name: "Espresso",
        imageName: "espresso",
        volume: 30,
        drinkType: "caffeine" as const,
        caffeineContent: 70,
      },
      {
        name: "Double Espresso",
        imageName: "double_espresso",
        volume: 60,
        drinkType: "caffeine" as const,
        caffeineContent: 140,
      },
      {
        name: "Cappuccino",
        imageName: "cappuccino",
        volume: 170,
        drinkType: "caffeine" as const,
        caffeineContent: 70,
      },
      {
        name: "Caffe Latte",
        imageName: "latte",
        volume: 220,
        drinkType: "caffeine" as const,
        caffeineContent: 70,
      },
      {
        name: "Flat White",
        imageName: "flat_white",
        volume: 170,
        drinkType: "caffeine" as const,
        caffeineContent: 100,
      },
      {
        name: "Green Tea",
        imageName: "greeen",
        volume: 300,
        drinkType: "caffeine" as const,
        caffeineContent: 40,
      },
      {
        name: "Black Tea",
        imageName: "black",
        volume: 300,
        drinkType: "caffeine" as const,
        caffeineContent: 70,
      },
      {
        name: "Americano",
        imageName: "kafe",
        volume: 200,
        drinkType: "caffeine" as const,
        caffeineContent: 71,
      },
      {
        name: "Coca-Cola",
        imageName: "coca_cola",
        volume: 500,
        drinkType: "caffeine" as const,
        caffeineContent: 48,
      },
      {
        name: "Pepsi",
        imageName: "pepsi",
        volume: 500,
        drinkType: "caffeine" as const,
        caffeineContent: 54,
      },
      {
        name: "Kofola",
        imageName: "kofola",
        volume: 500,
        drinkType: "caffeine" as const,
        caffeineContent: 75,
      },
    ];

    const now = Date.now();
    const insertedIds = [];
    const updatedIds = [];

    for (const drink of drinks) {
      // Check if drink already exists by name
      const existingDrink = await ctx.db
        .query("popularDrinks")
        .withIndex("by_name", (q) => q.eq("name", drink.name))
        .first();

      if (existingDrink) {
        // Update existing drink
        await ctx.db.patch(existingDrink._id, {
          ...drink,
          updatedAt: now,
          // Preserve original createdAt
          createdAt: existingDrink.createdAt,
        });
        updatedIds.push(existingDrink._id);
      } else {
        // Insert new drink
        const id = await ctx.db.insert("popularDrinks", {
          ...drink,
          createdAt: now,
          updatedAt: now,
        });
        insertedIds.push(id);
      }
    }

    return {
      success: true,
      inserted: insertedIds.length,
      updated: updatedIds.length,
      total: drinks.length,
      insertedIds,
      updatedIds,
    };
  },
});

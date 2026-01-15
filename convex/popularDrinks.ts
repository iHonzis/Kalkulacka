import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

// Query to get all popular drinks
export const getAllDrinks = query({
  handler: async (ctx) => {
    const drinks = await ctx.db.query("popularDrinks").collect();
    // Log for debugging
    const cocaCola = drinks.find(d => d.name === "Coca-Cola");
    if (cocaCola) {
      console.log(`🔍 Convex getAllDrinks: Coca-Cola volume = ${cocaCola.volume}ml`);
    }
    return drinks;
  },
});

// Test query to get a specific drink by name (for debugging)
export const getDrinkByName = query({
  args: {
    name: v.string(),
  },
  handler: async (ctx, args) => {
    const drink = await ctx.db
      .query("popularDrinks")
      .withIndex("by_name", (q) => q.eq("name", args.name))
      .first();
    if (drink) {
      console.log(`🔍 Convex getDrinkByName: ${drink.name} volume = ${drink.volume}ml`);
    }
    return drink;
  },
});

// Query to get drinks filtered by type
export const getDrinksByType = query({
  args: {
    drinkType: v.union(v.literal("alcohol"), v.literal("caffeine")),
  },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("popularDrinks")
      .withIndex("by_drinkType", (q) => q.eq("drinkType", args.drinkType))
      .collect();
  },
});

// Mutation to add a new drink (for admin/management)
export const addDrink = mutation({
  args: {
    name: v.string(),
    imageName: v.string(),
    volume: v.number(),
    drinkType: v.union(v.literal("alcohol"), v.literal("caffeine")),
    alcoholPercentage: v.optional(v.number()),
    caffeineContent: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const now = Date.now();
    return await ctx.db.insert("popularDrinks", {
      name: args.name,
      imageName: args.imageName,
      volume: args.volume,
      drinkType: args.drinkType,
      alcoholPercentage: args.alcoholPercentage,
      caffeineContent: args.caffeineContent,
      createdAt: now,
      updatedAt: now,
    });
  },
});

// Mutation to update an existing drink by name
export const updateDrinkByName = mutation({
  args: {
    name: v.string(),
    imageName: v.optional(v.string()),
    volume: v.optional(v.number()),
    drinkType: v.optional(v.union(v.literal("alcohol"), v.literal("caffeine"))),
    alcoholPercentage: v.optional(v.number()),
    caffeineContent: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    // Find drink by name
    const existingDrink = await ctx.db
      .query("popularDrinks")
      .withIndex("by_name", (q) => q.eq("name", args.name))
      .first();

    if (!existingDrink) {
      throw new Error(`Drink "${args.name}" not found`);
    }

    // Update only provided fields
    const updates: any = {
      updatedAt: Date.now(),
    };

    if (args.imageName !== undefined) updates.imageName = args.imageName;
    if (args.volume !== undefined) updates.volume = args.volume;
    if (args.drinkType !== undefined) updates.drinkType = args.drinkType;
    if (args.alcoholPercentage !== undefined) updates.alcoholPercentage = args.alcoholPercentage;
    if (args.caffeineContent !== undefined) updates.caffeineContent = args.caffeineContent;

    await ctx.db.patch(existingDrink._id, updates);
    return { success: true, id: existingDrink._id };
  },
});

// Mutation to update a drink by ID
export const updateDrinkById = mutation({
  args: {
    id: v.id("popularDrinks"),
    imageName: v.optional(v.string()),
    volume: v.optional(v.number()),
    drinkType: v.optional(v.union(v.literal("alcohol"), v.literal("caffeine"))),
    alcoholPercentage: v.optional(v.number()),
    caffeineContent: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const updates: any = {
      updatedAt: Date.now(),
    };

    if (args.imageName !== undefined) updates.imageName = args.imageName;
    if (args.volume !== undefined) updates.volume = args.volume;
    if (args.drinkType !== undefined) updates.drinkType = args.drinkType;
    if (args.alcoholPercentage !== undefined) updates.alcoholPercentage = args.alcoholPercentage;
    if (args.caffeineContent !== undefined) updates.caffeineContent = args.caffeineContent;

    await ctx.db.patch(args.id, updates);
    return { success: true, id: args.id };
  },
});

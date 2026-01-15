import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  popularDrinks: defineTable({
    name: v.string(),
    imageName: v.string(),
    volume: v.number(), // in ml
    drinkType: v.union(v.literal("alcohol"), v.literal("caffeine")),
    alcoholPercentage: v.optional(v.number()), // in %
    caffeineContent: v.optional(v.number()), // in mg
    // Metadata
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_drinkType", ["drinkType"])
    .index("by_name", ["name"]),
});

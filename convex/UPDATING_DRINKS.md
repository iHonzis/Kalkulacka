# How to Update Drinks in Convex Database

## Why Seed Script Doesn't Update Automatically

The `seed.ts` script was originally designed to **insert** new drinks only. If you change a value in `seed.ts` and run it again, it would try to insert duplicates.

**I've now updated `seed.ts` to handle updates!** It will:
- Update existing drinks if they have the same name
- Insert new drinks if they don't exist

## Methods to Update Drinks

### Method 1: Update seed.ts and Re-run (Easiest)

1. **Edit `convex/seed.ts`** - Change the volume (or any property) of the drink
2. **Run the seed mutation again**:
   ```bash
   npx convex run seed:seedDrinks
   ```
   Or in Convex Dashboard → Functions → `seed:seedDrinks` → Run

3. **The script will now**:
   - Update existing drinks with matching names
   - Insert new drinks that don't exist
   - Return counts of updated vs inserted drinks

### Method 2: Use Update Mutation (For Single Drinks)

1. **In Convex Dashboard**:
   - Go to Functions tab
   - Find `popularDrinks:updateDrinkByName`
   - Click "Run"
   - Enter the drink name and new values:
   ```json
   {
     "name": "Coca-Cola",
     "volume": 600
   }
   ```

2. **Or via CLI**:
   ```bash
   npx convex run popularDrinks:updateDrinkByName '{"name": "Coca-Cola", "volume": 600}'
   ```

### Method 3: Update via Convex Dashboard UI

1. Go to Convex Dashboard
2. Navigate to "Data" tab
3. Find the `popularDrinks` table
4. Click on the drink you want to update
5. Edit the fields directly
6. Save

### Method 4: Update by ID

If you know the drink's ID:
```bash
npx convex run popularDrinks:updateDrinkById '{"id": "YOUR_DRINK_ID", "volume": 600}'
```

## After Updating in Convex

Once you update a drink in Convex:

1. **The app will fetch the update** when:
   - Cache expires (24 hours)
   - App is restarted and cache is expired
   - You force refresh (if you implement that feature)

2. **To see changes immediately**:
   - Clear app cache (delete and reinstall app)
   - Or wait for cache to expire
   - Or implement a pull-to-refresh feature

## Example: Updating Coca-Cola Volume

### Step 1: Update in seed.ts
```typescript
{
  name: "Coca-Cola",
  imageName: "coca_cola",
  volume: 600,  // Changed from 500
  drinkType: "caffeine" as const,
  caffeineContent: 48,
}
```

### Step 2: Run seed mutation
```bash
npx convex run seed:seedDrinks
```

### Step 3: Check result
You should see:
```json
{
  "success": true,
  "inserted": 0,
  "updated": 1,
  "total": 36
}
```

### Step 4: Verify in Dashboard
- Go to Data → `popularDrinks`
- Find "Coca-Cola"
- Verify volume is now 600

### Step 5: Test in App
- Clear app cache or wait for cache expiration
- Launch app
- Check if Coca-Cola shows 600ml

## Troubleshooting

### Changes not appearing in app?

1. **Check Convex Dashboard**: Verify the drink was actually updated
2. **Check app cache**: The app caches drinks for 24 hours
3. **Clear cache**: Delete and reinstall the app
4. **Check console**: Look for fetch errors

### Seed script creating duplicates?

- The updated seed script now checks for existing drinks by name
- It will update instead of inserting duplicates
- If you still see duplicates, check if drink names match exactly (case-sensitive)

### Want to update multiple drinks?

- Edit `seed.ts` with all your changes
- Run `seedDrinks` mutation once
- It will update all matching drinks and insert any new ones

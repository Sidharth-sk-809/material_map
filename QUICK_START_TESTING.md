# Quick Start Guide - Testing Material Map Updates

## Pre-Flight Checklist

- ✅ Firebase initialized with google-services.json
- ✅ Real Firebase Auth enabled
- ✅ Location permissions configured (Android + iOS)
- ✅ All 24 products in mock data
- ✅ Category Items Screen fully implemented
- ✅ Location-based distance calculations working
- ✅ 0 compilation errors

---

## 🚀 Running the App

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Run in debug mode
flutter run

# Or on specific device
flutter run -d <device_id>
```

---

## 📝 Test Scenarios

### Test 1: Login & Authentication
1. **Expected**: Splash screen → Login screen
2. **Action**: Enter email/password and tap Login/Register
3. **Verify**:
   - [ ] Real Firebase authentication works
   - [ ] Successful login navigates to Home
   - [ ] Error messages show for invalid credentials
   - [ ] Logout button in Home screen top-right

### Test 2: Home Screen Location
1. **Expected**: Location detection on app launch
2. **Action**: Allow location permission when prompted
3. **Verify**:
   - [ ] Location chip shows "📍 Detecting location..." → "📍 Near you"
   - [ ] Search bar appears
   - [ ] 6 category cards visible (Grocery, Vegetables, Stationery, etc.)
   - [ ] Nearby Deals section shows sample products

### Test 3: Category Navigation
1. **Expected**: Tap Grocery category
2. **Action**: Tap any category card
3. **Verify**:
   - [ ] Routes to CategoryItemsScreen
   - [ ] Category name + icon in header
   - [ ] Location banner with detection status
   - [ ] Grid of products (2 columns)
   - [ ] Each product shows emoji/image + name + unit + top-3 prices
   - [ ] Stores sorted by distance (if location available)

### Test 4: Product Details
1. **Expected**: Tap a product card
2. **Action**: Tap any product in category grid
3. **Verify**:
   - [ ] Routes to ProductDetailScreen
   - [ ] Product image/emoji displays
   - [ ] Full inventory list appears
   - [ ] Back button returns to category

### Test 5: Location & Distance
1. **Expected**: Distance shown on store prices
2. **Verify**:
   - [ ] Store distances calculated correctly (Haversine formula)
   - [ ] Format shows "km" or "m" appropriately
   - [ ] Stores sorted by closest distance first
   - [ ] Mock stores: Fresh Mart, Super Save, Big Bazaar, Daily Needs, Value Mart (Erode area)

### Test 6: Search Functionality
1. **Expected**: Search bar navigates to SearchScreen
2. **Action**: Tap search bar
3. **Verify**:
   - [ ] SearchScreen opens
   - [ ] Can search by product name
   - [ ] Category filter works
   - [ ] Mock data shows in results

---

## 🛠️ Troubleshooting

### Location Permission Denied
**Issue**: Location banner shows "Permission denied"
**Solution**:
- Go to phone Settings → Material Map → Permissions → Location → Allow
- Restart app
- Verification: Should see "📍 Near you" after restart

### Images Not Showing
**Issue**: Products show emoji instead of images
**Solution**: This is expected! Images need to be generated with Gemini API
- See `IMAGE_GENERATION_GUIDE.md` for instructions
- Emoji fallbacks are intentional and work fine
- Once images are generated and placed in `assets/images/products/`, they'll load

### Firebase Auth Issues
**Issue**: Login always fails or throws error
**Solution**:
- Verify google-services.json exists in `android/app/`
- Check Firebase Console → Authentication → Users
- Ensure Email/Password provider is enabled
- Try with test credentials first

### Compilation Errors
**Issue**: Flutter analyze shows errors
**Solution**:
```bash
flutter clean
flutter pub get
flutter analyze
```

---

## 📊 Test Data Summary

### Categories (6)
1. 🛒 **Grocery** - Rice, Oil, Atta, Dal, Sugar, Salt
2. 🥦 **Vegetables** - Tomato, Potato, Onion, Carrot, Broccoli, Capsicum
3. 📝 **Stationery** - Notebook, Pen, Pencils, Stapler, Eraser, Ruler
4. 🏠 **Household** - Detergent, Dish Soap, Paper Towels, Trash Bags
5. 🔧 **Plumbing** - Faucet, Wrench, PVC Pipe, Teflon Tape
6. 💡 **Electronics** - LED Bulb, Extension Cord, USB Charger, Batteries

### Mock Stores (5 - Erode, TN)
- Fresh Mart: 11.3415°N, 77.7171°E
- Super Save: 11.3380°N, 77.7250°E
- Big Bazaar: 11.3500°N, 77.7100°E
- Daily Needs: 11.3310°N, 77.7180°E
- Value Mart: 11.3450°N, 77.7300°E

### Sample Prices
- **Tomato** (500g): ₹28 (Fresh Mart) → ₹32 (Super Save) → ₹35 (Big Bazaar)
- **Notebook** (200p): ₹35 (Fresh Mart) → ₹38 (Super Save) → ₹42 (Big Bazaar)
- **LED Bulb** (9W): ₹75 (Fresh Mart) → ₹82 (Super Save) → ₹90 (Big Bazaar)

---

## ✨ New Features to Test

### Feature 1: Real Firebase Auth
- Test complete login/register flow
- Verify auth persistence across app restarts
- Check logout functionality

### Feature 2: Category Items Grid
- Browse categories
- See product prices from different stores
- Visual grid layout (2 columns)
- Product images (currently emojis)

### Feature 3: Location-Based Pricing
- Location detection on app launch
- Distance calculations for each store
- Stores sorted by nearest first
- Distance shown on product cards

### Feature 4: Reusable Product Widget
- ProductItemCard used throughout
- Consistent product display
- Tap-to-detail navigation
- Price and distance display

---

## 🎯 Performance Considerations

- **Mock Data**: ~24 products, 5 stores, 72 inventory items (instant loading)
- **Location**: Detects on app init, ~3-5 second permission prompt
- **Images**: Currently emojis (instant), generated images ~50-200KB each
- **Distance Calc**: Haversine formula (negligible impact)

---

## 📋 Checklist for Production

- [ ] Test on Android device
- [ ] Test on iOS device  
- [ ] Verify Firebase Auth with real project
- [ ] Generate 24 product images with Gemini API
- [ ] Update imageUrl in search_provider.dart
- [ ] Test location on actual GPS hardware
- [ ] Verify location in different cities
- [ ] Test offline behavior
- [ ] Check battery impact of location tracking
- [ ] Deploy to TestFlight/Internal Testing

---

## 📚 Documentation

- **IMPLEMENTATION_SUMMARY.md** - Complete implementation details
- **IMAGE_GENERATION_GUIDE.md** - How to generate product images

---

## 💬 Questions?

### Q: Do I need to generate images?
**A**: No! The app works perfectly with emoji fallbacks right now. Images are optional for better UX but not required for functionality.

### Q: Can I use real Firestore data?
**A**: Yes! The app is designed to fetch from Firestore. Currently uses mock data as fallback. Update `product_repository.dart` to enable Firestore.

### Q: How long does location detection take?
**A**: ~3-5 seconds for permission prompt, then immediate GPS fix. Works offline with last known location.

### Q: What if images fail to load?
**A**: Built-in emoji fallback ensures UI never breaks. Clear Asset loading errors show in console.

---

**Happy Testing! 🚀**

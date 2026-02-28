# Product Image Generation Guide

This document outlines the product images needed for Material Map.

## Image Requirements

- **Format**: PNG with transparency (recommended)
- **Size**: 200x200 pixels (will be used in grid layout)
- **Quality**: High-quality, clean product shots
- **Style**: Consistent with each other, slightly stylized/illustrated look

## Products by Category (24 total images)

### 🛒 Grocery (6 items)
- `rice_bag.png` - Jasmine Rice bag
- `cooking_oil.png` - Cooking Oil bottle
- `sugar.png` - Sugar bag
- `atta_flour.png` - Whole Wheat Atta bag
- `dal_lentils.png` - Toor Dal package
- `salt.png` - Salt container

### 🥦 Vegetables (6 items)
- `tomato.png` - Red Tomato
- `potato.png` - Brown Potato
- `onion.png` - Yellow Onion
- `carrot.png` - Orange Carrot
- `broccoli.png` - Fresh Broccoli
- `capsicum.png` - Green Capsicum/Bell Pepper

### 📝 Stationery (6 items)
- `notebook.png` - Spiral/Classmate Notebook
- `ballpoint_pen.png` - Reynolds Ballpoint Pen
- `pencils.png` - Drawing Pencils set
- `stapler.png` - Metal Stapler
- `eraser.png` - Pink Eraser
- `ruler.png` - Plastic Ruler

### 🏠 Household (4 items)
- `liquid_detergent.png` - Surf Excel or similar
- `dish_soap.png` - Vim Dish Soap bottle
- `paper_towels.png` - Paper towels roll
- `trash_bags.png` - Trash bags box

### 🔧 Plumbing (4 items)
- `chrome_faucet.png` - Chrome Water Faucet
- `adjustable_wrench.png` - Metal Adjustable Wrench
- `pvc_pipe.png` - PVC Pipe
- `teflon_tape.png` - Teflon Tape roll

### 💡 Electronics (4 items)
- `led_bulb.png` - LED Bulb (9W)
- `extension_cord.png` - Power Extension Cord
- `usb_charger.png` - USB-C Charger
- `battery_pack.png` - AA Batteries pack

## How to Generate with Gemini

### Using Google Cloud Vertex AI (Python)
```python
import vertexai
from vertexai.generative_models import GenerativeModel
import base64

vertexai.init(project="YOUR_PROJECT_ID", location="us-central1")
model = GenerativeModel("gemini-2.0-flash", system_instruction="...")

response = model.generate_content([
    "Generate a product image of a tomato",
    # The response should contain image data
])
```

### Using Gemini API (REST)
See https://ai.google.dev/tutorials/image_generation

### Alternative: Use Built-in Emoji Fallback
Currently, the app uses Unicode emojis as fallbacks. Products will display fine without images:
- 🍅 Tomato
- 🥔 Potato
- 📒 Notebook
- etc.

The `ProductItemCard` widget automatically falls back to emojis if `imageUrl` is empty.

## File Placement

Place all generated images in:
```
assets/images/products/
├── grocery/
│   ├── rice_bag.png
│   ├── cooking_oil.png
│   └── ...
├── vegetables/
│   ├── tomato.png
│   ├── potato.png
│   └── ...
├── stationery/
│   ├── notebook.png
│   └── ...
├── household/
│   ├── liquid_detergent.png
│   └── ...
├── plumbing/
│   ├── chrome_faucet.png
│   └── ...
└── electronics/
    ├── led_bulb.png
    └── ...
```

## Update ProductModel.imageUrl

After generating images, update the mock data in `search_provider.dart`:

```dart
ProductModel(
  id: 'v1',
  name: 'Tomato',
  brand: 'Fresh Farm',
  category: 'vegetables',
  imageUrl: 'assets/images/products/vegetables/tomato.png', // ← Add this
  unit: '500 g'
),
```

## Current Status

- ✅ App structure supports images (will fall back to emojis)
- ✅ Product cards configured to load from `imageUrl`
- ⏳ Images to be generated via Gemini API
- ⏳ Update product URLs after generation

## Notes

- If image generation quota is limited, generate in batches (one category at a time)
- Emoji fallbacks ensure UI never breaks while generating images
- Consider caching generated images to avoid regeneration
- All 24 images provide visual consistency and better UX

# Background Color Selection Feature

## Overview
Users can now select a custom background color from a curated color palette in the Settings screen.

## Implementation Details

### 1. **Color Palette** (`BackgroundColors` class)
- 14 predefined colors including:
  - **Neutrals**: White, Light Grey
  - **Blues**: Light Blue, Sky Blue, Medium Blue, Bright Blue
  - **Greens**: Light Green, Soft Green
  - **Oranges**: Light Orange, Peach
  - **Purples**: Light Purple, Lavender
  - **Pinks**: Light Pink, Soft Pink

### 2. **State Management** (`BackgroundController`)
- `customBackgroundColor` property (nullable)
- `setCustomBackgroundColor(Color?)` method
- `clearCustomColor()` method to reset to theme default
- Notifies listeners when color changes

### 3. **UI Integration** (`AppScaffold`)
- If custom color is set:
  - **Solid style**: Uses custom color directly
  - **Gradient style**: Creates a subtle gradient from the custom color
- If no custom color: Uses theme default colors

### 4. **Settings UI** (`_ColorPalette` widget)
Features:
- Grid display of 14 color swatches
- Visual feedback (border + check icon) for selected color
- Color name display
- "Reset" button to clear custom color
- Shows "Using theme default" when no custom color

## User Flow
1. Go to **Settings** → **Appearance**
2. Select a **Background Style** (Solid/Gradient)
3. Choose a color from the **Background Color** palette
4. See live preview throughout the app
5. Click **Reset** to return to theme default

## Technical Notes
- Custom colors work with **all themes** (Calm Light, Calm Dark, Emerald, Indigo)
- When gradient style is used with custom color, creates dynamic gradient:
  - Lighter shade (30% blend with white)
  - Darker shade (10% blend with black)
- No persistence yet (in-memory only)
- Colors are accessibility-conscious (sufficient contrast)

## Next Steps (Future Enhancements)
- [ ] Persist color selection using SharedPreferences
- [ ] Add more color options
- [ ] Support custom hex color input
- [ ] Preview color before applying


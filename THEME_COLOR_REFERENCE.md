# 🎨 THEME COLOR REFERENCE GUIDE

## 3-Layer System Visual Guide

### Light Mode (Calm Neutral Light)

```
┌─────────────────────────────────────────┐
│  appBackground: #F7F7F7 (soft grey)     │  ← App Canvas
│  ┌───────────────────────────────────┐  │
│  │ surface: #FAFAFA (lighter)        │  │  ← Section Container
│  │  ┌─────────────────────────────┐  │  │
│  │  │ card: #FFFFFF (pure white)  │  │  │  ← Content Card (most elevated)
│  │  │                             │  │  │
│  │  │  [Icon] Document Title      │  │  │
│  │  │  Added 2 days ago           │  │  │
│  │  │                             │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Dark Mode (Calm Neutral Dark)

```
┌─────────────────────────────────────────┐
│  appBackground: #0F0F0F (charcoal)      │  ← App Canvas
│  ┌───────────────────────────────────┐  │
│  │ surface: #1A1A1A (elevated)      │  │  ← Section Container
│  │  ┌─────────────────────────────┐  │  │
│  │  │ card: #232323 (most elev.)  │  │  │  ← Content Card (lightest in dark)
│  │  │                             │  │  │
│  │  │  [Icon] Document Title      │  │  │
│  │  │  Added 2 days ago           │  │  │
│  │  │                             │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

---

## Complete Color Palette

### LIGHT MODE (Calm Neutral Light)

#### Core Surfaces
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `appBackground` | `#F7F7F7` | `247, 247, 247` | App canvas (full screen) |
| `surface` | `#FAFAFA` | `250, 250, 250` | Section containers |
| `card` | `#FFFFFF` | `255, 255, 255` | Content cards (most elevated) |
| `surfaceContainer` | `#F0F0F0` | `240, 240, 240` | Alternative containers |

#### Brand Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `primary` | `#1976D2` | `25, 118, 210` | Primary actions, links |
| `primaryContainer` | `#BBDEFB` | `187, 222, 251` | Primary backgrounds |
| `onPrimary` | `#FFFFFF` | `255, 255, 255` | Text on primary |
| `secondary` | `#424242` | `66, 66, 66` | Secondary actions |

#### Text Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `textPrimary` | `#1F1F1F` | `31, 31, 31` | Headlines, body text |
| `textSecondary` | `#6B6B6B` | `107, 107, 107` | Captions, muted text |

#### UI Elements
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `border` | `#E8E8E8` | `232, 232, 232` | Borders, outlines |
| `divider` | `#E8E8E8` | `232, 232, 232` | Dividing lines |
| `iconBackground` | `#E3F2FD` | `227, 242, 253` | Icon containers (10% primary) |

#### Semantic Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `success` | `#4CAF50` | `76, 175, 80` | Success states |
| `successLight` | `#C8E6C9` | `200, 230, 201` | Success backgrounds |
| `warning` | `#FFA726` | `255, 167, 38` | Warning states |
| `warningLight` | `#FFE0B2` | `255, 224, 178` | Warning backgrounds |
| `danger` | `#EF5350` | `239, 83, 80` | Error/danger states |
| `dangerLight` | `#FFCDD2` | `255, 205, 210` | Error backgrounds |
| `info` | `#2196F3` | `33, 150, 243` | Info states |
| `infoLight` | `#BBDEFB` | `187, 222, 251` | Info backgrounds |

---

### DARK MODE (Calm Neutral Dark)

#### Core Surfaces
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `appBackground` | `#0F0F0F` | `15, 15, 15` | App canvas (deep charcoal) |
| `surface` | `#1A1A1A` | `26, 26, 26` | Section containers (elevated) |
| `card` | `#232323` | `35, 35, 35` | Content cards (most elevated) |
| `surfaceContainer` | `#2A2A2A` | `42, 42, 42` | Alternative containers |

#### Brand Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `primary` | `#64B5F6` | `100, 181, 246` | Primary actions (lighter for dark) |
| `primaryContainer` | `#1565C0` | `21, 101, 192` | Primary backgrounds (darker) |
| `onPrimary` | `#000000` | `0, 0, 0` | Text on primary (black for lighter primary) |
| `secondary` | `#B0BEC5` | `176, 190, 197` | Secondary actions |

#### Text Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `textPrimary` | `#E8E8E8` | `232, 232, 232` | Headlines, body (NOT pure white) |
| `textSecondary` | `#9E9E9E` | `158, 158, 158` | Captions, muted text |

#### UI Elements
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `border` | `#3A3A3A` | `58, 58, 58` | Borders (softer in dark) |
| `divider` | `#3A3A3A` | `58, 58, 58` | Dividing lines |
| `iconBackground` | `#1E3A5F` | `30, 58, 95` | Icon containers (12% primary, darker) |

#### Semantic Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `success` | `#66BB6A` | `102, 187, 106` | Success states (lighter) |
| `successLight` | `#2E7D32` | `46, 125, 50` | Success backgrounds (darker) |
| `warning` | `#FFB74D` | `255, 183, 77` | Warning states (lighter) |
| `warningLight` | `#F57C00` | `245, 124, 0` | Warning backgrounds (darker) |
| `danger` | `#EF5350` | `239, 83, 80` | Error states (same as light) |
| `dangerLight` | `#C62828` | `198, 40, 40` | Error backgrounds (darker) |
| `info` | `#42A5F5` | `66, 165, 245` | Info states (lighter) |
| `infoLight` | `#1565C0` | `21, 101, 192` | Info backgrounds (darker) |

---

## Gradient Colors

### Light Mode Gradients
- `backgroundGradientStart`: `#FAFAFA` (lighter)
- `backgroundGradientEnd`: `#F4F4F4` (slightly darker)

### Dark Mode Gradients
- `backgroundGradientStart`: `#1A1A1A` (lighter)
- `backgroundGradientEnd`: `#0A0A0A` (darker, almost black)

---

## Icon Badge Colors (Domain-Specific)

### Light Mode
| Domain | Color | Hex | RGB |
|--------|-------|-----|-----|
| Blue (Identity) | Light Blue | `#E3F2FD` | `227, 242, 253` |
| Green (Vehicles) | Light Green | `#E8F5E9` | `232, 245, 233` |
| Orange (Property) | Light Orange | `#FFF3E0` | `255, 243, 224` |
| Purple (Banking) | Light Purple | `#F3E5F5` | `243, 229, 245` |
| Red (Insurance) | Light Red | `#FFEBEE` | `255, 235, 238` |
| Grey (General) | Light Grey | `#F5F5F5` | `245, 245, 245` |

### Dark Mode
| Domain | Color | Hex | RGB |
|--------|-------|-----|-----|
| Blue (Identity) | Deep Blue | `#1A237E` | `26, 35, 126` |
| Green (Vehicles) | Deep Green | `#1B5E20` | `27, 94, 32` |
| Orange (Property) | Deep Orange | `#E65100` | `230, 81, 0` |
| Purple (Banking) | Deep Purple | `#4A148C` | `74, 20, 140` |
| Red (Insurance) | Deep Red | `#B71C1C` | `183, 28, 28` |
| Grey (General) | Dark Grey | `#424242` | `66, 66, 66` |

---

## Usage Examples

### Accessing Colors in Code

```dart
// Get semantic colors
final colors = AppThemeProvider.colorsOf(context);

// Use semantic tokens
Container(
  color: colors.appBackground,  // App canvas
  child: Card(
    color: colors.card,          // Content card (auto from theme)
    child: Container(
      decoration: BoxDecoration(
        color: colors.iconBackground,  // Icon container
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.home,
        color: colors.primary,
      ),
    ),
  ),
)
```

### Theme-Aware Text

```dart
Text(
  'Primary Text',
  style: TextStyle(color: colors.textPrimary),  // Auto adapts to theme
)

Text(
  'Secondary Text',
  style: TextStyle(color: colors.textSecondary),  // Auto adapts to theme
)
```

---

## Design Principles

### Light Mode
- **NOT pure white** - Soft grey (#F7F7F7) reduces eye strain
- **Clear elevation** - Cards pop against grey background
- **Warm tones** - Slightly warm greys for comfortable reading
- **High contrast** - Dark text on light backgrounds

### Dark Mode
- **NOT pure black** - Charcoal (#0F0F0F) is easier on eyes
- **Elevation through lightness** - Lighter = more elevated
- **Reduced contrast** - Light grey text (#E8E8E8), not pure white
- **Subtle color shifts** - Accent colors are lighter for visibility

### Both Modes
- **Consistent spacing** - Same layout in both themes
- **Clear hierarchy** - 3 distinct surface layers
- **Accessible contrast** - WCAG AA compliant
- **Semantic tokens** - Colors have meaning, not just aesthetics

---

## Testing Color Accessibility

All color combinations meet WCAG 2.1 Level AA standards:
- **Normal text**: 4.5:1 contrast ratio minimum
- **Large text**: 3:1 contrast ratio minimum
- **UI components**: 3:1 contrast ratio minimum

Use tools like [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/) to verify custom colors.


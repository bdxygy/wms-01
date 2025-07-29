# Development Guidelines

## Business Rules

- Products must have unique barcodes within owner scope
- SALE transactions require at least one product item and photo proof
- All data is owner-scoped (non-OWNER roles see data from same owner only)
- Soft delete for audit trail

## Code Standards

- **DRY & KISS**: Avoid duplication, keep solutions simple
- **Type Safety**: Use Zod schemas, typed models throughout
- **Security**: Never expose secrets/keys, validate all inputs
- **Testing**: Test at controller layer via HTTP endpoints
- **ID Generation**: `randomUUID()` for DB primary keys, `nanoid()` for barcodes only
- **🛡️ GUARD CLAUSES MANDATORY**: Always use guard clauses instead of nested if statements
- **🎨 MODERN DESIGN MANDATORY**: All UI must follow modern design principles
- **📝 SINGLE-STEP FORMS ONLY**: Multi-step forms are strictly prohibited
- **🌐 INTERNATIONALIZATION MANDATORY**: All user-facing text must use i18n

## 🛡️ Guard Clause Patterns

**MANDATORY**: All new code must use guard clauses instead of nested if statements.

### Required Guard Clause Patterns:

```dart
// ✅ CORRECT: Early return validation
Future<void> saveData() async {
  if (!isValid) return;
  if (!hasPermission) return;
  if (!mounted) return;
  
  // Main logic here
}

// ❌ WRONG: Nested if statements
Future<void> saveData() async {
  if (isValid) {
    if (hasPermission) {
      if (mounted) {
        // Main logic here
      }
    }
  }
}
```

### Benefits of Guard Clauses:
- **Reduced cognitive load**: Less nesting, easier to read
- **Early validation**: Fail fast pattern
- **Cleaner code**: Eliminate deeply nested if statements
- **Better error handling**: Clear validation boundaries
- **Improved maintainability**: Easier to modify and debug

## 📱 Responsive UI Patterns

**MANDATORY**: All widgets must be responsive and handle text/content overflow gracefully.

### Required Responsive Patterns:

```dart
// ✅ CORRECT: Use Flexible/Expanded for Row/Column children
Row(
  children: [
    Flexible(
      child: Text('Label', overflow: TextOverflow.ellipsis),
    ),
    Expanded(
      child: Text('Long content', overflow: TextOverflow.ellipsis),
    ),
  ],
)

// ❌ WRONG: Row/Column without Flexible/Expanded
Row(
  children: [
    Text('Label'),
    Text('Very long content'), // Will overflow
  ],
)
```

### Responsive UI Requirements:
- **Always use `Flexible` or `Expanded`** for Row/Column children that contain text
- **Always add `overflow: TextOverflow.ellipsis`** for text that might be long
- **Use `SingleChildScrollView`** for content that might exceed screen height
- **Test on different screen sizes** - mobile, tablet, and desktop
- **Handle edge cases** - very long product names, UUIDs, currency amounts

## 📱 Mobile Device Compatibility

**Target Device Specifications:**
- **Reference Device**: 168.6 x 76.6 x 9 mm (6.64 x 3.02 x 0.35 in)
- **Screen Width**: ~76.6mm (~375-390px logical pixels)
- **Usable Height**: ~150mm (~700-800px logical pixels after system UI)

### Mobile Design Requirements:
- **Text Breaking**: NO text overflow - use `TextOverflow.ellipsis` and `maxLines`
- **Button Positioning**: Minimum 44x44 logical pixels touch targets
- **Content Spacing**: Minimum 16px margins, 8-24px between sections
- **Scrollable Content**: Always use `SingleChildScrollView` for forms
- **Responsive Widgets**: All components must adapt to narrow screen widths
- **Safe Area**: Respect device safe areas with `SafeArea` widget
- **Portrait Orientation**: Primary design for portrait mode (76.6mm width)

## 🎨 Modern Design Standards

**MANDATORY**: All user interface designs must follow modern design principles.

### Modern Design Requirements:
- **Material Design 3**: Use latest Material Design principles
- **Clean Visual Hierarchy**: Clear typography scales, consistent spacing
- **Contemporary Color Palette**: Modern color schemes with proper contrast
- **Subtle Animations**: Smooth transitions and micro-interactions
- **Card-Based Layout**: Use cards with rounded corners and subtle shadows
- **Icon Integration**: Consistent icon usage with proper sizing

### Visual Design Patterns:
- **Section Headers**: Always include icons with titles and subtitles
- **Form Styling**: Rounded input fields with clear labels
- **Button Design**: Elevated primary, outlined secondary, text tertiary
- **Color Usage**: Primary for actions, neutral grays for content
- **Typography**: Consistent font weights, proper line heights
- **Spacing System**: 8px grid with 16px base margins

## 📝 Single-Step Form Policy

**MANDATORY**: All forms must be single-step forms. Multi-step forms are prohibited.

### Form Design Requirements:
- **Single Scrollable Layout**: All form fields in one continuous interface
- **Logical Grouping**: Group related fields using section headers
- **Progressive Disclosure**: Use collapsible sections or conditional fields
- **Clear Validation**: Real-time field validation with immediate feedback
- **Streamlined Navigation**: Single Save/Submit button at bottom

### Benefits of Single-Step Forms:
- **Reduced Friction**: Users see all requirements upfront
- **Better Mobile Experience**: Optimal for touch interfaces
- **Faster Completion**: No navigation between steps
- **Improved Validation**: Immediate feedback on all fields
- **Enhanced Accessibility**: Better screen reader support

## 🌐 Internationalization Requirements

**MANDATORY**: All user-facing text must use AppLocalizations. Hardcoded strings are prohibited.

### i18n Implementation Requirements:

```dart
// ✅ CORRECT: Using AppLocalizations
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Text(l10n.productName);
  return AppBar(title: Text(l10n.products));
  return ElevatedButton(
    onPressed: () {},
    child: Text(l10n.save),
  );
}

// ❌ WRONG: Hardcoded strings
Widget build(BuildContext context) {
  return Text('Product Name'); // FORBIDDEN
  return AppBar(title: Text('Products')); // FORBIDDEN
}
```

### Text Localization Rules:
- **All UI Text**: Buttons, labels, titles, descriptions, error messages
- **Dynamic Content**: Form validation messages, status text, notifications  
- **Accessibility**: Screen reader content, tooltips, semantic labels
- **Placeholders**: Input hints, loading messages, empty states
- **Error Handling**: Exception messages, network errors, validation feedback

### Translation Key Organization:
- Follow `screenName_elementType_description` naming convention
- Use common keys for repeated text across screens
- Maintain alphabetical order within each screen section
- Include context comments for translators in .arb files

## 📱 Global AppBar System Requirements

**MANDATORY**: All screens must use the WMSAppBar component. Custom AppBar implementations are prohibited.

### WMSAppBar Implementation:

```dart
// ✅ CORRECT: Using WMSAppBar
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: WMSAppBar(
      icon: Icons.inventory_2,
      title: 'Product Details',
      badge: product.isImei ? WMSAppBarBadge.imei(Theme.of(context)) : null,
      shareConfig: WMSAppBarShare(onShare: _shareProduct),
      printConfig: WMSAppBarPrint.barcode(
        onPrint: _printBarcode,
        onManagePrinter: _managePrinter,
      ),
      menuItems: [
        WMSAppBarMenuItem.delete(onTap: _deleteProduct),
      ],
    ),
    body: _buildBody(),
  );
}
```

### WMSAppBar Configuration Components:
- **WMSAppBarBadge**: Status indicators (IMEI, Active, Pending, Completed)
- **WMSAppBarShare**: Share functionality with onShare callback
- **WMSAppBarPrint**: Print system (barcode, receipt, or both)
- **WMSAppBarMenuItem**: Custom menu items with factory methods

### Available Badge Types:
- `WMSAppBarBadge.imei(theme)` - Orange IMEI indicator
- `WMSAppBarBadge.active(theme)` - Green active status
- `WMSAppBarBadge.inactive(theme)` - Red inactive status
- `WMSAppBarBadge.pending(theme)` - Orange pending status
- `WMSAppBarBadge.completed(theme)` - Green completed status

### Print System Integration:
- `WMSAppBarPrint.barcode()` - Barcode printing only (Owner/Admin roles)
- `WMSAppBarPrint.receipt()` - Receipt printing only (Owner/Admin/Cashier roles)
- `WMSAppBarPrint.both()` - Both barcode and receipt printing (role-dependent)
- **Role-Based Visibility**: Print buttons automatically hidden for unauthorized roles

## 🚫 Critical Database Model Protection

**NEVER MODIFY** these files without explicit user request:
- `src/models/users.ts`, `src/models/stores.ts`, `src/models/categories.ts`
- `src/models/products.ts`, `src/models/transactions.ts`
- `src/models/product_checks.ts`, `src/models/product_imeis.ts`

## API Response Standards

- **ALWAYS use `ResponseUtils`** from `src/utils/responses.ts`
- **ALWAYS use Zod schemas** for validation
- **Required format**: `BaseResponse<T>` or `PaginatedResponse<T>`
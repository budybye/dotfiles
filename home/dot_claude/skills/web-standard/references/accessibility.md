# Web Accessibility Reference

## WCAG Principles (POUR)

### Perceivable
- Text alternatives for non-text content
- Captions for audio content
- Adaptable content presentation
- Distinguishable content (contrast, color)

### Operable
- Keyboard accessible
- Enough time to read and use
- Seizures and physical reactions
- Navigable interface

### Understandable
- Readable text content
- Predictable interface
- Input assistance

### Robust
- Compatible with current and future user tools

## ARIA (Accessible Rich Internet Applications)

### Landmark Roles
- `role="banner"` - Site header
- `role="navigation"` - Navigation sections
- `role="main"` - Primary content
- `role="complementary"` - Supporting content
- `role="contentinfo"` - Page footer

### State and Property Attributes
- `aria-label` - Accessible name
- `aria-labelledby` - ID reference to label
- `aria-describedby` - ID reference to description
- `aria-hidden` - Remove element from accessibility tree
- `aria-expanded` - Indicate expanded/collapsed state

### Live Regions
- `aria-live="polite"` - Announce updates
- `aria-live="assertive"` - Immediate announcements
- `aria-atomic` - Treat region as whole unit
- `aria-relevant` - What changes should be announced

## Semantic HTML for Accessibility

### Headings
- Proper heading hierarchy (h1-h6)
- One h1 per page
- No skipped heading levels

### Links
- Descriptive link text
- Unique link text in context
- Visible focus indicators

### Forms
- Label all form controls
- Group related controls with fieldset/legend
- Provide clear error identification and suggestions

### Images
- Informative images need alt text
- Decorative images use empty alt=""
- Complex images need long descriptions

## Keyboard Navigation

### Focus Management
- Logical tab order
- Visible focus indicators
- Skip navigation links
- Focus trapping in modals

### Keyboard Interactions
- Space/Enter for buttons
- Arrow keys for radio groups
- Escape to close modals
- Tab for form fields

## Screen Reader Testing

### Common Screen Readers
- NVDA (Windows)
- JAWS (Windows)
- VoiceOver (macOS/iOS)
- TalkBack (Android)

### Testing Techniques
- Navigate with keyboard only
- Listen to screen reader announcements
- Verify landmark navigation
- Check form labeling

## Color and Contrast

### Minimum Contrast Ratios
- 4.5:1 for normal text
- 3:1 for large text
- 3:1 for graphics and UI components

### Color Independence
- Don't rely on color alone to convey information
- Use text labels or patterns
- Test with color blindness simulators

## Mobile Accessibility

### Touch Targets
- Minimum 44x44 pixels
- Adequate spacing between targets
- Consistent positioning

### Gestures
- Support standard gestures
- Provide alternatives for complex gestures
- Clear gesture instructions
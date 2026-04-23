# CSS3 Features Reference

## Layout

### Flexbox
- `display: flex` - Establishes flex container
- `flex-direction` - Direction of flex items
- `justify-content` - Alignment along main axis
- `align-items` - Alignment along cross axis
- `flex-wrap` - Whether items wrap to new lines

### Grid
- `display: grid` - Establishes grid container
- `grid-template-columns/rows` - Define grid tracks
- `grid-column/row` - Item placement
- `gap` - Spacing between grid cells

## Values and Units

### New Units
- `rem` - Root em (relative to root font size)
- `vw/vh` - Viewport width/height percentage
- `vmin/vmax` - Viewport minimum/maximum

### Functional Notation
- `calc()` - Mathematical expressions
- `min()/max()/clamp()` - Value constraints

## Visual Effects

### Transforms
- `transform` - Rotate, scale, skew, translate elements
- `transform-origin` - Point around which transforms occur

### Transitions
- `transition` - Smooth property changes
- `transition-duration` - Length of transition
- `transition-timing-function` - Acceleration curve

### Animations
- `@keyframes` - Define animation sequences
- `animation` - Apply animations to elements

## Selectors

### Attribute Selectors
- `[attr^=value]` - Attribute begins with value
- `[attr$=value]` - Attribute ends with value
- `[attr*=value]` - Attribute contains value

### Pseudo-classes
- `:nth-child()` - Select by position
- `:not()` - Negation pseudo-class
- `:focus-within` - Element or descendant has focus

## Media Queries

### Level 4 Features
- `width: calc(100vw - 2em)` - Calculated dimensions
- `hover` - Hover capability detection
- `pointer` - Pointer accuracy detection

## Variables (Custom Properties)

```css
:root {
  --main-color: #0057a8;
  --spacing-unit: 1rem;
}

.component {
  color: var(--main-color);
  margin: var(--spacing-unit);
}
```

## Feature Queries

```css
@supports (display: grid) {
  .container {
    display: grid;
  }
}

@supports not (display: grid) {
  .container {
    display: flex;
  }
}
```
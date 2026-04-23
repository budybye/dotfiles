# Responsive Design Reference

## Core Principles

### Mobile-First Approach
- Start with smallest screen designs
- Progressively enhance for larger screens
- Focus on essential content and features
- Optimize performance for mobile devices

### Flexible Grid Systems
- Relative units (%, em, rem, vw, vh)
- CSS Grid and Flexbox layouts
- Component-based design
- Content-out approach

### Media Queries

#### Breakpoint Strategy
```css
/* Small devices (landscape phones, 576px and up) */
@media (min-width: 576px) { }

/* Medium devices (tablets, 768px and up) */
@media (min-width: 768px) { }

/* Large devices (desktops, 992px and up) */
@media (min-width: 992px) { }

/* Extra large devices (large desktops, 1200px and up) */
@media (min-width: 1200px) { }
```

#### Modern Media Queries
```css
/* Hover capability */
@media (hover: hover) { }

/* Pointer accuracy */
@media (pointer: fine) { }

/* Orientation */
@media (orientation: landscape) { }
```

## Fluid Typography

### CSS Lock Technique
```css
h1 {
  font-size: 1.5rem; /* Minimum size */
}

@media (min-width: 30rem) {
  h1 {
    font-size: calc(1.5rem + ((1vw - 0.3rem) * 1.72));
  }
}

@media (min-width: 60rem) {
  h1 {
    font-size: 2.5rem; /* Maximum size */
  }
}
```

### Clamp Function
```css
h1 {
  font-size: clamp(1.5rem, 4vw, 2.5rem);
}
```

## Flexible Images and Media

### Responsive Images
```html
<!-- Different sizes for different screen widths -->
<img srcset="small.jpg 480w, medium.jpg 800w, large.jpg 1200w"
     sizes="(max-width: 480px) 100vw, (max-width: 800px) 50vw, 25vw"
     src="medium.jpg" alt="Description">

<!-- Different resolutions for high-density displays -->
<img srcset="image-1x.jpg 1x, image-2x.jpg 2x" 
     src="image-1x.jpg" alt="Description">
```

### Art Direction
```html
<picture>
  <source media="(min-width: 800px)" srcset="large.jpg">
  <source media="(min-width: 400px)" srcset="medium.jpg">
  <img src="small.jpg" alt="Description">
</picture>
```

### Intrinsic Ratio Boxes
```css
.aspect-ratio-box {
  position: relative;
  width: 100%;
  padding-bottom: 56.25%; /* 16:9 Aspect Ratio */
}

.aspect-ratio-box-content {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}
```

## Touch Interface Design

### Touch Target Sizes
- Minimum 44x44 pixels for interactive elements
- Adequate spacing between touch targets
- Consistent positioning across views

### Gesture Support
- Standard gestures (tap, swipe, pinch)
- Custom gesture documentation
- Feedback for gesture actions

### Input Modes
```html
<!-- Numeric keypad for phone numbers -->
<input type="tel" inputmode="tel">

<!-- Email keyboard -->
<input type="email" inputmode="email">

<!-- Numeric keyboard -->
<input type="number" inputmode="numeric">
```

## Navigation Patterns

### Hamburger Menus
- Clear labeling
- Smooth animations
- Keyboard accessibility
- Focus management

### Tab Bars
- Persistent navigation
- Limited to 5 main destinations
- Active state indication
- Touch-friendly targets

### Mega Menus
- Organized content grouping
- Search within menu
- Scrollable sections
- Keyboard navigation

## Form Design

### Adaptive Forms
- Vertical layout on small screens
- Horizontal layout on large screens
- Appropriate input sizing
- Clear error messaging

### Input Enhancement
```html
<!-- Auto-complete suggestions -->
<input type="text" autocomplete="name">

<!-- Spellcheck control -->
<textarea spellcheck="false"></textarea>

<!-- Auto-capitalization -->
<input type="text" autocapitalize="words">
```

## Performance Considerations

### Conditional Loading
```css
/* Load different resources based on screen size */
@media (min-width: 768px) {
  .hero {
    background-image: url('large-hero.jpg');
  }
}

@media (max-width: 767px) {
  .hero {
    background-image: url('small-hero.jpg');
  }
}
```

### Lazy Loading
```html
<!-- Images -->
<img data-src="image.jpg" class="lazy" alt="Description">

<!-- iframes -->
<iframe data-src="embed.html" class="lazy"></iframe>
```

## Testing Strategies

### Device Testing
- Physical device testing
- Browser developer tools
- Online device emulators
- Real user monitoring

### Breakpoint Testing
- Content-centric breakpoints
- Component-level testing
- Edge case scenarios
- Orientation changes

### Performance Testing
- Mobile network simulation
- Loading performance metrics
- Rendering performance
- Battery impact assessment

## Emerging Patterns

### Container Queries
```css
.card {
  container-type: inline-size;
}

@container (min-width: 400px) {
  .card-content {
    display: grid;
    grid-template-columns: 1fr 1fr;
  }
}
```

### Dynamic Viewport Units
- `dvh` - Dynamic viewport height
- `svh` - Small viewport height
- `lvh` - Large viewport height

### CSS Anchor Positioning
```css
.tooltip {
  anchor-name: --trigger;
}

.popup {
  position-anchor: --trigger;
  position-area: bottom;
}
```
# Web Performance Reference

## Core Metrics

### Loading Metrics
- **First Contentful Paint (FCP)** - Time to first text/image
- **Largest Contentful Paint (LCP)** - Time to main content
- **Speed Index** - How quickly content is visually populated
- **Time to Interactive (TTI)** - Time to fully interactive

### Rendering Metrics
- **First Meaningful Paint (FMP)** - Time to primary content
- **First CPU Idle** - Time to initial interactivity

### Layout Stability
- **Cumulative Layout Shift (CLS)** - Visual stability metric

## Optimization Strategies

### Resource Loading
- **Preloading** - `rel="preload"` for critical resources
- **Prefetching** - `rel="prefetch"` for likely next resources
- **Preconnecting** - `rel="preconnect"` for third-party origins
- **DNS Prefetching** - `rel="dns-prefetch"` for domain resolution

### Code Splitting
- Bundle splitting by route
- Dynamic imports for lazy loading
- Tree shaking unused code
- Minification and compression

### Image Optimization
- Modern formats (WebP, AVIF)
- Responsive images with srcset
- Proper sizing and aspect ratios
- Lazy loading with loading="lazy"

### Critical Rendering Path
- Inline critical CSS
- Defer non-critical JavaScript
- Optimize CSS delivery
- Minimize render-blocking resources

## Network Optimization

### Compression
- Gzip/Brotli compression
- Text compression for HTML/CSS/JS
- Image compression without quality loss

### Caching
- HTTP caching headers
- Service worker caching
- CDN distribution
- Cache invalidation strategies

### Resource Hints
```html
<link rel="preload" href="critical.css" as="style">
<link rel="prefetch" href="next-page.html">
<link rel="preconnect" href="https://fonts.googleapis.com">
```

## JavaScript Performance

### Efficient DOM Manipulation
- Batch DOM reads and writes
- Use DocumentFragment for multiple elements
- Avoid forced synchronous layouts
- Use CSS transforms instead of changing layout properties

### Event Handling
- Event delegation for multiple elements
- Debouncing and throttling event handlers
- Removing unused event listeners
- Passive event listeners for scroll/touch

### Memory Management
- Avoid memory leaks
- Remove event listeners properly
- Nullify references to detached DOM nodes
- Monitor memory usage with DevTools

## CSS Performance

### Selector Efficiency
- Avoid expensive selectors (descendant, child, adjacent)
- Use class selectors primarily
- Limit selector depth
- Use ID selectors sparingly

### Layout Optimization
- Avoid layout thrashing
- Use transform and opacity for animations
- Minimize reflows and repaints
- Use contain property for isolated components

### Containment
```css
.component {
  contain: layout style paint;
}
```

## Monitoring and Measurement

### Web Vitals
- Core Web Vitals dashboard
- Field data vs lab data
- Real User Monitoring (RUM)
- Synthetic monitoring

### Performance Budgets
- Asset size limits
- Request count limits
- Time-based budgets
- Metric-based thresholds

### Tools
- Lighthouse for audits
- Chrome DevTools Performance panel
- WebPageTest for detailed analysis
- PageSpeed Insights for quick checks
# HTML5 Semantic Elements

## Core Semantic Elements

### Document Structure
- `<header>` - Introductory content or navigational aids
- `<nav>` - Navigation links
- `<main>` - Dominant content of the document
- `<article>` - Self-contained composition
- `<section>` - Generic section of a document
- `<aside>` - Content tangentially related to the content
- `<footer>` - Footer for its nearest ancestor sectioning content

### Text Content
- `<figure>` - Self-contained content (images, diagrams, code listings)
- `<figcaption>` - Caption or legend for a figure
- `<details>` - Disclosure widget
- `<summary>` - Summary, caption, or legend for details
- `<mark>` - Highlighted text
- `<time>` - Machine-readable time/date

## Best Practices

1. Use semantic elements to describe content meaning, not just for styling
2. Maintain proper document outline with heading hierarchy (h1-h6)
3. Ensure accessibility with appropriate ARIA roles when needed
4. Validate HTML markup regularly
5. Test with screen readers and assistive technologies

## Browser Support

All modern browsers support HTML5 semantic elements. For IE8 and below, include html5shiv:

```html
<!--[if lt IE 9]>
<script src="https://cdnjs.cloudflare.com/ajax/libs/html5shiv/3.7.3/html5shiv.min.js"></script>
<![endif]-->
```
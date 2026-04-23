# Format — Reference File Organization

## Directory Structure

Organize reference files in a consistent structure:

```
/references/
  ├── tech-stack/
  │   ├── frontend/
  │   ├── backend/
  │   ├── database/
  │   └── infrastructure/
  ├── libraries/
  │   ├── category-1/
  │   ├── category-2/
  │   └── category-3/
  ├── frameworks/
  │   ├── frontend/
  │   ├── backend/
  │   └── full-stack/
  └── comparisons/
      ├── [technology-a]-vs-[technology-b].md
      └── stack-combinations/
```

## File Naming Conventions

Use descriptive, consistent naming:

- **Libraries**: `library-name.md`
- **Frameworks**: `framework-name.md`
- **Comparisons**: `technology-a-vs-technology-b.md`
- **Stacks**: `frontend-backend-database.md`
- **Categories**: `category-overview.md`

## Content Structure

Each reference file should include:

1. **Header**: Technology name and brief description
2. **Overview**: What it is and primary use cases
3. **Key Features**: Bullet-point list of main capabilities
4. **Installation**: Standard installation commands
5. **Basic Usage**: Minimal working example
6. **Configuration**: Common options and settings
7. **Best Practices**: Recommended approaches
8. **Common Pitfalls**: Issues to avoid
9. **Resources**: Links to documentation and community

## Metadata Format

Include frontmatter for easy parsing and categorization:

```yaml
---
name: Technology Name
category: [frontend, backend, database, etc.]
type: [library, framework, tool]
license: MIT, Apache 2.0, etc.
stars: GitHub star count (approximate)
last_updated: YYYY-MM-DD
maintained: true/false
tags: [tag1, tag2, tag3]
compatibility: [node, python, java, etc.]
---
```

## Comparison Files

Structure comparison files to highlight differences:

```markdown
# Technology A vs Technology B

## Quick Summary
Brief comparison highlighting the main differences.

## Detailed Comparison

### Performance
| Metric | Technology A | Technology B |
|--------|--------------|--------------|
| Speed | Value | Value |
| Memory | Value | Value |

### Features
| Feature | Technology A | Technology B |
|---------|--------------|--------------|
| Feature 1 | ✓/✗ | ✓/✗ |
| Feature 2 | ✓/✗ | ✓/✗ |

### Ecosystem
- Technology A: [Description of ecosystem]
- Technology B: [Description of ecosystem]

### Learning Curve
- Technology A: [Difficulty level and reasons]
- Technology B: [Difficulty level and reasons]

## Recommendations
When to choose each technology based on specific criteria.
```

## Version Tracking

Track technology versions and update dates:

```markdown
## Version Information
- Current version: vX.Y.Z (as of YYYY-MM-DD)
- Release notes: [Link to changelog]
- Breaking changes: [List if applicable]
- Migration guide: [Link if available]
```

## Link Format

Use consistent link formatting:

- **Official Documentation**: [Official Documentation](https://...)
- **API Reference**: [API Reference](https://...)
- **GitHub Repository**: [Repository](https://...)
- **NPM/Yarn**: [Package](https://...)

## Update Frequency

Reference files should be updated:

- When major versions are released
- When significant changes occur in the technology
- When new best practices emerge
- At least annually for active projects
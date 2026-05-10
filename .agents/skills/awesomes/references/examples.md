# Examples — Implementation Templates

## Minimal Implementation Template

When evaluating a library or framework, use this structure for consistent comparisons:

```javascript
// package.json or equivalent dependency declaration
{
  "name": "technology-evaluation-example",
  "version": "1.0.0",
  "dependencies": {
    // List evaluated technology and minimal dependencies
  }
}

// Basic usage example
import Technology from 'technology-name';

// Initialize with default configuration
const instance = new Technology({
  // Minimal required configuration
});

// Demonstrate core functionality
const result = instance.coreMethod(input);
console.log(result);

// Error handling example
try {
  const riskyResult = instance.riskyMethod(input);
} catch (error) {
  console.error('Expected error handling pattern:', error.message);
}
```

## Comparison Matrix Template

Document evaluation results in a structured format:

| Feature/Criteria | Technology A | Technology B | Technology C |
|------------------|--------------|--------------|--------------|
| Installation ease | ★★★☆☆ | ★★★★☆ | ★★☆☆☆ |
| Documentation quality | ★★★★☆ | ★★★☆☆ | ★★★★★ |
| Performance (relative) | Fast | Medium | Slow |
| Community size | Large | Medium | Small |
| Learning curve | Steep | Moderate | Gentle |
| Customization | High | Medium | Low |

## Reference File Template

Structure reference files consistently for easy consumption:

```markdown
# Technology Name

## Overview
Brief description of what this technology does and its primary use cases.

## Key Features
- Feature 1
- Feature 2
- Feature 3

## Installation
```bash
# Standard installation command
npm install technology-name
```

## Basic Usage
```javascript
// Minimal working example
import Technology from 'technology-name';

const instance = new Technology();
const result = instance.doSomething();
```

## Configuration Options
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| option1 | boolean | true | Description of what this option does |
| option2 | string | "default" | Another configurable option |

## Best Practices
- Practice 1
- Practice 2
- Practice 3

## Common Pitfalls
- Pitfall 1 and how to avoid it
- Pitfall 2 and solution

## Resources
- [Official Documentation](link)
- [API Reference](link)
- [Community Forum](link)
```

## Architecture Combination Template

When recommending technology combinations:

```markdown
# Recommended Stack: Frontend + Backend + Database

## Architecture Diagram
[Simple ASCII or Mermaid diagram showing component interactions]

## Component Breakdown

### Frontend: [Technology]
- Role: User interface and client-side logic
- Strengths: [List key advantages]
- Integration points: [How it connects to other components]

### Backend: [Technology]
- Role: Server-side logic and API layer
- Strengths: [List key advantages]
- Integration points: [How it connects to other components]

### Database: [Technology]
- Role: Data persistence and querying
- Strengths: [List key advantages]
- Integration points: [How it connects to other components]

## Data Flow
1. User interacts with frontend
2. Frontend makes API request to backend
3. Backend processes request and queries database
4. Database returns data to backend
5. Backend sends response to frontend
6. Frontend updates UI

## Setup Instructions
[Step-by-step setup for the entire stack]
```

## Evaluation Scenario Template

Document specific use cases for evaluation:

```markdown
## Scenario: [Descriptive name]

### Description
Brief description of the use case being evaluated.

### Requirements
1. [critical] Requirement 1
2. [critical] Requirement 2
3. Nice-to-have requirement 3

### Expected Outcome
What a successful implementation would achieve.

### Test Implementation
[Code snippet or steps to test this scenario]
```
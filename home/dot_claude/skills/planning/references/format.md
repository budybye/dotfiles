# Plan Format Specification

All implementation plans must follow this structure:

## Context Section

**Purpose**: Explain the background and problem to be solved

**Required elements**:
- Clear problem statement
- Business/user motivation
- Scope boundaries
- Success criteria

**Format**:
```
### Context

[2-4 paragraphs explaining the background, problem, and objectives]
```

## Approach Section

**Purpose**: Present the recommended solution and justification

**Required elements**:
- Brief overview of the chosen approach
- Why this approach was selected over alternatives
- Key benefits and tradeoffs
- Alignment with project goals/architecture

**Format**:
```
### Approach

[Explanation of the recommended approach with rationale]
```

## Steps Section

**Purpose**: Provide a concrete, actionable implementation plan

**Required elements**:
- Numbered list of steps
- Each step must be a single, clear action with specific file targets
- File names/paths for each modification using full paths
- Brief description of what each step accomplishes
- Steps should be independently executable by a developer

**Format**:
```
### Steps

1. [Action description] in `[file/path]`
2. [Action description] in `[file/path]`
...
```

**Guidelines**:
- Avoid vague steps like "Update the authentication module" - instead specify "Add login endpoint in `src/routes/auth.js`"
- Each step should contain exactly one actionable item
- Include verification steps where appropriate
- Order steps logically to ensure successful implementation

## Risks Section

**Purpose**: Identify potential issues and mitigation strategies

**Required elements**:
- Specific risks related to the implementation
- Likelihood and impact assessment
- Mitigation or contingency plans
- Monitoring/validation approaches

**Format**:
```
### Risks

- **[Risk description]**: [Likelihood/impact] - Mitigation: [strategy]
- **[Risk description]**: [Likelihood/impact] - Mitigation: [strategy]
...
```

## Overall Requirements

- Use markdown formatting consistently
- Keep language clear and actionable
- Include specific file paths where relevant
- Balance detail with conciseness
- Focus on implementation, not design theory
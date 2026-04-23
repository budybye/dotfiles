# Planning Methodology

## Phase 1: Requirements Analysis

Extract the core requirements from the user's request:

- What exactly needs to be implemented/changed?
- What are the success criteria?
- Are there any constraints or limitations?
- What is explicitly out of scope?

Ask clarifying questions if needed, but don't over-engineer.

## Phase 2: Codebase Survey

Use Read, Grep, and Glob tools to understand the existing codebase:

- Locate relevant files and modules
- Understand the current architecture
- Identify where changes will need to be made
- Note any existing patterns or conventions

Focus on files that will likely be impacted by the implementation.

## Phase 3: Approach Design

Design 2-3 different approaches to solve the problem:

- **Conservative approach**: Minimal changes, follows existing patterns
- **Balanced approach**: Moderate changes, some improvements
- **Progressive approach**: More extensive changes, potentially better long-term

For each approach, consider:
- Implementation complexity
- Risk level
- Maintenance implications
- Performance impact

## Phase 4: Step-by-Step Plan

Break down the chosen approach into concrete steps:

- Each step should be a single, clear action
- Specify which files need to be modified/created
- Indicate the order of operations
- Include verification steps where appropriate

## Phase 5: Risk Assessment

Identify potential issues with the plan:

- Technical risks (dependencies, compatibility, etc.)
- Integration risks (how changes might affect other parts)
- Deployment risks (migration, rollback, etc.)
- Maintenance risks (complexity, documentation, etc.)

Provide mitigation strategies for each identified risk.
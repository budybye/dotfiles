# Extended Planning Methodology

## Phase 1: Requirements Analysis - Deep Dive

When analyzing requirements, focus on these key aspects:

### Problem Definition
- Clearly articulate the core problem to be solved
- Distinguish between symptoms and root causes
- Identify stakeholders and their specific needs
- Document any constraints or limitations

### Scope Boundaries
- Explicitly define what is in scope
- Clearly state what is out of scope
- Identify potential scope creep areas
- Define success criteria and acceptance conditions

### Technical Context
- Understand existing system architecture
- Identify integration points and dependencies
- Assess current technology stack and limitations
- Note any relevant business rules or regulations

## Phase 2: Codebase Survey - Strategic Approach

Conduct a targeted survey focusing on impact areas:

### Architecture Understanding
- Identify relevant modules and components
- Understand data flow and dependencies
- Locate similar functionality for pattern reference
- Note existing abstractions and extension points

### Impact Assessment
- Map out files that will need modification
- Identify potential ripple effects
- Assess testing coverage in affected areas
- Note any technical debt or legacy concerns

### Pattern Recognition
- Observe existing coding patterns and conventions
- Identify reusable components or utilities
- Note any anti-patterns to avoid
- Understand error handling and logging approaches

## Phase 3: Approach Design - Comparative Analysis

Design multiple approaches with clear evaluation criteria:

### Approach Framework
For each approach, document:
- Core concept and implementation strategy
- Required changes to existing codebase
- Resource requirements (time, complexity, risk)
- Long-term maintenance implications

### Tradeoff Evaluation
Compare approaches across dimensions:
- **Complexity**: Implementation difficulty and cognitive load
- **Risk**: Potential for bugs, breaking changes, or performance issues
- **Maintainability**: Long-term ease of updates and modifications
- **Performance**: Impact on system speed and resource usage
- **Extensibility**: Ability to accommodate future enhancements

### Stakeholder Considerations
- Team familiarity with required technologies
- Alignment with organizational standards and practices
- Impact on development velocity during implementation
- Training or onboarding implications

## Phase 4: Step-by-Step Plan - Execution Focus

Create a detailed implementation plan optimized for execution:

### Granularity Principles
- Each step should represent 1-4 hours of focused work
- Steps should have clear completion criteria
- Dependencies between steps should be explicit
- Include both implementation and verification activities

### Quality Assurance Integration
- Identify testing requirements for each step
- Plan for code review checkpoints
- Consider rollback strategies for high-risk changes
- Document validation approaches for critical functionality

### Progress Tracking
- Define measurable milestones
- Identify quick wins for early momentum
- Plan for integration testing points
- Anticipate demonstration opportunities

## Phase 5: Risk Assessment - Proactive Management

Develop comprehensive risk mitigation strategies:

### Technical Risks
- Dependency conflicts or compatibility issues
- Performance degradation or resource exhaustion
- Data integrity or migration concerns
- Security vulnerabilities or compliance gaps

### Project Risks
- Timeline delays or resource constraints
- Knowledge transfer or team availability issues
- Integration challenges with external systems
- Changing requirements or scope creep

### Mitigation Strategies
For each identified risk, specify:
- Prevention measures to reduce likelihood
- Detection mechanisms for early warning
- Response procedures for when risks materialize
- Contingency plans for critical scenarios

## Continuous Improvement

After plan execution, capture lessons learned:

### Retrospective Questions
- Which estimates were accurate/inaccurate and why?
- What unexpected challenges arose?
- Which approaches proved most effective?
- What would you do differently next time?

### Knowledge Transfer
- Document any architectural decisions made during implementation
- Update team guidelines based on new insights
- Share patterns or solutions that could be reused
- Identify areas for future refactoring or improvement
# Methodology — Research Workflow

## Phase 0 — Define Scope and Criteria

Before starting research, clearly define:

- **Problem domain**: What specific problem are you solving?
- **Technical requirements**: Performance, scalability, compatibility needs
- **Evaluation criteria**: 
  - [critical] Community support and activity
  - [critical] Documentation quality
  - [critical] License compatibility
  - Maintenance frequency
  - Learning curve
  - Integration complexity
  - Ecosystem maturity

## Phase 1 — Search and Curate

Search relevant awesome lists and repositories:

- Start with sindresorhus/awesome as the master index
- Identify domain-specific awesome lists
- Look for recent additions and trending repositories
- Check for duplicates and forks across lists

Curate candidates based on:
- Star count and recent activity
- Description relevance to your problem domain
- Ecosystem compatibility with your stack

## Phase 2 — Evaluation

Evaluate each candidate against defined criteria:

**Primary evaluation axes**:
- **Community Health**: Issues response time, PR merge frequency, contributor diversity
- **Documentation**: Completeness, examples quality, API reference clarity
- **Performance**: Benchmarks, resource usage, scalability characteristics
- **Compatibility**: Integration with existing tools, migration paths
- **Maintenance**: Release frequency, backward compatibility policy

**Secondary evaluation axes**:
- **Learning Curve**: Time to basic proficiency, tutorial availability
- **Flexibility**: Customization options, plugin architecture
- **Security**: Vulnerability disclosure process, security audit history

## Phase 3 — Implementation

For top 2-3 candidates, implement minimal examples:

- Set up basic "Hello World" implementations
- Test core functionality relevant to your use case
- Measure setup complexity and initial configuration
- Identify potential integration challenges

Implementation guidelines:
- Use standard project structures for each technology
- Document setup steps and dependencies
- Note any deviations from official documentation
- Record initial impressions and surprises

## Phase 4 — Reference Creation

Create structured reference files containing:

- Technology overview and key features
- Installation and setup instructions
- Basic usage examples
- Configuration options and best practices
- Common pitfalls and solutions
- Links to essential documentation

Reference file formats: see [references/format.md](format.md)

## Phase 5 — Recommendation

Provide a clear recommendation based on:

- How well each candidate meets critical criteria
- Trade-offs between options
- Long-term maintenance considerations
- Team familiarity and learning investment

Include:
- Ranked list of recommendations
- Justification for top choice
- Alternative options for specific scenarios
- Migration strategy if replacing existing technology

## Phase 6 — Validation (if needed)

For high-stakes decisions, validate with:

- Small prototype implementation
- Performance testing under expected load
- Security scanning
- Integration testing with existing systems

## Stopping Criteria

**Complete** when:
- Clear recommendation is identified
- Reference materials are created
- Implementation examples validate the choice
- Risks and mitigation strategies are documented

**Revisit** when:
- New major versions are released
- Significant changes in project requirements
- Community sentiment shifts dramatically
- Integration issues arise in production

## Common Failures

- **Analysis paralysis**: Too much research without making decisions
- **Premature commitment**: Choosing based on limited information
- **Ignoring ecosystem**: Focusing only on the library, not its dependencies
- **Overlooking maintenance**: Choosing unmaintained or abandoned projects
- **Underestimating integration**: Assuming compatibility without testing

## Extended Red Flags

| Rationalization | Reality |
|----------------|---------|
| "Let's evaluate every option in the list." | Exhaustive evaluation wastes time. Focus on top candidates. |
| "We can customize any library to fit our needs." | Extensive customization increases maintenance burden. |
| "Performance doesn't matter for this use case." | Premature optimization is evil, but known bottlenecks aren't. |
| "We'll deal with integration later." | Integration challenges often make or break technology choices. |
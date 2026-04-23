# XDG Base Skill Evaluation - Empirical Prompt Tuning

## Baseline Scenarios

### Scenario 1: New User Setup with Chezmoi
**Goal**: Help a user set up XDG directories in a chezmoi dotfiles repository for both macOS and Ubuntu
**Requirements**:
- Explain what XDG is and why it's useful in the context of chezmoi
- Show how to set environment variables using chezmoi templates
- Verify setup is correct with chezmoi scripts
- Provide examples of organizing applications in chezmoi structure

### Scenario 2: Application Migration in Chezmoi Context
**Goal**: Help migrate existing applications to XDG-compliant storage within a chezmoi-managed environment
**Requirements**:
- Identify non-XDG compliant applications in a chezmoi setup
- Provide specific migration steps for common applications using chezmoi features
- Show how to test if migration worked with chezmoi tools
- Address platform-specific issues (macOS vs Ubuntu)

### Scenario 3: Compliance Auditing with Chezmoi Tools
**Goal**: Audit chezmoi-managed system for XDG compliance
**Requirements**:
- Methods to detect non-compliant applications using chezmoi commands
- Classification system for compliance levels in chezmoi context
- Remediation strategies using chezmoi features (templates, external files, scripts)
- Reporting format compatible with chezmoi workflow

## Evaluation Criteria

### Clarity
- [x] Clear explanation of XDG concepts in chezmoi context
- [x] Well-defined terminology specific to chezmoi
- [x] Logical progression of topics from basic to advanced

### Completeness
- [x] Covers all five XDG variables with platform considerations
- [x] Addresses common use cases in chezmoi environment
- [x] Provides practical examples using chezmoi features
- [x] Includes troubleshooting guidance for both platforms

### Actionability
- [x] Concrete steps for implementation using chezmoi
- [x] Copy-paste friendly commands and templates
- [x] Clear before/after examples with chezmoi structure
- [x] Platform-specific considerations for macOS and Ubuntu

### Accuracy
- [x] Correct default values for both macOS and Ubuntu
- [x] Proper variable usage in chezmoi templates
- [x] Up-to-date best practices for chezmoi integration
- [x] Security considerations for chezmoi-managed environments

## Initial Assessment

### Strengths
1. Good organizational structure with references following empirical prompt tuning
2. Comprehensive coverage of XDG variables with platform differences
3. Practical examples for common applications using chezmoi features
4. Clear separation of concerns in reference documents
5. Integration with chezmoi-specific tools (templates, scripts, external files)

### Areas for Improvement
1. Need more specific examples of chezmoi template integration
2. Could benefit from more visual examples of directory structures
3. Missing integration with popular chezmoi patterns and best practices
4. Could provide more detailed troubleshooting steps for chezmoi-specific issues

## Improvement Plan Based on Empirical Tuning

### Iteration 1: Enhanced Template Examples
- Add more detailed chezmoi template examples
- Include conditional logic for different platforms
- Show integration with .chezmoiexternal.toml

### Iteration 2: Visual Documentation
- Add directory structure diagrams
- Include before/after comparisons
- Show example outputs of commands

### Iteration 3: Troubleshooting Expansion
- Expand troubleshooting section with common chezmoi issues
- Add platform-specific debugging techniques
- Include recovery procedures for failed migrations

## Fresh Agent Evaluation Protocol

### Execution Contract
1. **Environment Setup**: Fresh chezmoi repository with default configuration
2. **Task Assignment**: Implement XDG Base Directory specification for a mixed macOS/Ubuntu environment
3. **Resource Access**: Access to SKILL.md and references only
4. **Output Format**: Implementation report with challenges encountered

### Self-Report Metrics
- **Clarity Score**: How easily were the instructions understood?
- **Completeness Score**: Were all necessary steps covered?
- **Actionability Score**: How easy was it to implement the solution?
- **Platform Compatibility Score**: How well did the solution work across platforms?

### Instructor-Side Metrics
- **Implementation Success**: Was the XDG setup correctly implemented?
- **Code Quality**: Are the chezmoi templates and scripts well-formed?
- **Cross-Platform Consistency**: Does the solution work on both macOS and Ubuntu?
- **Best Practices Adherence**: Are chezmoi best practices followed?

## Stopping Criteria
- Two consecutive iterations show 0 new ambiguities
- Metrics plateau across clarity, completeness, actionability, and accuracy
- All three baseline scenarios can be successfully executed

## Red Flags to Avoid
- [x] Not re-reading the skill myself - always dispatch a fresh agent
- [x] Assuming one scenario is enough - using all three baseline scenarios
- [x] Making multiple changes at once - one themed delta per iteration
- [x] Ignoring qualitative feedback - prioritizing user experience over metrics
- [x] Reusing the same agent - each evaluation uses a truly fresh perspective
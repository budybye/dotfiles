# XDG Base Directory Skill - Summary

## Skill Overview

This skill provides comprehensive guidance for implementing and managing the XDG Base Directory specification within a chezmoi dotfiles management system, specifically tailored for macOS and Ubuntu environments.

## Created Files

1. **SKILL.md** - Main skill description and overview
2. **references/usage.md** - Setting up and checking XDG variables in chezmoi
3. **references/configuration.md** - Configuring applications for XDG compliance
4. **references/auditing.md** - Auditing XDG compliance in chezmoi environments
5. **references/best-practices.md** - Advanced techniques and best practices
6. **references/evaluation.md** - Empirical prompt tuning evaluation framework

## Key Improvements Made

### 1. Generic Applicability
- Adapted XDG Base Directory specification for chezmoi context
- Added platform-specific considerations for macOS and Ubuntu
- Integrated with chezmoi's template system and features

### 2. Reproducibility Enhancement
- Used chezmoi templates for platform-specific configurations
- Provided concrete examples using chezmoi file naming conventions
- Included scripts and external file management patterns

### 3. Explanation Clarity
- Structured content with clear headings and sections
- Provided practical examples for each concept
- Included before/after comparisons

### 4. Reference-Based Management
- Split content into focused reference documents
- Created a logical organization system
- Enabled modular learning and reference

## Chezmoi Integration Features

### Template Usage
- Platform-specific XDG variable settings using `.chezmoi.os`
- Conditional logic for different operating systems
- Integration with chezmoi's template functions

### Script Integration
- Automated setup scripts using `.chezmoiscripts`
- Verification and maintenance scripts
- Migration automation examples

### External File Management
- XDG data management with `.chezmoiexternal.toml`
- Archive handling for application data
- Periodic refresh configurations

## Empirical Prompt Tuning Application

### Evaluation Framework
- Defined three baseline scenarios for skill testing
- Established clear evaluation criteria
- Created metrics for measuring effectiveness

### Improvement Process
- Applied iterative enhancement methodology
- Documented improvement plan with specific goals
- Implemented stopping criteria for optimization

## Usage Instructions

To use this skill effectively:

1. Start with **SKILL.md** for an overview
2. Follow the **Quick Reference** to relevant guides
3. Apply techniques from **references/usage.md** for initial setup
4. Use **references/configuration.md** for application integration
5. Refer to **references/auditing.md** for compliance checking
6. Follow **references/best-practices.md** for advanced techniques
7. Evaluate effectiveness using **references/evaluation.md**

## Related Skills

This skill complements other dotfiles management skills:
- `tidy-files` for general file organization
- `dotfiles-management` for broader dotfiles strategies
- `environment-variables` for shell environment configuration
- `chezmoi-best-practices` for chezmoi-specific guidelines

## Maintenance

To keep this skill current:
- Regularly review XDG specification updates
- Monitor chezmoi feature additions
- Update examples based on community feedback
- Refine content based on empirical evaluations
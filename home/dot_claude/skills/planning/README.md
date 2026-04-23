# Planning Skill

A comprehensive skill for creating structured implementation plans before writing code.

## Overview

This skill guides agents through a systematic process to analyze requirements, survey codebases, design approaches, and create detailed implementation plans with specific file targets for each step.

## Key Components

1. **Main Skill Definition**: [`SKILL.md`](SKILL.md) - Core instructions and guidelines
2. **Methodology**: [`references/methodology.md`](references/methodology.md) - Detailed planning workflow
3. **Format Specification**: [`references/format.md`](references/format.md) - Required plan structure
4. **Examples**: [`references/examples.md`](references/examples.md) - Sample implementation plans
5. **Extended Methodology**: [`references/methodology_extended.md`](references/methodology_extended.md) - Advanced planning techniques

## Empirical Tuning Process

The skill was developed using empirical prompt tuning with two iterations:

1. **Iteration 1**: [Initial evaluation](iteration_1_evaluation.md) - Identified issues with vague steps
2. **Iteration 2**: [Improved version](iteration_2_evaluation.md) - Achieved 100% accuracy with specific file targets

## Usage

To use this skill, reference the main SKILL.md file and supporting documentation in the references directory. The skill is triggered by prompts related to implementation planning, design planning, or when asked to create plans for features or fixes.

## Key Features

- Structured approach with 5 distinct phases
- Emphasis on concrete, actionable steps with specific file targets
- Comprehensive risk assessment requirements
- Clear section structure with detailed content requirements
- Examples demonstrating proper usage
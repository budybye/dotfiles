# Empirical Prompt Tuning Demonstration - Testcase Skill

This directory demonstrates the empirical prompt tuning process applied to the `/testcase` skill.

## Process Overview

The empirical prompt tuning methodology follows these key steps:

1. **Static coherence check** - Ensure the skill description matches its content
2. **Baseline preparation** - Define evaluation scenarios and requirement checklists
3. **Bias-free reading** - Dispatch a fresh agent to evaluate the skill
4. **Two-sided evaluation** - Collect both executor self-report and instructor-side metrics
5. **Apply a delta** - Make focused improvements based on identified ambiguities
6. **Re-evaluate** - Repeat with a new fresh agent
7. **Stopping criteria** - Continue until 2 consecutive iterations show 0 new ambiguities and metrics plateau

## Files in This Directory

1. `evaluation_scenario.md` - Defined scenario for evaluating the skill
2. `iteration_1_evaluation.md` - First evaluation showing ambiguities and shortcomings
3. `SKILL_improved.md` - Enhanced version addressing identified issues
4. `iteration_2_evaluation.md` - Second evaluation showing improved performance
5. `demo_summary.md` - This summary document

## Key Issues Identified in Iteration 1

1. **Unclear document structures** - The main SKILL.md file referenced templates in formats.md but didn't clearly specify the required document structures
2. **Incomplete roadmap guidance** - The roadmap document structure wasn't fully specified in the main skill file
3. **Technology adaptation confusion** - It wasn't clear how to adapt the Hono/Cloudflare Workers example to other technology stacks
4. **Discretionary decisions** - Users had to make many discretionary decisions about document structure and organization

## Improvements Made in SKILL_improved.md

1. **Explicit document structure requirements** - Added detailed requirements for both test-case list and roadmap documents directly in the main skill file
2. **Clear TC-ID conventions** - Made the TC-ID formatting requirements more prominent
3. **Technology adaptation guidance** - Added a section explaining how to apply the principles to any technology stack
4. **Common pitfalls section** - Added guidance on what to avoid to prevent common mistakes

## Results

The improvements led to:
- Increased accuracy from 70% to 100%
- Reduced steps from 8 to 6
- Eliminated retries (from 2 to 0)
- No new ambiguities in the second iteration

## Application to the Real Testcase Skill

The actual `/testcase` skill could benefit from similar improvements:
1. Making document structure requirements more explicit in the main SKILL.md file
2. Providing clearer guidance on technology adaptation
3. Including more explicit examples of common pitfalls to avoid
4. Ensuring all critical information is available without requiring navigation to reference documents

This would reduce the cognitive load on users and minimize discretionary decisions that could lead to inconsistent results.
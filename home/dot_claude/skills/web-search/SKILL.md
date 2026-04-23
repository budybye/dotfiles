---
name: web-search
description: "Performs web searches to find relevant information. Use when you need to look up facts, definitions, current events, or any information that requires accessing the internet. [Triggers: search the web, find information about, look up, what is, who is, when did, how to, current news about]"
---

# Web Search

A skill for performing web searches to find relevant information from the internet. This skill helps answer questions that require current or factual information not available in training data.

## What This Skill Covers

- Performing web searches for factual information
- Finding current events and recent developments
- Looking up definitions, explanations, and tutorials
- Researching topics that require up-to-date information
- Verifying claims or statements with reliable sources
- Handling ambiguous or complex queries through refinement
- Managing search failures and limitations gracefully
- Synthesizing information from multiple sources
- Communicating uncertainty and limitations clearly

## Quick Reference

| Task | Guide |
|------|-------|
| Search query formulation and optimization | Read [references/search-strategy.md](references/search-strategy.md) |
| Source evaluation and reliability assessment | Read [references/source-evaluation.md](references/source-evaluation.md) |
| Information synthesis and summarization | Read [references/information-synthesis.md](references/information-synthesis.md) |

## When to Use

- Looking up facts, definitions, or explanations
- Finding current events or recent news
- Researching topics that require up-to-date information
- Verifying claims or statements with reliable sources
- Getting information that is beyond training data cutoff
- Answering questions about recent developments (post-training)
- Resolving conflicting information from multiple sources

Do **not** use:

- For information that is common knowledge or in training data
- When the user explicitly asks not to search the web
- For personal or private information not available publicly
- When offline or without internet connectivity
- For creative tasks that don't require factual lookup
- When the query is clearly hypothetical or speculative

## Workflow (Summary)

```
0. Analyze the query to determine search necessity
     ↓
1. Identify query type (factual, current events, instructional, etc.)
     ↓
2. Refine ambiguous or complex queries
     ↓
3. Formulate appropriate search queries
     ↓
4. Perform web search using available tools
     ↓
5. Evaluate source reliability and relevance
     ↓
6. Extract and synthesize relevant information
     ↓
7. Handle edge cases (no results, conflicting information, etc.)
     ↓
8. Present findings with proper attribution
     ↓
9. Cite sources when making factual claims
```

Detailed workflow and search strategies: see [references/search-strategy.md](references/search-strategy.md).

## Red Flags (watch for these rationalizations)

| Rationalization | Reality |
|----------------|---------|
| "I can guess the answer without searching." | Guessing can spread misinformation. Always verify when in doubt. |
| "One source is enough for factual information." | Single sourcing can be biased. Cross-reference important facts. |
| "Recent search results aren't necessary for this topic." | Even "evergreen" topics can have recent developments. |
| "All information from reputable sources is accurate." | Even reputable sources can contain errors or outdated information. |
| "I don't need to cite my sources." | Proper attribution builds trust and allows verification. |
| "I should click on the first search result." | First results can be SEO-optimized, not necessarily the most accurate. |
| "I can't find anything, so I'll make something up." | It's better to admit limitations than provide false information. |
| "I need to provide a definitive answer even when uncertain." | Communicating uncertainty is more honest and helpful. |

Extended pitfalls: see [references/search-strategy.md](references/search-strategy.md#common-failures).

## Environment Constraints

This skill requires access to:
- Internet connectivity for performing searches
- Web search tools (like WebSearch, DuckDuckGo, Google, etc.)
- Ability to parse and process search results
- Time to perform searches and evaluate results

When constrained (limited connectivity, no search tools), adapt by:
- Explaining the limitation to the user
- Providing information from training data with appropriate disclaimers
- Suggesting alternative approaches when possible
- Requesting user assistance when appropriate

When search tools fail or return no results:
- Try alternative search formulations
- Check for typos or ambiguous terms in the query
- Break complex queries into simpler sub-queries
- Inform the user of the difficulty and propose alternatives

## Related Skills

- `defuddle` — Extract clean content from web pages, removing clutter
- `repo-research` — Research external libraries and repositories
- `awesomes` — Discover and evaluate technologies using curated lists
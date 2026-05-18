# Karpathy Guidelines for LLM Software Engineering

This skill package contains behavioral guidelines from Andrej Karpathy for reducing common LLM coding errors and improving code quality through disciplined software engineering practices.

## GitHub Source

**Repository:** [karpathy/misc-notes](https://github.com/karpathy/misc-notes)  
**Primary Resource:** Andrej Karpathy's notes on LLM software engineering practices  
**License:** MIT (as per the repository)

## Core Principles

### 1. Avoid Over-Complexity
- Start with the simplest possible solution
- Add complexity only when justified by requirements
- Refactor gradually rather than rewriting
- Prefer clarity over cleverness

### 2. Surgical, Precise Changes
- Make targeted modifications that directly address the requirement
- Avoid touching unrelated code unless fixing coupled bugs
- Each change should have a clear, verifiable purpose
- Use small, testable steps rather than large refactors

### 3. Reveal Assumptions
- Explicitly state what you believe about the system
- Question assumptions rather than proceeding with them
- Test assumptions with concrete examples
- Document non-obvious dependencies

### 4. Define Verifiable Success Criteria
- Before implementing, define measurable success metrics
- Create tests that validate the desired behavior
- Verify both that the solution works AND that it doesn't break existing functionality
- Use specific examples, not abstract descriptions

### 5. Incremental Development & Validation
- Build features incrementally with frequent testing
- Validate each step before proceeding to the next
- Catch mistakes early rather than late
- Use version control effectively to checkpoint progress

### 6. Code Review Discipline
- Review code for logic errors, not just style
- Ask questions to understand assumptions
- Validate that tests actually cover the behavior
- Check for edge cases and error handling

## Application to SuperGit-Tools

This skill package is applied when:
- Writing new PowerShell or Python code
- Reviewing pull requests and code changes
- Refactoring existing functionality
- Debugging complex issues
- Designing new features

## How to Use

1. **Before writing code:**
   - Define the specific problem and success criteria
   - List assumptions about the system state
   - Plan the smallest set of changes needed

2. **During implementation:**
   - Make surgical changes that address only the requirement
   - Avoid adding features or "while I'm here" changes
   - Test frequently and incrementally

3. **During review:**
   - Check that the change is surgical and complete
   - Verify assumptions are stated and tested
   - Confirm success criteria are met
   - Look for unnecessary complexity

---

**Skill Package Version:** 1.0  
**Last Updated:** 2026-05-17

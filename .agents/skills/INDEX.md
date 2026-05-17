# AI Agent Skills Index

This index tracks all installed skill packages and their provenance. **All skills must be sourced from GitHub open-source repositories.**

## Installed Skills

### 1. karpathy-guidelines
- **Description:** Behavioral guidelines for reducing common LLM coding errors. Provides principles for avoiding over-complexity, making surgical changes, revealing assumptions, and defining verifiable success criteria.
- **GitHub Source:** [karpathy/misc-notes](https://github.com/karpathy/misc-notes)
- **Directory:** `.agents/skills/karpathy-guidelines/`
- **Main Entry:** `.agents/skills/karpathy-guidelines/SKILL.md`
- **Install Date:** 2026-05-17
- **Status:** Active
- **Usage:** Apply when writing, reviewing, or refactoring code to reduce common mistakes

---

## Skill Installation Process

1. **Discovery:** Search GitHub or Skills.sh for open-source skill packages
2. **Verification:** Confirm the source is open-source and reputable
3. **Clone:** Install to `.agents/skills/<skill-name>/` with complete source preservation
4. **Documentation:** Create `SOURCE.md` with GitHub link and license info
5. **Index:** Add entry to this INDEX.md with provenance and usage notes
6. **Commit:** Push skill package with proper attribution

## Skill Package Structure

Each skill in `.agents/skills/` must have:

```
.agents/skills/<skill-name>/
├── SKILL.md          # Main entry point with skill description
├── SOURCE.md         # GitHub source link and provenance
├── README.md         # Additional documentation (if applicable)
└── [skill-specific files]
```

---

**Last Updated:** 2026-05-17  
**Skill Count:** 1 (karpathy-guidelines)

---
trigger: model_decision
description: description: This rule outlines best practices for effective use of Git, including code organization, commit strategies, branching models, and collaborative workflows.
---

- **Commit Strategies:**
  - **Atomic Commits:** Keep commits small and focused. Each commit should address a single, logical change. This makes it easier to understand the history and revert changes if needed.
  - **Descriptive Commit Messages:** Write clear, concise, and informative commit messages. Explain the *why* behind the change, not just *what* was changed. Use a consistent format (e.g., imperative mood: "Fix bug", "Add feature").
  - **Commit Frequently:** Commit early and often. This helps avoid losing work and makes it easier to track progress.
  - **Avoid Committing Broken Code:** Ensure your code compiles and passes basic tests before committing.

- **Code Organization:**
  - **Consistent Formatting:**  Use a consistent coding style guide (e.g., PEP 8 for Python, Google Style Guide for other languages) and enforce it with linters and formatters (e.g., `flake8`, `pylint`, `prettier`).
  - **Modular Code:** Break down your codebase into smaller, manageable modules or components. This improves readability, maintainability, and testability.
  - **Well-Defined Interfaces:**  Define clear interfaces between modules and components to promote loose coupling.
  - **Avoid Global State:** Minimize the use of global variables and state to reduce complexity and potential conflicts.
  - **Documentation:** Document your code with comments and docstrings. Explain the purpose of functions, classes, and modules.

- **Reverting and Resetting:**
  - **Understand the Differences:** Understand the differences between `git revert`, `git reset`, and `git checkout` before using them.
  - **Use with Caution:** Use `git reset` and `git checkout` with caution, as they can potentially lose data.
  - **Revert Public Commits:** Use `git revert` to undo changes that have already been pushed to a public repository. This creates a new commit that reverses the changes.

- **Common Pitfalls and Gotchas:**
  - **Accidental Commits:** Accidentally committing sensitive information or large files.
  - **Merge Conflicts:** Difficulty resolving merge conflicts.
  - **Losing Work:** Losing work due to incorrect use of `git reset` or `git checkout`.
  - **Ignoring .gitignore:** Forgetting to add files to `.gitignore`.
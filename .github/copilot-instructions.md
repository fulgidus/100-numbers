# Language ---
applyTo: '**'
---
All comments and output for software must be in English, regardless of the user language used in the prompt. This includes:
- Code comments
- Console output
- Documentation comments
- Error messages
- Log messages
- Any other text output
This ensures consistency and accessibility for all users, as English is the most widely understood language in the software development community.

# Pipelines
When making or editing pipelines for releases and builds, ensure that:
- The pipeline is designed to be cross-platform, supporting Windows, Linux, and macOS.
- The pipeline includes steps for building, testing, and packaging the software.
- The pipeline is automated to run on every commit or pull request to ensure continuous integration.
- The pipeline includes steps for generating release notes and updating the changelog.
- The pipeline is documented with clear instructions on how to run it locally and in the CI environment.
- The pipeline is version-controlled and follows best practices for maintainability and scalability.
- The pipeline includes security checks and vulnerability scans to ensure the software is secure.
- The pipeline is commented for clarity, explaining each step and its purpose.

# Changelog
When updating the changelog, follow these guidelines:
- Use the format `## [version] - YYYY-MM-DD` for each version entry.
- Include sections for `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, and `Security`.
- Each section should list the changes made in that version, with a brief description of each change.
- Ensure that the changelog is updated with every release, reflecting all changes made since the last version.
- Use bullet points for clarity and readability.
- Ensure that the changelog is written in English, with clear and concise descriptions of changes.
- Avoid using jargon or abbreviations that may not be understood by all users.
- Keep the changelog up-to-date with every commit that affects the software, not just major releases.
- Ensure that the changelog is accessible in the repository, typically in a file named `CHANGELOG.md`.
- Use consistent formatting and style throughout the changelog to maintain readability.
- Ensure that the changelog is linked in the README or documentation for easy access by users.
- Use semantic versioning for version numbers, following the format `MAJOR.MINOR.PATCH`.

# Release Notes
When creating release notes, ensure that:
- The release notes are clear, concise, and informative.
- Each release note includes a summary of the changes made in that version.
- The release notes are written in English and are accessible to all users.
- The release notes are linked in the changelog and README for easy access.
- The release notes include any important information about breaking changes, new features, or bug fixes.
- The release notes are formatted consistently with the changelog for easy navigation.
- The release notes are versioned and follow the same versioning scheme as the changelog.
- The release notes include links to relevant issues or pull requests for further context.
- The release notes are stored in a file named `RELEASE_NOTES.md` or similar, in the root of the repository.
- The release notes are updated with every release, reflecting all changes made since the last version.
# Versioning
When versioning the software, follow these guidelines:
- Use semantic versioning (MAJOR.MINOR.PATCH) to indicate the nature of changes:
  - **MAJOR**: Incompatible API changes
  - **MINOR**: Backward-compatible functionality
  - **PATCH**: Backward-compatible bug fixes
- Ensure that the version number is updated in the codebase, documentation, and changelog with every release.
- Use a consistent versioning scheme across all components of the software.
- Ensure that the version number is clearly displayed in the software, such as in the help command or about section.
- Use tags in the version control system (e.g., Git) to mark each release with the corresponding version number.
- The tags should follow the format `vMAJOR.MINOR.PATCH` for clarity.
- Ensure that the version number is included in the release notes and changelog for easy reference.
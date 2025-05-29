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
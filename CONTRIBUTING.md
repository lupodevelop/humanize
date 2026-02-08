# Contributing

Thanks for your interest in contributing to the humanize library! We welcome contributions of all sizes — bug reports, documentation fixes, tests, or improvements to the code.

## How to contribute

- Fork the repository and create a branch for your change: `git checkout -b my-feature`.
- Make your changes on the branch and follow the project style (run `gleam format`).
- Add tests for bug fixes or new functionality under the `test/` directory.
- Run the test suite locally: `gleam deps download && gleam test`.
- When ready, push your branch and open a Pull Request against `main`.

## Reporting issues

Please open issues for: bugs, feature requests, or questions. Provide a clear description, steps to reproduce, and (when applicable) a minimal reproduction case.

## Pull request guidelines

- Keep PRs small and focused.
- Describe the motivation and the changes included.
- Reference related issues using `#<issue-number>`.
- Ensure tests pass and formatting is correct (`gleam format --check`).

## Style and tests

- Use `gleam format` to keep code style consistent.
- Add unit tests for new behaviour and for bug fixes.

## License

By contributing you agree that your changes will be licensed under the MIT License of this project.

---

Thank you for helping improve humanize! 💜
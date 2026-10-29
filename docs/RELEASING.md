# Releasing a new version

The download links in the README always point to the newest GitHub release
(`releases/latest/download/<file>`), so every release must attach each
`.lsp` file under its own name. The workflow in
`.github/workflows/release.yml` does this automatically.

1. In each changed `.lsp` file, raise the `Version:` line in the header (and
   the year in the `Copyright` line if needed).
2. Add a section for the new release at the top of `CHANGELOG.md`, e.g.
   `## 1.1.0`, and update the "Release" line in `README.md`.
3. Commit, then push a tag named after the release:

   ```sh
   git tag v1.1.0
   git push origin v1.1.0
   ```

   The workflow publishes the release "LISP routines 1.1.0" with every
   `lisp/*.lsp` file and `lisp-routines.zip` attached, and the CHANGELOG
   section as its text.

A new routine needs a new row (and download link) in the README table; the
release picks it up automatically from the `lisp/` folder.

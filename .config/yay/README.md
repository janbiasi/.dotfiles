# AUR review policy

Requires yay 13.0.1 or newer. `init.lua` shows all build-file diffs, enables
the edit menu, enables missing PGP key lookup, and clears persisted makepkg
flags. Explicit CLI options still override these defaults.

Before the review menus, the hook warns about `SKIP` checksums declared in
`.SRCINFO`, including architecture-specific entries. This is an advisory:
metadata can be stale or dishonest, and Git sources commonly use `SKIP`.
Inspect the actual PKGBUILD, auxiliary scripts, source URLs, pinned revisions,
and signing-key fingerprints against upstream information.

makepkg already verifies declared checksums and source signatures. A checksum
supplied by the same maintainer as the source URL cannot establish that the
source is trustworthy. Fetching a PGP key does not authenticate its owner.
Do not bypass failures with `--skipinteg`, `--skipchecksums`, or `--skippgpcheck`.
Do not regenerate checksums simply to make a failed check pass.

For a separate manual review, use `aur-fetch-review PACKAGE_BASE`. After
reviewing the downloaded files, `makepkg --verifysource` checks the sources
without building. It still sources the PKGBUILD, so review must come first.

The existing two-day cooldown only covers upgrades. It exempts selected nightly
software packages, whose frequent releases would otherwise be excluded
indefinitely. Maintainer-change warnings record the latest observed maintainer,
not an explicitly approved identity. Neither mechanism is a sandbox or proof
that a package is safe.

References: [yay Lua API](https://github.com/Jguer/yay/blob/next/doc/lua.md),
[makepkg manual](https://man.archlinux.org/man/makepkg.8.en).

# Reference Files

These files are retained for historical comparison or manual host setup. They
are not installed by `setup.sh`.

- `bash/` contains legacy complete `.bashrc` examples. Active shell
  customizations live in `assets/dev-shell/`.
- `colors/256colors2.pl` is the legacy terminal color test downloaded from
  ConEmu's documentation site.
- `wsl/.wslconfig` configures the Windows WSL host. Copy it manually to
  `%UserProfile%\.wslconfig`; it is not a Linux guest configuration file.
  Its memory and processor values are examples to review for the host, not
  portable defaults.

# NixOS Configuration

![NixOS](https://img.shields.io/badge/-NixOS-5277C3?style=flat-square&logo=nixos&logoColor=black) ![Nix](https://img.shields.io/badge/-Nix-7EBAFF?style=flat-square&logo=nixos&logoColor=black)

A personal NixOS configuration for daily-driver laptops, built over time with an emphasis on:

- security
- network privacy
- development tooling
- penetration testing
- AI/ML workflows (exists but often proven unrealistic sorry if you had rainbow dreams because of what the hardware companies gives as a sorry excuse of a vram *coughs~ Nvidia* while spitting on us for most consumer hardware at best, that's your sign that you know a human was behind this code)

The configuration is declarative throughout, everything is expressed in Nix, with secrets kept in an excluded `Sec/` directory.

> **Started**: 10/11/2023 (DD/MM/YYYY)
> **Last reviewed:** 19/07/2026 (DD/MM/YYYY)

---

## Repository Layout

The repository lives at `/etc/nixos/` and is structured so that each concern owns its own directory. The root `configuration.nix` is the single entry point that imports everything else.

The `ztop.nix` convention is used throughout: every directory that groups multiple files provides a `ztop.nix` that imports all siblings, so the parent only needs to import that single file.

> Note: the file `control-hardware.nix` is for overriding logic that is in `hardware-configuration.nix` per the instructions provided in

---

## Hardware Detection

Because the same repository is shared between two machines

- **ASUS TUF Gaming A15**
- **Dell G15**
- **IdeaPad 5**
- (Extensibility is available to other hardware/server cases)

> Note: hardware branching is needed in several places (git identity, power management, etc.).

Rather than maintaining separate `configuration.nix` files, an activation-time shell script (`ID/detect-hardware.sh`) reads `/sys/class/dmi/id/product_name`, matches it against known patterns, and writes a small Nix file to `Sec/hardware-detected.nix`. That generated file sets four boolean options (`hardware.isAsusTuf`, `hardware.isDellG15`, `hardware.isThinkPad`, `hardware.isIdeaPad5`) which are declared in `ID/ID.nix` and consumed wherever hardware-specific behavior is required.

> Note: I don't own a thinkpad it's just a so much of a legendary / based hardware that i thought of it before the hardware i have access to (yes i know it's stupid to leave it but i will leave it as a pure template)
---

## Boot and Kernel

The system uses **systemd-boot** with EFI. Several categories of kernel parameters are set explicitly. (BE AWARE!)

View them in

- [security.nix](security.nix)
- [control-hardware.nix](control-hardware.nix)
- [Network_Kernel_Parameters.nix](Networking/hardening/Network_Kernel_Parameters.nix)

I have the use-case and sometimes the absolute need for these parameters to be set, these aren't written by AI, I formatted these files that way so I can actually go back and understand what is going on or if something in my system messes up that these aren't the suspect.

---

## Graphics

The systems runs NVIDIA GPUs in [graphics.nix](graphics.nix)

- ASUS TUF contains a single dedicated GPU No Integrated.
- Dell G15 contains both a dedicated and an integrated.
- Lenovo IdeaPad 5 also contains both a dedicated and an integrated.

`hardware.nvidia` is configured with the latest proprietary driver, modesetting enabled, `powerManagement.enable = true`, and `dynamicBoost.enable = true`. `forceFullCompositionPipeline` is left off deliberately; tear-free is instead handled at the X server screen-section level for compatibility.

`nixpkgs.config.cudaSupport = true` is set globally, which means any package that optionally supports CUDA will be built with it. The binary cache is configured as a substituter so CUDA-enabled packages are pulled from cache rather than compiled locally.

---

## Desktop

KDE Plasma 6 runs on Wayland via SDDM with the KWin compositor. X.Org server is explicitly disabled (`services.xserver.enable = lib.mkForce false`). `programs.xwayland` remains enabled for applications that do not yet support Wayland natively.

Several XDG portals are configured in parallel (GTK, GNOME, KDE) so both GTK and Qt applications get proper file-picker and screen-share integration.

Notable environment variables: `NIXOS_OZONE_WL=1` enables Ozone Wayland for Chromium-based apps, `QT_QPA_PLATFORM="wayland;xcb"` allows Qt to fall back to XCB when Wayland is unavailable, and `GSK_RENDERER=nvidia` nudges GTK4's scene graph toward the NVIDIA backend.

KWallet PAM integration is disabled (`security.pam.services.sddm.kwallet.enable = false`) in favour of using KeePassXC for credential management.

---

## Networking

DNS resolution is isolated from the system resolver through three separate layers, with encryption and caching at each stage.

### DNS Architecture

Resolution flows through three hops.

```
Application
    │
    ▼
Unbound  (127.0.0.1:53)   - DNSSEC validation, caching, ad-blocking
    │  forward-zone "."
    ▼
dnscrypt-proxy  (127.0.0.1:5354)   - DNS-over-HTTPS / DNSCrypt
    │  server_names: cloudflare, google, quad9, mullvad
    ▼
Upstream resolver
```

**Unbound** (`Networking/DNS/cache.nix`) listens on localhost port 53 and handles DNSSEC validation, negative caching, query-name minimisation, and ad-blocking. The ad-block zone list is fetched from the StevenBlack hosts repository at build time and compiled into an Unbound `local-zone` include file. Cache sizes are generous (message cache 512 MB, RRset cache 1 GB) with a 7-day maximum TTL and `serve-expired` enabled so stale records are served while a background refresh happens.

**dnscrypt-proxy** (`Networking/DNS/resolver.nix`) listens on port 5354 and forwards encrypted DNS upstream. It is configured to only select servers that pass `require_nolog`, `require_nofilter`, and `require_dnssec`. The resolver list is fetched from the official DNSCrypt repository and verified with a Minisign key. Its own cache is disabled because Unbound already handles caching; double-caching would cause stale-data inconsistencies.

`systemd-resolved` and `resolvconf` are both disabled. NetworkManager is told to use `dns = "default"`, which means it writes `nameservers = ["127.0.0.1"]` to the effective resolver configuration, pointing all applications at Unbound.

### Time Synchronization

`systemd-timesyncd` is disabled and replaced with **chrony** with NTS (Network Time Security) using `time.cloudflare.com`. NTS authenticates time packets cryptographically so they cannot be spoofed.

### Firewall

The firewall is handled by `nftables` (enabled via `networking.nftables.enable = true`) with NixOS's higher-level `networking.firewall` rules layered on top. Opened ports are documented inline:

- TCP 53/5353/853: DNS and DNS-over-TLS
- TCP 443: OpenVPN
- TCP 8384, 22000: Syncthing GUI and sync
- TCP 8888, 18081: Jupyter and general development (will be removed)
- UDP 67/68: DHCP (for hotspot mode)
- UDP 6881: qBittorrent (will be removed after some research)
- UDP 21027: Syncthing discovery
- TCP/UDP 1714-1764: KDE Connect
- TCP/UDP 21114-21119: RustDesk

`fail2ban` is enabled. Refused packets, reverse-path drops, and refused connections are all logged.

### Protocols

SSH is configured but `sshd.wantedBy` is set to an empty list, meaning the daemon does not start on boot. It must be started manually, which is treated as a deliberate security measure. Password authentication remains enabled for flexibility.

OpenVPN uses `openvpn3` with systemd-resolved integration disabled (since the system does not use resolved). WireGuard kernel support is enabled with `wireguard-tools` installed, but interface configuration is left to NetworkManager imports at runtime.

### Kernel Network Parameters

`Networking/hardening/Network_Kernel_Parameters.nix` sets `boot.kernel.sysctl` values across several categories. Key decisions:

TCP congestion control is set to **BBR** with the `fq` qdisc, which provides better throughput on lossy or high-latency links. TCP buffer sizes are raised to 16 MB maximum. MPTCP (Multipath TCP) is enabled for potential throughput gains on multi-interface setups. IPv6 is disabled system-wide. Reverse-path filtering is set to loose mode (value 2) on all interfaces, which prevents obvious spoofing while remaining compatible with asymmetric routing that hotspot/bridging setups produce. SYN cookie protection is enforced, and TCP keepalive probes are set aggressively (60 s idle, 10 s interval, 6 probes) to detect dead connections quickly.

---

## Development Environment

### Languages

Each language has its own file under `Dev/Langs/` and is imported by `Dev/Langs/ztop.nix`.

> Note: You may need shells with every project while working with NixOS please be mindful that this is done to cache as much in nix-store due to the limited bandwidth and expensive internet environment that is forcedly conditioned in my very situation

**C++** (`Dev/Langs/cpp.nix`) installs GCC 14 at high priority alongside LLVM/Clang 20, CMake, Ninja, pkg-config, GTest, GTK3/4, Qt base and tools, Eigen, nlohmann_json, and BPF tooling. The high-priority markers avoid library path collisions between GCC and Clang toolchains. A separate `Dev/cpp_env.nix` exists (currently commented out in `Dev/ztop.nix`) that sets `CC`/`CXX`/`CPLUS_INCLUDE_PATH`/`LIBRARY_PATH` environment variables for projects that rely on those rather than CMake's detection logic.

**Python** (`Dev/Langs/python.nix`) provides a system-wide `python312` environment with packages covering GUI (PyQt6, PySide6, raylib), data (pandas, OpenCV, JAX, ONNX), networking (netutils, Selenium), databases (SQLite, pymysql), packaging (PyInstaller), and Jupyter/IPython infrastructure. The package set is installed with `lib.lowPrio` so it does not conflict with project-specific virtual environments. `ruff` and `ffmpeg-full` (with Whisper support disabled to reduce closure size) are installed at normal priority.

**Rust** (`Dev/Langs/rust.nix`) installs the compiler, Cargo, Clippy, rustfmt, rust-analyzer, and cargo-flamegraph for profiling.

**Go** (`Dev/Langs/go.nix`) installs the Go toolchain, `gopls`, `libcap`, and `go-outline`.

**Dart/Flutter** (`Dev/Langs/dart.nix`) installs the `flutter` package, which bundles the Dart SDK.

**Java** (`Dev/Langs/java.nix`) uses `programs.java` with `binfmt` enabled so JAR files can be executed directly.

**Nix** (`Dev/Langs/nix.nix`) installs `nixd` (the LSP), `alejandra` (formatter), `direnv`, `nix-direnv`, `nix-tree`, `nix-init`, `nix-eval-jobs`, `nix-output-monitor`, and `nixpkgs-review`.

**SQL** (`Dev/Langs/sql.nix`) installs SQLite. Database servers are handled separately.

### Domain-Specific Tools

**MySQL** (`Dev/Domain_Specific/MySQL.nix`) runs MariaDB on port 3306, bound to localhost only. The configuration includes InnoDB tuning (256 MB buffer pool, `O_DIRECT` flush method, `ACID` compliance at `innodb_flush_log_at_trx_commit=1`), slow query logging (threshold 2 s), `utf8mb4` character set, and the `server_audit` and `ed25519` plugins. A single user is granted all privileges without a hardcoded password.

**PostgreSQL** (`Dev/Domain_Specific/PostgreSQL.nix`) is defined but set to `enable = false`. When enabled it uses `scram-sha-256` authentication, listens on 127.0.0.1, and initializes the postgres superuser password from a secrets file.

**UML/Diagramming** (`Dev/Domain_Specific/UML.nix`) installs Mermaid CLI, PlantUML, Graphviz, and a JDK to run PlantUML.

**Big Data** (`Dev/Domain_Specific/Big_Data.nix`) installs Hadoop, Pig, and Spark.

**Documentation** (`Dev/Domain_Specific/Docs.nix`) installs Doxygen (with GUI and CSS theme) and Monolith (a tool to save web pages as single HTML files).

**Pandoc** (`Dev/Domain_Specific/Pandoc.nix`) pulls from the unstable channel to get a newer release. It installs Pandoc, `pandoc-include`, `pandoc-ext-diagram`, Typst (noted as not fully working), and a `texliveMedium` with the `fontspec` package. Environment variables `PLANTUML_JAR` and `PANDOC_DIAGRAM_FILTER` are set globally so Pandoc diagram filters can locate their dependencies without per-project configuration.

### IDE: VSCodium

`Dev/IDEs/vscodium.nix` configures VSCodium (the telemetry-free VS Code build) with an extension set assembled from both nixpkgs and the VS Code Marketplace.

Extensions are split across per-language files under `Dev/IDEs/VScode_Extensions/` to keep the main configuration manageable. Each file exports two lists (`*-nixpkgs-extensions` and `*-marketplace-extensions`) which are concatenated in `vscodium.nix`.

The settings file (`Dev/IDEs/vscode_config.jsonc`) is copied into `~/.config/VSCodium/User/settings.json` via a `system.userActivationScripts` entry, so the editor configuration is managed declaratively without home-manager.

---

## Python/ML Package Overlays

`Dev/overlays.nix` defines a `nixpkgs.overlays` entry that overrides several Python packages. This is the mechanism used to bring in ML/AI packages that either don't exist in nixpkgs or require patched versions.

Overridden packages include: `torch` → `torch-bin`, `torchaudio` → `torchaudio-bin`, `torchvision` → `torchvision-bin`, `jaxlib` → `jaxlib-bin` (all preferring pre-built binaries to avoid hours-long compilation), plus custom derivations for `unsloth`, `unsloth-zoo`, `flash-attn`, `vllm`, `xformers`, `smolagents`, `trl`, `tyro`, `datasets`, `huggingface-hub`, `hf-xet`, `cut-cross-entropy`, `keras`, `onnxruntime`, and `fairseq2`.

`Programs/python-libs/` contains the actual derivations. Several require nontrivial patching:

`unsloth-zoo` requires `dos2unix` at build time because upstream ships CRLF line endings in Python source files, which break the Nix patcher. Patches remove the requirement for `sudo` at runtime, remove the circular import check that requires `unsloth` to be present before `unsloth-zoo` can import, and fix the `pyproject.toml` license field syntax to conform to PEP 621.

`xformers` disables parallel building (`enableParallelBuilding = false`) and caps `MAX_JOBS=2` to prevent OOM during compilation. The build is memory-intensive: each concurrent xformers job can consume 4 to 8 GB of RAM.

`vllm` carries three patches: one to respect `cmakeFlags` passed from the Nix build environment, one to propagate `PYTHONPATH` to a subprocess that `vllm` spawns for model registry loading, and one to remove an `lsmod` call that fails in the sandbox. `vllm` also vendors several upstream libraries (cutlass, FlashMLA, vllm-flash-attn) via `fetchFromGitHub` rather than using FetchContent at build time, which is incompatible with the Nix sandbox.

`onnxruntime` is installed as a pre-built wheel (CPU or CUDA variant selected by `config.cudaSupport`). The TensorRT provider shared library is deleted at `preFixup` time because `libnvinfer` and `libnvonnxparser` are not available in the closure.

---

## Services

### AI Stack

`Services/Ai.nix` configures **Ollama** (from the unstable channel, with CUDA acceleration) on port 11434, binding to localhost. Models are stored in `~/AI` rather than the default location. Open-WebUI is defined but set to `enable = false`.

Apache Tika OCR is defined but disabled. Podman is defined but disabled.

### Custom search engine

**SearXNG** is enabled as a local metasearch engine on port 8880. Its engine list includes Google, DuckDuckGo, Wikipedia, Wikidata, books (Goodreads, OpenLibrary, Anna's Archive), software (F-Droid, APKMirror, Void Linux, Apple App Store, CachyOS, Alpine packages), torrents (seven sources), wikis (multiple MediaWiki instances, Arch Linux wiki, Wikimedia Commons), and a handful of explicitly disabled engines (Bing, Brave). Engines are assigned shortcut numbers sequentially. The favicon and thumbnail proxy resolvers are enabled. NNSFW, OpenAI API, and evaluation arena features are disabled.

### Gaming

`Services/Gaming.nix` enables Steam with Proton Tricks, extest, and gamescope session support. A custom `proton-ge-bin` derivation is included as an extra compat package. Bottles (the Wine/game launcher) is configured with Proton GE linked into its runners directory.

Additional packages: Heroic (Epic/GOG launcher), DXVK, MangoHud, Winetricks, and a selection of open-source games (Unciv, OpenTTD, Mindustry).

### Penetration Testing

`Services/Pen_Testing.nix` installs a set of tools grouped by purpose.

### Audio

`Services/PipeWire.nix` runs PipeWire with ALSA, JACK, and PulseAudio compatibility layers. Buffer sizes are set conservatively large (2048 frames quantum, 1024 minimum) for stability rather than minimum latency. The PulseAudio compatibility layer is configured with matching buffer sizes. `security.rtkit` is enabled so the PipeWire daemon can request real-time scheduling.

### Power Management

`Services/PowerManagment.nix` branches on detected hardware. On the ASUS TUF, `asusd` (the ASUS Linux daemon), while all commenly use `power-profiles-daemon`, and `system76-scheduler` .

### Syncthing

`Services/Syncthing.nix` configures Syncthing for the user `masrkai` with four defined folders: college documents (send-only, synced to phone, tablet, and Mariam's laptop), a books library (send-only to the same devices), and a music folder (bidirectional with the Android phone). Relay servers are disabled; only local announcement and direct connections are used. Devices are overridden declaratively so the WebUI cannot add unknown peers.

### Virtualization

`Services/Virtualization/virtualisation.nix` enables QEMU/KVM via libvirtd with the full QEMU package, swtpm (software TPM), spice and virtio-win guest agent support, and virglrenderer for 3D acceleration in VMs. The `masrkai` user is added to `libvirt`, `libvirtd`, `kvm`, and `ubridge` groups.

`Services/Virtualization/GNS.nix` runs GNS3 server on port 3080 (localhost only) with VPCS and Dynamips emulators enabled. The systemd service configuration is overridden to grant `CAP_NET_ADMIN` and `CAP_NET_RAW` capabilities and to remove filesystem protection that would prevent GNS3 from accessing network interfaces.

`Services/Virtualization/simulation.nix` installs Cisco Packet Tracer 8 from a local `.deb` file (the file is gitignored; the derivation handles unpacking and patching). Octave with the `image` package and Veusz are also installed here.

### Application Configuration Management

`Services/App_configs/apply_configs.nix` runs a oneshot systemd service as the user `masrkai` on each boot to copy configuration files managed inside this repository into their expected locations: btop (`~/.config/btop/btop.conf`), kitty (`~/.config/kitty/kitty.conf`), Octave (`~/.octaverc`), Ghostty (`~/.config/ghostty/config`), a clangd config YAML, and a Jackett tracker configuration JSON. This sidesteps home-manager while still keeping dotfiles in version control.

### Radicale

A CalDAV/CardDAV server (`radicale`) is enabled on port 5232 with bcrypt `htpasswd` file authentication. The comment in the file notes that the password file must be created manually with `htpasswd -B`.

### Jackett

Jackett runs as its own user on port 9117 (no firewall hole opened) to provide an API bridge between torrent indexers and qBittorrent.

---

## Terminal Environment

### Bash

`Terminal/bash.nix` configures the system Bash shell using `programs.bash`. It sources a library of shell functions and sets aliases for most of the common commands.

**Aliases** replace several standard commands: `ls`/`la`/`lss` and variants all point to `eza` with color, git status, icons, and directory-first sorting. `grep` is replaced with `ripgrep`. `cp` and `mv` have `-vi` flags for verbosity and overwrite protection. `sudo` is aliased with a trailing space so aliases are expanded after `sudo`. A `cpv` alias wraps `rsync` for copy-with-progress.

**Functions** sourced at login (`Terminal/Functions/`):

- `switch` / `update` / `rollback` / `garbage` / `gens`: NixOS rebuild and maintenance helpers, piping output through `nom` (nix-output-monitor).
- `compress` / `extract`: Archive creation and extraction supporting zip, 7z, tar.gz (with pigz for parallel compression), tar.lz, and tar.zst. Compression uses `pv` for progress display.
- `convert_to_mp4`: ffmpeg wrapper for normalizing video to H.264 baseline with AAC audio and faststart flag.
- `convert_ppts_to_pdf`: LibreOffice headless batch conversion of PowerPoint files to PDF.
- `pandocmarkdowntopdf`: Pandoc wrapper that converts Markdown to PDF via XeLaTeX, using the FreeSans and FreeMono fonts, with PlantUML diagram support via the `pandoc-ext-diagram` Lua filter.
- `download-youtube` / `download-playlist` / `download-video`: yt-dlp wrappers with configurable resolution, archive file tracking, and MP4 output.
- `ani-cli-batch`: Batch anime downloader built on `ani-cli`, iterating episodes with automatic quality fallback (1080p → 720p → 480p → 360p).
- `s`: Re-runs the last command with sudo, stripping any existing `sudo` prefix. Falls back to the second-to-last command if the last command was itself `s`.
- `sync_nixos_config`: rsync-based sync from `/etc/nixos/` to a user directory, excluding `Sec/` and protecting `.git` metadata.
- `journalctle` / `journalctlw`: Deduplicated journald error and warning viewers, rendered with `bat` if available.
- `sector_copy`: Copies all files with a given extension from a directory into the clipboard as fenced Markdown code blocks (using `wl-copy`).
- `clean_stale_mount`: Unmounts and removes stale `/run/media/` mount points after improper disconnections.
- `usb_power_map`: Cross-references `lsusb` output with sysfs power control settings to display per-device USB power management status.
- `garbage`: Runs `nix-collect-garbage -d` followed by `nix-store --optimise`.
- `clearjournal`: Rotates and vacuums journald logs.
- `fixcode` / `fixgit` / `fixbrave` / `fixkde`: Quick fixes for common breakage (GPU cache corruption, git ownership, browser singleton locks, dead plasma shell).

FZF completion is enabled via `fzf-bash-completion.sh`, bound to the Tab key. FZF color scheme is set to a Dracula-inspired palette.

### Starship Prompt

`Terminal/starship.nix` configures a two-line Starship prompt. Line one shows the directory, a custom git remote icon, git branch and status (with counts for each state: modified, staged, untracked, stashed, ahead, behind, etc.), and language module indicators that appear only when the relevant project files are detected. Line two shows the username, hostname, time, and the prompt character (green arrow on success, red on error).

A custom `giturl` module (`Terminal/starship_custom/giturl.sh`) displays a provider-specific icon (GitHub, GitLab, Bitbucket, or generic Git) based on the remote URL.

The nix-shell indicator shows `❄️ pure shell`, `❄️ impure shell`, or `❄️ unknown shell` depending on the nix shell type, so you can tell at a glance whether you are in a development shell.

---

## Custom Packages

`Programs/Packages/` contains derivations for software not in nixpkgs or requiring customization.

**airgeddon** is a Bash-based wireless auditing framework. The derivation patches the default `.airgeddonrc` to disable auto-update (inappropriate in a Nix environment), change windows handling from `xterm` to `tmux`, and redirect runtime file paths to `~/.config/airgeddon/` so the Nix store path is read-only.

**evillimiter** is a Python application that throttles bandwidth of LAN hosts via ARP spoofing. The derivation builds it without a setup.py (the upstream repository does not use one), manually installing the Python source tree and creating a wrapper with `makeWrapper`.

**hostapd-wpe** builds `hostapd` from upstream sources with WPE (Wireless Pwnage Edition) patches applied manually via `sed` rather than patch files. The result is a `hostapd-wpe` binary that logs EAP credentials during evil-twin attacks.

**Cisco Packet Tracer 8** (`Programs/Packages/CiscoPacketTracer8.nix`) is a `requireFile`-based derivation (the `.deb` must be placed in the Nix store manually because Cisco requires account registration to download). It unpacks the Debian package, patches ELF files, and wraps the binary in a FHS environment to satisfy its runtime library expectations.

**whisper-cpp**, **LM Studio**, **Super Productivity**, **Logisim Evolution**, **jSQL Injection**, and **Proton GE** are additional derivations packaging pre-built binaries with appropriate wrappers and desktop entries.

### In-House Python Scripts

`Programs/custom/Python/` contains three small scripts installed as system commands via `writeScriptBin`.

`ctj` uses `pyvips` to convert any image format to JPEG with sRGB color space normalization, alpha channel flattening to white, and 95% quality output.

`MD-PDF` converts Markdown to PDF via WeasyPrint, supporting explicit page breaks, tables, footnotes, fenced code blocks, and A4 paper size. It accepts an optional CSS stylesheet argument.

`mac-formatter` normalizes a colon-separated MAC address to a lowercase hexadecimal string without separators.

---

## Nix Configuration

`experimental-features` enables only `nix-command` (not flakes). Builds are capped at 12 cores and 4 parallel jobs to prevent memory exhaustion during large builds like xformers or vllm. Sandboxing is enabled. The `big-parallel` and `kvm` system features are declared so packages that require them can be built locally.

`nixpkgs.config.allowUnfree = true` is set globally, as several packages (NVIDIA drivers, CUDA, Cisco Packet Tracer, Grayjay, LM Studio) require it.

Several packages are overridden in the top-level overlay in `configuration.nix`: `wine` is built with Wayland support and without X11 or CUPS; `ffmpeg-full` has Whisper support disabled to reduce the closure; `jackett` has its test suite disabled because the tests require network access.

---

## Secrets Management

The `Sec/` directory is listed in `.gitignore` and never committed. It contains:

- `secrets.nix`: A Nix attribute set with Wi-Fi passwords, MAC addresses, git email addresses, database passwords, and API keys, imported by files that need them. **Must** define `username` and `hostname`. These are the system's primary user and hostname, consumed by `ID/ID.nix` and referenced throughout the config.
- `network-manager.env`: An environment file referenced by NetworkManager's `ensureProfiles.environmentFiles`, containing the actual PSK values interpolated into profile configurations.
- `hardware-detected.nix`: Auto-generated by the hardware detection script at activation time.

---

## Getting Started

The repository must live at `/etc/nixos/`. Initializing it as a git repository requires changing `.git/` ownership after creating it as root.

```bash
cd /etc/nixos
sudo git init
sudo chown -R $(whoami) .git/
```

The `Sec/` directory must be populated manually before the first build. At minimum, `secrets.nix` must exist and export the expected attributes (including `username` and `hostname`), and `network-manager.env` must contain the network credentials.

On first boot after a rebuild, the hardware detection script runs as part of system activation and writes `Sec/hardware-detected.nix`. Subsequent rebuilds can then use the hardware-conditional logic.

The `switch` shell function handles day-to-day rebuilds:

```bash
switch    # equivalent to: sudo nixos-rebuild switch --show-trace 2>&1 | nom
update    # nix-channel --update followed by switch --upgrade
garbage   # nix-collect-garbage -d && nix-store --optimise
```

in case you saved configurations in `hardware-configuration.nix`, the following command will regenerate it, just avoid using that file entirely and use a layer like `control-hardware.nix` (just another file) to define your configuration

```
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
```

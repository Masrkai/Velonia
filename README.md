# Velonia

![NixOS](https://img.shields.io/badge/-NixOS-5277C3?style=flat-square&logo=nixos&logoColor=black) ![Nix](https://img.shields.io/badge/-Nix-7EBAFF?style=flat-square&logo=nixos&logoColor=black) ![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square) ![Repo Size](https://img.shields.io/github/repo-size/Masrkai/Velonia?style=flat-square) ![GitHub Stars](https://img.shields.io/github/stars/Masrkai/Velonia?style=social) ![Architecture](https://img.shields.io/badge/arch-x86__64-orange?style=flat-square) ![Neovim](https://img.shields.io/badge/neovim-%2357A143.svg?style=flat-square&logo=neovim&logoColor=white)

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

## Table of Contents

1. [Repository Layout](#repository-layout)
2. [Hardware Detection](#hardware-detection)
3. [Boot and Kernel](#boot-and-kernel)
4. [Graphics](#graphics)
5. [Desktop & Browsers](#desktop--browsers)
6. [Networking & Security](#networking--security)
7. [Development Environment](#development-environment)
8. [Python/ML Package Overlays](#pythonml-package-overlays)
9. [Services & Daemons](#services--daemons)
10. [Terminal Environment](#terminal-environment)
11. [Custom Packages & Scripts](#custom-packages--scripts)
12. [Nix Configuration](#nix-configuration)
13. [Secrets Management](#secrets-management)
14. [Getting Started](#getting-started)

---

## Repository Layout

The repository lives at `/etc/nixos/` and is structured so that each concern owns its own directory. The root `configuration.nix` is the single entry point that imports everything else.

The `ztop.nix` convention is used throughout: every directory that groups multiple files provides a `ztop.nix` that imports all siblings, so the parent only needs to import that single file.

> **Note**: The file `control-hardware.nix` is for overriding logic in `hardware-configuration.nix` without modifying auto-generated boilerplate directly, per the guidelines outlined in the [Getting Started](#getting-started) section.

---

## Hardware Detection

Because the same repository is shared across multiple machines:

- **ASUS TUF Gaming A15** (I burned that one haha sad)
- **Dell G15**
- **IdeaPad 5**
- **ThinkPad T14 G1 AMD** (Currently developing this configuration on)

An activation-time shell script (`ID/detect-hardware.sh`) reads `/sys/class/dmi/id/product_name`, matches it against known DMI patterns, and writes a small Nix file to `Sec/hardware-detected.nix`. That generated file sets four boolean options (`hardware.isAsusTuf`, `hardware.isDellG15`, `hardware.isThinkPad`, `hardware.isIdeaPad5`) declared in `ID/ID.nix` and consumed wherever hardware-specific behavior is required.

---

## Boot and Kernel

The system uses **systemd-boot** with EFI. Several categories of kernel parameters are set explicitly.

Key configuration files:

- [security.nix](security.nix)
- [control-hardware.nix](control-hardware.nix)
- [Network_Kernel_Parameters.nix](Networking/hardening/Network_Kernel_Parameters.nix)

These parameters are tailored to specific system requirements and explicitly documented so system diagnostics remain straightforward.

---

## Graphics

NVIDIA GPUs are configured via [graphics.nix](graphics.nix):

- **ASUS TUF**: Single dedicated GPU (no integrated graphics).
- **Dell G15 & Lenovo IdeaPad 5**: Hybrid dedicated + integrated graphics.

`hardware.nvidia` is configured with the latest proprietary driver, modesetting enabled, `powerManagement.enable = true`, and `dynamicBoost.enable = true`. `forceFullCompositionPipeline` is left off deliberately; tear-free rendering is handled at the X server screen-section level.

`nixpkgs.config.cudaSupport = true` is set globally, enabling CUDA support across matching packages with binary cache substituters enabled.

---

## Desktop & Browsers

### Desktop Environment

KDE Plasma 6 runs on Wayland via SDDM with the KWin compositor. X.Org server is explicitly disabled (`services.xserver.enable = lib.mkForce false`). `programs.xwayland` remains enabled for legacy compatibility.

- **Portals**: Multiple XDG desktop portals (GTK, GNOME, KDE) are configured in parallel.
- **Environment Variables**: `NIXOS_OZONE_WL=1` (Chromium Ozone Wayland), `QT_QPA_PLATFORM="wayland;xcb"`, and `GSK_RENDERER=nvidia`.
- **Credentials**: KWallet PAM integration is disabled (`security.pam.services.sddm.kwallet.enable = false`) in favor of KeePassXC.

### Dual-Browser Routing (`Services/Browser.nix`)

- **ThinkPad**: Runs Zen Browser with pre-configured privacy extensions (uBlock Origin, ClearURLs, Consent-O-Matic, KeePassXC-browser, User-Agent Switcher, Port Authority).
- **Other Machines**: Runs Brave.

---

## Networking & Security

### DNS Architecture

Resolution flows through three isolated layers:

1. **Unbound** (`Networking/DNS/cache.nix` - `127.0.0.1:53`): DNSSEC validation, caching, query-name minimization, and ad-blocking (StevenBlack hosts fetched at build time).
2. **dnscrypt-proxy** (`Networking/DNS/resolver.nix` - `127.0.0.1:5354`): Encrypted DNS upstream (`require_nolog`, `require_nofilter`, `require_dnssec`).
3. **Upstream Resolvers**.

`systemd-resolved` and `resolvconf` are disabled. NetworkManager uses `dns = "default"`.

### Time Synchronization & Cloudflare Warp

- **Chrony & NTS Enforcement**: Replaces `systemd-timesyncd` with strict Network Time Security (NTS) enforcement (`iburst nts` configured in `Networking/TimeSync.nix`) via `time.cloudflare.com` to cryptographically secure system clock synchronization.
- **Cloudflare Warp** (`Networking/cloudflare-warp.nix`): Configured with WARN-level log filtering.

### Firewall

Handled by `nftables` with higher-level rules layered on top:

- TCP 53/5353/853 (DNS / DoT)
- TCP 443 (OpenVPN)
- TCP 8384, 22000 (Syncthing GUI & sync)
- TCP 8888, 18081 (Development - slated for removal)
- UDP 67/68 (DHCP hotspot mode)
- UDP 6881 (qBittorrent)
- UDP 21027 (Syncthing discovery)
- TCP/UDP 1714-1764 (KDE Connect)
- TCP/UDP 21114-21119 (RustDesk)

`fail2ban` is enabled, and dropped/refused packets are logged.

### Kernel Network Parameters

Managed in `Networking/hardening/Network_Kernel_Parameters.nix`:

- **Congestion Control**: BBR with `fq` qdisc.
- **Buffers**: Raised to 16 MB max.
- **IPv6**: Disabled system-wide.
- **RP Filter**: Loose mode (value 2).
- **SYN Cookies & Keepalives**: Enforced.

---

## Development Environment

### Languages (`Dev/Langs/`)

- **C++**: GCC 14 + LLVM/Clang 20, CMake, Ninja, GTest, GTK/Qt, Eigen, nlohmann_json.
- **Python**: Python 3.12 environment (PyQt, PySide, pandas, OpenCV, JAX, ONNX, SQLite, pymysql, Jupyter). Installed with `lib.lowPrio` to avoid virtualenv conflicts.
- **Rust / Go / Dart & Flutter / Java / Nix / SQL**: Full toolchain setups with LSPs (`nixd`, `gopls`, `rust-analyzer`, etc.) and formatters (`alejandra`).

### Domain-Specific Tools (`Dev/Specialized/`)

- **MySQL (MariaDB)**: Port 3306 (localhost only), InnoDB tuning, slow query logging, `utf8mb4`.
- **PostgreSQL**: Defined in modules (default `enable = false`).
- **UML & Diagrams**: Mermaid CLI, PlantUML, Graphviz.
- **Big Data & Docs**: Hadoop, Pig, Spark, Doxygen, Monolith.
- **Pandoc**: Markdown-to-PDF toolchain with XeLaTeX and PlantUML filter support.

### IDE: VSCodium

Configured via `Dev/IDEs/vscodium.nix` with modular extensions (`Dev/IDEs/VScode_Extensions/`) and declarative user settings (`Dev/IDEs/vscode_config.jsonc`).

---

## Python/ML Package Overlays

`Dev/overlays.nix` overrides Python packages to incorporate pre-built binary wheels (`torch-bin`, `torchaudio-bin`, `torchvision-bin`, `jaxlib-bin`) and custom derivations (`unsloth`, `flash-attn`, `vllm`, `xformers`, `smolagents`, `trl`, etc.):

- **unsloth-zoo**: Patched for CRLF line endings (`dos2unix`), sudo removal, and PEP 621 license compliance.
- **xformers**: Parallel building disabled (`MAX_JOBS=2`) to prevent OOM errors.
- **vllm**: Patched for cmakeFlags, PYTHONPATH propagation, and sandboxed `lsmod` removal.

---

## Services & Daemons

### Status Overview

- **Active / Core**: Ollama (AI stack on port 11434 with CUDA), SearXNG (metasearch on port 8880), PipeWire (audio with RTKit), Syncthing, QEMU/KVM Virtualization, Radicale (CalDAV/CardDAV on port 5232).
- **Hardware-Conditional**: Power Management (`asusd` disabled, `power-profiles-daemon` enabled per machine).
- **Disabled / Templated Stubs**: Nextcloud, Open-WebUI, Apache Tika, Podman, ArcadeDB, PostgreSQL.

### Additional Integrations

- **OBS Studio** (`Services/OBS.nix`): Configured with virtual camera support and plugins (`wlrobs`, `input-overlay`, `obs-pipewire-audio-capture`, `obs-gstreamer`, `obs-vkcapture`).
- **Secret Service Integration** (`Services/SSI.nix`): KeePassXC configured as the `org.freedesktop.secrets` D-Bus provider on ASUS TUF hardware.
- **Gaming & Penetration Testing**: Steam (Proton GE, Gamescope), Heroic, Bottles, and wireless auditing toolkits (`airgeddon`, `hostapd-wpe`).

---

## Terminal Environment

### Bash (`Terminal/bash.nix`)

- **Aliases**: `eza` integration (`ls`/`la`), `ripgrep` (`grep`), verbose `cp`/`mv`, `cpv` (rsync progress).
- **Custom Functions**: `switch`/`update`/`garbage` (nix-output-monitor wrappers), archive compression/extraction (`compress`/`extract`), media converters (`convert_to_mp4`, `pandocmarkdowntopdf`), yt-dlp wrappers, and utility helpers (`s` for sudo re-run, `sync_nixos_config`, `clean_stale_mount`).

### Starship Prompt

Two-line prompt showing directory, git remote icons & status, language indicators, and nix-shell status (`❄️ pure shell`, `❄️ impure shell`).

---

## Custom Packages & Scripts

- **Packages (`Programs/Packages/`)**: `airgeddon`, `evillimiter`, `hostapd-wpe`, Cisco Packet Tracer 8 (`requireFile` derivation), and pre-built binaries (whisper-cpp, LM Studio, Proton GE).
- **Python Scripts (`Programs/custom/Python/`)**: `ctj` (pyvips image conversion), `MD-PDF` (WeasyPrint Markdown-to-PDF), and `mac-formatter`.

---

## Nix Configuration

- **Experimental Features**: `nix-command`.
- **Build Limits**: Capped at 12 cores and 4 parallel jobs to prevent memory exhaustion.
- **Unfree**: `nixpkgs.config.allowUnfree = true` enabled globally.

---

## Secrets Management

The `Sec/` directory is `.gitignore`d and contains:

- `secrets.nix`: Attribute set containing Wi-Fi passwords, MAC addresses, git email, and API keys. **Must** define `username` and `hostname`.
- `network-manager.env`: Environment file for NetworkManager PSK values.
- `hardware-detected.nix`: Auto-generated by activation script.

---

## Getting Started

The repository must reside at `/etc/nixos/`:

```bash
cd /etc/nixos
sudo git init
sudo chown -R $(whoami) .git/
```

1. Populate `Sec/secrets.nix` and `Sec/network-manager.env`.
2. On first boot, the hardware detection script runs automatically and generates `Sec/hardware-detected.nix`.
3. Day-to-day management helpers:

   ```bash
   switch    # Rebuilds system (sudo nixos-rebuild switch --show-trace 2>&1 | nom)
   update    # Channel update + upgrade switch
   garbage   # Garbage collection and store optimization
   ```

# Audio Suite (`modules/programs/media`)

The `modules/programs/media` directory contains a modular suite of tools designed to provide a high-fidelity, native, and visually integrated audio experience on NixOS. This suite is powered by **PipeWire**, allowing for lossless and high-resolution audio processing natively.

## Directory Structure

The audio suite is split into modular directories that manage backend playback, frontend UI, desktop integration, and audio post-processing.

### Music Player Daemon (MPD)

- **`rmpd/default.nix`**: Provides a Nix derivation for `rmpd`, a modern Rust reimplementation of the Music Player Daemon (MPD). 
  - Exposes a native MPRIS interface on the session D-Bus without external bridges, allowing desktops, `playerctl`, and multimedia keys to natively control playback.
  - Directly interfaces with the PipeWire sound server to enable native high-resolution and lossless audio formats up to 384kHz, disabling internal resampling to maintain optimal output.
  - Automatically configured to scan `~/Music` and managed securely via a systemd user service.

### Termimal Audio Clients

- **`rmpc/default.nix`**: Configures a highly customizable Rust terminal user interface (TUI) client for MPD.
  - Configured via Rusty Object Notation (RON) with dynamic album art panes, queue management, and a rich tabular song display.
  - Integrated deeply with the system's aesthetic through a multi-pane layout featuring a comprehensive 2-row Header (Track Progress, Bitrate, Volume Bar, and States).
- **`rmpc/themes/catppuccin.ron`**: The layout and styling engine for `rmpc`, meticulously configured to apply the Catppuccin Macchiato color palette for a unified terminal experience.
- **`euphonica/default.nix`**: Configures Euphonica, a lightweight minimal graphical UI designed for quick playback manipulation connected directly to the local `rmpd` daemon on port `6600`.

### Audio Post-Processing (DSP)

- **`easyeffects/default.nix`**: Integrates EasyEffects, an advanced audio manipulation tool built for PipeWire.
  - Allows precise equalizer configurations to sculpt sound signatures without introducing audible loss, using 32-bit floating-point mathematics natively.
  - Enabled as a background service via Home Manager, ensuring EQ presets automatically persist on login.

## How it Works

The audio suite relies on PipeWire's dynamic sample-rate switching configured globally in the system. Because the backend (`rmpd`) explicitly outputs to `pipewire` with zero internal resampling, the source format of the audio file determines the processing pipeline natively. 

The clients (`rmpc` and `euphonica`) communicate seamlessly with `rmpd` over the local `6600` port. You can use the terminal clients or system-wide MPRIS integrations to control the queue and playback. When advanced DSP such as equalization is required, `easyeffects` acts as a highly optimized node in the PipeWire graph, applying modifications transparently without forcing an unwanted downsample.

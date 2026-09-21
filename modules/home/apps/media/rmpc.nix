{ config, pkgs, lib, ... }:

let
  # 1. Matugen RON template for rmpc
  rmpc-matugen-template = pkgs.writeText "rmpc-theme-template.ron" ''
    #![enable(implicit_some)]
    #![enable(unwrap_newtypes)]
    #![enable(unwrap_variant_newtypes)]
    (
        default_album_art_path: None,
        draw_borders: false,
        show_song_table_header: false,
        symbols: (song: "🎵", dir: "📁", playlist: "🎼", marker: "\u{e0b0}"),
        layout: Split(
            direction: Vertical,
            panes: [
                (
                    size: "4",
                    borders: "ALL",
                    pane: Pane(Header),
                ),
                (
                    size: "3",
                    background_color: "{{colors.surface.default.hex}}",
                    pane: Pane(Tabs),
                ),
                (
                    size: "100%",
                    borders: "ALL",
                    pane: Pane(TabContent),
                ),
                (
                    size: "3",
                    borders: "ALL",
                    pane: Pane(ProgressBar),
                ),
            ],
        ),
        progress_bar: (
            symbols: ["", "", "⭘", " ", " "],
            track_style: (bg: "{{colors.surface_container_highest.default.hex}}"),
            elapsed_style: (fg: "{{colors.primary.default.hex}}", bg: "{{colors.surface_container_highest.default.hex}}"),
            thumb_style: (fg: "{{colors.tertiary.default.hex}}", bg: "{{colors.surface_container_highest.default.hex}}"),
        ),
        scrollbar: (
            symbols: ["│", "█", "▲", "▼"],
            track_style: (),
            ends_style: (),
            thumb_style: (fg: "{{colors.secondary.default.hex}}"),
        ),
        browser_column_widths: [20, 38, 42],
        text_color: "{{colors.on_surface.default.hex}}",
        background_color: "{{colors.surface.default.hex}}",
        header_background_color: None,
        modal_background_color: None,
        modal_backdrop: false,
        tab_bar: (
            active_style: (fg: "{{colors.on_primary.default.hex}}", bg: "{{colors.primary.default.hex}}", modifiers: "Bold"),
            inactive_style: (fg: "{{colors.on_surface_variant.default.hex}}"),
        ),
        borders_style: (fg: "{{colors.outline_variant.default.hex}}"),
        highlighted_item_style: (fg: "{{colors.primary.default.hex}}", modifiers: "Bold"),
        current_item_style: (fg: "{{colors.on_secondary_container.default.hex}}", bg: "{{colors.secondary_container.default.hex}}", modifiers: "Bold"),
        highlight_border_style: (fg: "{{colors.primary.default.hex}}"),
        song_table_format: [
            (
                prop: (kind: Property(Artist), style: (fg: "{{colors.secondary.default.hex}}"), default: (kind: Text("Unknown"))),
                width: "50%",
                alignment: Right,
            ),
            (
                prop: (kind: Text("-"), style: (fg: "{{colors.outline.default.hex}}"), default: (kind: Text("Unknown"))),
                width: "1",
                alignment: Center,
            ),
            (
                prop: (kind: Property(Title), style: (fg: "{{colors.primary.default.hex}}"), default: (kind: Text("Unknown"))),
                width: "50%",
            ),
        ],
        header: (
            rows: [
                (
                    left: [
                        (kind: Text("["), style: (fg: "{{colors.primary.default.hex}}", modifiers: "Bold")),
                        (kind: Property(Status(State)), style: (fg: "{{colors.primary.default.hex}}", modifiers: "Bold")),
                        (kind: Text("]"), style: (fg: "{{colors.primary.default.hex}}", modifiers: "Bold"))
                    ],
                    center: [
                        (kind: Property(Song(Title)), style: (fg: "{{colors.primary.default.hex}}", modifiers: "Bold"), default: (kind: Text("No Song"), style: (fg: "{{colors.primary.default.hex}}", modifiers: "Bold")))
                    ],
                    right: [
                        (kind: Property(Widget(Volume)), style: (fg: "{{colors.secondary.default.hex}}"))
                    ]
                ),
                (
                    left: [
                        (kind: Property(Status(Elapsed)), style: (fg: "{{colors.on_surface_variant.default.hex}}")),
                        (kind: Text(" / "), style: (fg: "{{colors.outline.default.hex}}")),
                        (kind: Property(Status(Duration)), style: (fg: "{{colors.on_surface_variant.default.hex}}")),
                        (kind: Text(" ("), style: (fg: "{{colors.outline.default.hex}}")),
                        (kind: Property(Status(Bitrate)), style: (fg: "{{colors.on_surface_variant.default.hex}}")),
                        (kind: Text(" kbps)"), style: (fg: "{{colors.outline.default.hex}}"))
                    ],
                    center: [
                        (kind: Property(Song(Artist)), style: (fg: "{{colors.primary.default.hex}}", modifiers: "Bold"), default: (kind: Text("Unknown"), style: (fg: "{{colors.primary.default.hex}}", modifiers: "Bold"))),
                        (kind: Text(" - "), style: (fg: "{{colors.outline.default.hex}}")),
                        (kind: Property(Song(Album)), style: (fg: "{{colors.on_surface_variant.default.hex}}"), default: (kind: Text("Unknown Album"), style: (fg: "{{colors.on_surface_variant.default.hex}}")))
                    ],
                    right: [
                        (kind: Property(Widget(States(active_style: (fg: "{{colors.primary.default.hex}}", modifiers: "Bold"), separator_style: (fg: "{{colors.outline_variant.default.hex}}")))))
                    ]
                )
            ],
        ),
    )
  '';

  # 2. Dedicated Matugen configuration pointing to the template and output path
  matugen-rmpc-config = pkgs.writeText "matugen-rmpc.toml" ''
    [config]
    reload_apps = false

    [templates.rmpc]
    input_path = "${rmpc-matugen-template}"
    output_path = "${config.home.homeDirectory}/.config/rmpc/themes/current.ron"
  '';

  # 3. Dynamic theme switcher script
  rmpc-theme-switcher = pkgs.writeShellApplication {
    name = "rmpc-theme-switcher";
    runtimeInputs = [
      pkgs.rmpc
      pkgs.matugen
      pkgs.coreutils
    ];
    text = ''
      ART_PATH="/tmp/rmpc_current_cover.jpg"
      mkdir -p "$HOME/.config/rmpc/themes"

      # Extract album cover
      rmpc albumart "$ART_PATH" 2>/dev/null || rmpc albumart --output "$ART_PATH" 2>/dev/null || exit 0
      [ -f "$ART_PATH" ] || exit 0

      # Generate theme using the dedicated matugen config
      matugen -c "${matugen-rmpc-config}" image "$ART_PATH" -m dark --prefer chroma
    '';
  };
in
{
  home.packages = [
    pkgs.rmpc
    pkgs.cava
    pkgs.matugen
    rmpc-theme-switcher
  ];

  # 4. Bootstrap initial fallback theme so rmpc never opens with a missing theme
  home.activation.initRmpcTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/rmpc/themes"
    if [ ! -f "$HOME/.config/rmpc/themes/current.ron" ]; then
      ${pkgs.matugen}/bin/matugen -c "${matugen-rmpc-config}" color hex "#fabd2f" -m dark || true
    fi
  '';

  # 5. Main rmpc configuration
  xdg.configFile."rmpc/config.ron".text = ''
    #![enable(implicit_some)]
    #![enable(unwrap_newtypes)]
    #![enable(unwrap_variant_newtypes)]
    (
      address: "127.0.0.1:6600",
      theme: "current",
      enable_config_hot_reload: true,
      on_song_change: ["${rmpc-theme-switcher}/bin/rmpc-theme-switcher"],
      enable_mouse: true,
      cava: (
        framerate: 60,
        autosens: true,
        sensitivity: 100,
        input: (
          method: Pulse,
          source: "auto",
        ),
      ),
      keybinds: (
        global: {
          "q": Quit,
          "?": ShowHelp,
          "<Space>": TogglePause,
          "p": TogglePause,
          "z": ToggleRepeat,
          "x": ToggleRandom,
          "c": ToggleConsume,
          "v": ToggleSingle,
          ">": NextTrack,
          "<": PreviousTrack,
          ".": VolumeUp,
          ",": VolumeDown,
          "<Tab>": NextTab,
          "gt": NextTab,
          "<S-Tab>": PreviousTab,
          "gT": PreviousTab,
          "1": SwitchToTab("Home"),
          "2": SwitchToTab("Directories"),
          "3": SwitchToTab("Playlists"),
          "4": SwitchToTab("Artists"),
          "5": SwitchToTab("Queue"),
          "6": SwitchToTab("Cava"),
          "7": SwitchToTab("Search"),
        },
      ),
      tabs: [
        (name: "Home", pane: Split(direction: Horizontal, panes: [
            (size: "65%", borders: "NONE", pane: Split(direction: Vertical, panes: [
                (size: "3", borders: "ALL", border_symbols: Rounded, pane: Pane(QueueHeader())),
                (size: "100%", borders: "ALL", border_symbols: Rounded, pane: Pane(Queue)),
            ])),
            (size: "35%", borders: "NONE", border_symbols: Rounded, pane: Split(direction: Vertical, panes: [
                (size: "0.47r", borders: "TOP | RIGHT | LEFT", border_symbols: Rounded, pane: Pane(AlbumArt)),
                (size: "100%", borders: "ALL",
                    border_symbols: Rounded,
                    border_title: [
                        (kind: Text("┐")),
                        (kind: Text("Lyrics")),
                        (kind: Text("┌")),
                    ],
                    border_title_position: Top,
                    border_title_alignment: Right,
                    pane: Pane(Lyrics)
                ),
            ])),
        ])),
        (name: "Directories", pane: Split(direction: Horizontal, panes: [
            (size: "100%", borders: "ALL", border_symbols: Rounded, pane: Pane(Directories)),
        ])),
        (name: "Playlists", pane: Split(direction: Horizontal, panes: [
            (size: "100%", borders: "ALL", border_symbols: Rounded, pane: Pane(Playlists)),
        ])),
        (name: "Artists", pane: Split(direction: Horizontal, panes: [
            (size: "100%", borders: "ALL", border_symbols: Rounded, pane: Pane(Browser(
                root_tag: "Artist",
                levels: [
                    (group_by: [[Artist]], skip: SingleEmpty),
                    (group_by: [[Album], [Other("date"), Other("originaldate")]],
                        format: [
                            (kind: Group([
                                (kind: Text("(")),
                                (kind: Property(Other("date"))),
                                (kind: Text(") ")),
                            ])),
                            (kind: Property(Album)),
                        ],
                    ),
                ],
            ))),
        ])),
        (name: "Queue", pane: Split(direction: Vertical, panes: [
            (size: "2", borders: "TOP | RIGHT | LEFT", border_symbols: Rounded, pane: Pane(QueueHeader())),
            (size: "100%", borders: "ALL", border_symbols: Rounded,
                border_title: [
                    (kind: Text("● ")),
                    (kind: Property(Song(File))),
                    (kind: Text(" ●─")),
                ],
                border_title_position: Bottom,
                border_title_alignment: Right,
                pane: Pane(Queue)
            ),
        ])),
        (name: "Cava", pane: Split(direction: Vertical, panes: [
            (size: "50%", pane: Split(direction: Horizontal, panes: [
                (size: "39%", borders: "ALL", border_symbols: Rounded, pane: Pane(Queue)),
                (size: "22%", borders: "ALL", border_symbols: Rounded, pane: Pane(AlbumArt)),
                (size: "39%", borders: "ALL",
                    border_title: [
                        (kind: Text("┐")),
                        (kind: Text("Lyrics")),
                        (kind: Text("┌─")),
                    ],
                    border_title_position: Top,
                    border_title_alignment: Right,
                    border_symbols: Rounded,
                    pane: Pane(Lyrics)
                ),
            ])),
            (size: "50%", borders: "ALL", border_symbols: Rounded, pane: Pane(Cava)),
        ])),
        (name: "Search", pane: Split(direction: Horizontal, panes: [
            (size: "100%", borders: "ALL", border_symbols: Rounded, pane: Pane(Search)),
        ])),
      ]
    )
  '';
}

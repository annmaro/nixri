{ pkgs, ... }:

{
  home.packages = [ pkgs.rmpc ];

  xdg.configFile."rmpc/config.ron".text = ''
    #![enable(implicit_some)]
    #![enable(unwrap_newtypes)]
    #![enable(unwrap_variant_newtypes)]
    (
      address: "127.0.0.1:6600",
      theme: Some("gruvbox"),
      enable_mouse: true,
      keybinds: (
        global: {
          "<Space>": TogglePause,
        },
      ),
      tabs: [
        (
            name: "Queue",
            pane: Split(
                direction: Horizontal,
                panes: [(size: "60%", pane: Pane(Queue)), (size: "40%", pane: Pane(AlbumArt))],
            ),
        ),
        (
            name: "Directories",
            pane: Pane(Directories),
        ),
        (
            name: "Artists",
            pane: Pane(Artists),
        ),
        (
            name: "Album Artists",
            pane: Pane(AlbumArtists),
        ),
        (
            name: "Albums",
            pane: Pane(Albums),
        ),
        (
            name: "Playlists",
            pane: Pane(Playlists),
        ),
        (
            name: "Search",
            pane: Pane(Search),
        ),
      ]
    )
  '';

  xdg.configFile."rmpc/themes/gruvbox.ron".text = ''
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
                    background_color: "#282828",
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
            track_style: (bg: "#3c3836"),
            elapsed_style: (fg: "#fabd2f", bg: "#3c3836"),
            thumb_style: (fg: "#fabd2f", bg: "#3c3836"),
        ),
        scrollbar: (
            symbols: ["│", "█", "▲", "▼"],
            track_style: (),
            ends_style: (),
            thumb_style: (fg: "#83a598"),
        ),
        browser_column_widths: [20, 38, 42],
        text_color: "#ebdbb2",
        background_color: "#282828",
        header_background_color: None,
        modal_background_color: None,
        modal_backdrop: false,
        tab_bar: (active_style: (fg: "black", bg: "#fabd2f", modifiers: "Bold"), inactive_style: ()),
        borders_style: (fg: "#928374"),
        highlighted_item_style: (fg: "#fabd2f", modifiers: "Bold"),
        current_item_style: (fg: "black", bg: "#83a598", modifiers: "Bold"),
        highlight_border_style: (fg: "#83a598"),
        song_table_format: [
            (
                prop: (kind: Property(Artist), style: (fg: "#83a598"), default: (kind: Text("Unknown"))),
                width: "50%",
                alignment: Right,
            ),
            (
                prop: (kind: Text("-"), style: (fg: "#83a598"), default: (kind: Text("Unknown"))),
                width: "1",
                alignment: Center,
            ),
            (
                prop: (kind: Property(Title), style: (fg: "#8ec07c"), default: (kind: Text("Unknown"))),
                width: "50%",
            ),
        ],
        header: (
            rows: [
                (
                    left: [
                        (kind: Text("["), style: (fg: "#fe8019", modifiers: "Bold")),
                        (kind: Property(Status(State)), style: (fg: "#fe8019", modifiers: "Bold")),
                        (kind: Text("]"), style: (fg: "#fe8019", modifiers: "Bold"))
                    ],
                    center: [
                        (kind: Property(Song(Title)), style: (fg: "#ebdbb2", modifiers: "Bold"), default: (kind: Text("No Song"), style: (fg: "#ebdbb2", modifiers: "Bold")))
                    ],
                    right: [
                        (kind: Property(Widget(Volume)), style: (fg: "#83a598"))
                    ]
                ),
                (
                    left: [
                        (kind: Property(Status(Elapsed)), style: (fg: "#ebdbb2")),
                        (kind: Text(" / "), style: (fg: "#ebdbb2")),
                        (kind: Property(Status(Duration)), style: (fg: "#ebdbb2")),
                        (kind: Text(" ("), style: (fg: "#ebdbb2")),
                        (kind: Property(Status(Bitrate)), style: (fg: "#ebdbb2")),
                        (kind: Text(" kbps)"), style: (fg: "#ebdbb2"))
                    ],
                    center: [
                        (kind: Property(Song(Artist)), style: (fg: "#fe8019", modifiers: "Bold"), default: (kind: Text("Unknown"), style: (fg: "#fe8019", modifiers: "Bold"))),
                        (kind: Text(" - "), style: (fg: "#ebdbb2")),
                        (kind: Property(Song(Album)), style: (fg: "#ebdbb2"), default: (kind: Text("Unknown Album"), style: (fg: "#ebdbb2")))
                    ],
                    right: [
                        (kind: Property(Widget(States(active_style: (fg: "#ebdbb2", modifiers: "Bold"), separator_style: (fg: "#665c54")))))
                    ]
                )
            ],
        ),
    )
  '';
}

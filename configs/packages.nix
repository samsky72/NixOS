# Common packages configs imports.
{ config, ... }: {
  imports = [
    ../packages/alacritty.nix         # Use alacritty as terminal.
    ../packages/bspwm.nix             # Use bspwm.
    ../packages/dunst.nix             # Use dunst.
    ../packages/git.nix               # Use git.
    ../packages/kdeconnect.nix        # Use KDEConnect.
    ../packages/mpv.nix               # Use mpv as media player.
    ../packages/neovim.nix            # Use neovim as editor.
    ../packages/picom.nix             # Use picom.
    ../packages/polybar.nix           # Use polybar.
    ../packages/rofi.nix              # Use rofi.
    ../packages/zsh.nix               # Use zsh as shell.
  ];
}

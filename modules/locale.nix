# modules/locale.nix
{ ... }: {

  ##########################################
  ## Locale and time configuration
  ##########################################

  # Timezone
  time.timeZone = "Asia/Oral";

  # Default locale (LANG) + generate locales
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "kk_KZ.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  # Use XKB for console keymap (instead of console.keyMap)
  console.useXkbConfig = true;

  # Keyboard layouts and switching (applies to Wayland too)
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:win_space_toggle";
  };
}

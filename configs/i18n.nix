# Select internationalisation properties.
{ config, ... }: {
  i18n = { 
    defaultLocale = "en_US.UTF-8";          # Set default locale.
    supportedLocales = [
      "en_US.UTF-8/UTF-8"                   # US english locale support. 
      "kk_KZ.UTF-8/UTF-8"                   # Kazakh locale support.
      "ru_RU.UTF-8/UTF-8"                   # Russian local support.
    ];
  };
}

_:

{
  # Set temperature unit to Fahrenheit
  system.defaults.NSGlobalDomain.AppleTemperatureUnit = "Fahrenheit";

  # Force 24-hour time
  system.defaults.NSGlobalDomain.AppleICUForce24HourTime = true;

  # Set supported languages
  system.defaults.CustomUserPreferences.NSGlobalDomain.AppleLanguages = [ "en-US" ];

  # Set supported languages
  system.defaults.CustomUserPreferences.NSGlobalDomain.AppleLocale = "en-US";

  # Set the first day of the week to Monday
  system.defaults.CustomUserPreferences.NSGlobalDomain.AppleFirstWeekday = {
    gregorian = 2;
  };

  # Set the date format to "MM/dd/yyyy"
  system.defaults.CustomUserPreferences.NSGlobalDomain.AppleICUDateFormatStrings = {
    "1" = "y-MM-dd";
  };
}

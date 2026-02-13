_: {
  system = {
    defaults = {
      NSGlobalDomain = {
        # Set temperature unit to Fahrenheit
        AppleTemperatureUnit = "Fahrenheit";

        # Force 24-hour time
        AppleICUForce24HourTime = true;
      };

      CustomUserPreferences = {
        NSGlobalDomain = {
          # Set supported languages
          AppleLanguages = [ "en-US" ];

          # Set supported languages
          AppleLocale = "en-US";

          # Set the first day of the week to Monday
          AppleFirstWeekday = {
            gregorian = 2;
          };

          # Set the date format to "MM/dd/yyyy"
          AppleICUDateFormatStrings = {
            "1" = "y-MM-dd";
          };
        };
      };
    };
  };
}

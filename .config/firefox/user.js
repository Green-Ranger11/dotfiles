// Firefox prefs applied on every start (linked into the profile by
// ~/.config/scripts/firefox-link). Changing these in Settings lasts only
// until the next restart; edit them here instead.
//
// The theme is not set here: Firefox only switches themes from Add-ons and
// themes. Use Catppuccin Mocha - Green (addons.mozilla.org) to match the bar.

// Load chrome/userChrome.css.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Compact toolbars.
user_pref("browser.compactmode.show", true);
user_pref("browser.uidensity", 1);

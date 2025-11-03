#!/bin/bash

# Comprehensive diagnostic script to check current macOS settings
# Compares current values against what's configured in .macos

echo "=============================================================================="
echo "  macOS Settings Diagnostic Report"
echo "  Compare current values with settings in .macos"
echo "=============================================================================="
echo ""

###############################################################################
# Computer Name
###############################################################################
echo "=== COMPUTER NAME ==="
echo "ComputerName:     $(scutil --get ComputerName 2>/dev/null || echo 'NOT SET')"
echo "HostName:         $(scutil --get HostName 2>/dev/null || echo 'NOT SET')"
echo "LocalHostName:    $(scutil --get LocalHostName 2>/dev/null || echo 'NOT SET')"
echo ".macos sets to:   \${COMPUTER_NAME:-mba}"
echo ""

###############################################################################
# General UI/UX
###############################################################################
echo "=== GENERAL UI/UX ==="
echo "Boot sound:                           $(sudo nvram SystemAudioVolume 2>/dev/null | cut -d$'\t' -f2 || echo 'NOT SET') (.macos: ' ' = disabled)"
echo "Sidebar icon size:                    $(defaults read NSGlobalDomain NSTableViewDefaultSizeMode 2>/dev/null || echo 'NOT SET') (.macos: 2 = medium)"
echo "Window resize time:                   $(defaults read NSGlobalDomain NSWindowResizeTime 2>/dev/null || echo 'NOT SET') (.macos: 0.001)"
echo "Expand save panel:                    $(defaults read NSGlobalDomain NSNavPanelExpandedStateForSaveMode 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Expand save panel 2:                  $(defaults read NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Expand print panel:                   $(defaults read NSGlobalDomain PMPrintingExpandedStateForPrint 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Expand print panel 2:                 $(defaults read NSGlobalDomain PMPrintingExpandedStateForPrint2 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Printer app auto-quit:                $(defaults read com.apple.print.PrintingPrefs "Quit When Finished" 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Disable quarantine dialog:            $(defaults read com.apple.LaunchServices LSQuarantine 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Show ASCII control chars:             $(defaults read NSGlobalDomain NSTextShowsControlCharacters 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Help Viewer dev mode:                 $(defaults read com.apple.helpviewer DevMode 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Login window shows host info:         $(sudo defaults read /Library/Preferences/com.apple.loginwindow AdminHostInfo 2>/dev/null || echo 'NOT SET') (.macos: HostName)"
echo ""

###############################################################################
# Auto-correction (for developers)
###############################################################################
echo "=== AUTO-CORRECTION (should be disabled for coding) ==="
echo "Auto-capitalization:                  $(defaults read NSGlobalDomain NSAutomaticCapitalizationEnabled 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Auto-dash substitution:               $(defaults read NSGlobalDomain NSAutomaticDashSubstitutionEnabled 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Auto-period substitution:             $(defaults read NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Smart quotes:                         $(defaults read NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Spell correction:                     $(defaults read NSGlobalDomain NSAutomaticSpellingCorrectionEnabled 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo ""

###############################################################################
# Trackpad, Mouse, Keyboard
###############################################################################
echo "=== TRACKPAD, MOUSE, KEYBOARD ==="
echo "Natural scrolling:                    $(defaults read NSGlobalDomain com.apple.swipescrolldirection 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Bluetooth audio bitpool min:          $(defaults read com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" 2>/dev/null || echo 'NOT SET') (.macos: 45)"
echo "Full keyboard access:                 $(defaults read NSGlobalDomain AppleKeyboardUIMode 2>/dev/null || echo 'NOT SET') (.macos: 3)"
echo "Press-and-hold disabled:              $(defaults read NSGlobalDomain ApplePressAndHoldEnabled 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Key repeat rate:                      $(defaults read NSGlobalDomain KeyRepeat 2>/dev/null || echo 'NOT SET') (.macos: 1 = fastest)"
echo "Initial key repeat:                   $(defaults read NSGlobalDomain InitialKeyRepeat 2>/dev/null || echo 'NOT SET') (.macos: 10)"
echo ""

###############################################################################
# Locale & Language
###############################################################################
echo "=== LOCALE & LANGUAGE ==="
echo "Languages:                            $(defaults read NSGlobalDomain AppleLanguages 2>/dev/null | tr '\n' ' ' || echo 'NOT SET') (.macos: en, pl)"
echo "Locale:                               $(defaults read NSGlobalDomain AppleLocale 2>/dev/null || echo 'NOT SET') (.macos: pl_PL@currency=PLN)"
echo "Measurement units:                    $(defaults read NSGlobalDomain AppleMeasurementUnits 2>/dev/null || echo 'NOT SET') (.macos: Centimeters)"
echo "Temperature unit:                     $(defaults read NSGlobalDomain AppleTemperatureUnit 2>/dev/null || echo 'NOT SET') (.macos: Celsius)"
echo "Metric units:                         $(defaults read NSGlobalDomain AppleMetricUnits 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Timezone:                             $(sudo systemsetup -gettimezone 2>/dev/null | cut -d':' -f2 | xargs || echo 'NOT SET') (.macos: Europe/Warsaw)"
echo ""

###############################################################################
# Energy Saving
###############################################################################
echo "=== ENERGY SAVING ==="
echo "Lid wake:                             $(pmset -g | grep lidwake | awk '{print $2}' || echo 'NOT SET') (.macos: 1)"
echo "Auto restart on power loss:           $(pmset -g | grep autorestart | awk '{print $2}' || echo 'NOT SET') (.macos: 1)"
echo "Restart on freeze:                    $(sudo systemsetup -getrestartfreeze 2>/dev/null | cut -d':' -f2 | xargs || echo 'NOT SET') (.macos: On)"
echo "Display sleep (minutes):              $(pmset -g | grep displaysleep | awk '{print $2}' || echo 'NOT SET') (.macos: 15)"
echo "Computer sleep (AC):                  $(pmset -g ac | grep ' sleep ' | awk '{print $2}' || echo 'NOT SET') (.macos: 0 = never)"
echo "Computer sleep (battery):             $(pmset -g batt | grep ' sleep ' | awk '{print $2}' || echo 'NOT SET') (.macos: 5)"
echo "Standby delay (seconds):              $(pmset -g | grep standbydelay | awk '{print $2}' || echo 'NOT SET') (.macos: 86400 = 24h)"
echo "Hibernate mode:                       $(pmset -g | grep hibernatemode | awk '{print $2}' || echo 'NOT SET') (.macos: 0)"
echo ""

###############################################################################
# Screen
###############################################################################
echo "=== SCREEN ==="
echo "Font smoothing disabled:              $(defaults read -g CGFontRenderingFontSmoothingDisabled 2>/dev/null || echo 'NOT SET') (.macos: FALSE)"
echo "Require password after sleep:         $(defaults read com.apple.screensaver askForPassword 2>/dev/null || echo 'NOT SET') (.macos: 1)"
echo "Password delay (seconds):             $(defaults read com.apple.screensaver askForPasswordDelay 2>/dev/null || echo 'NOT SET') (.macos: 0 = immediately)"
echo "Font smoothing level:                 $(defaults read NSGlobalDomain AppleFontSmoothing 2>/dev/null || echo 'NOT SET') (.macos: 1)"
echo ""

###############################################################################
# Finder
###############################################################################
echo "=== FINDER ==="
echo "Disable animations:                   $(defaults read com.apple.finder DisableAllAnimations 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Hide desktop icons:                   $(defaults read com.apple.finder CreateDesktop 2>/dev/null || echo 'NOT SET') (.macos: false = hidden)"
echo "Show path bar:                        $(defaults read com.apple.finder ShowPathbar 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Folders on top:                       $(defaults read com.apple.finder _FXSortFoldersFirst 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Default search scope:                 $(defaults read com.apple.finder FXDefaultSearchScope 2>/dev/null || echo 'NOT SET') (.macos: SCcf = current folder)"
echo "Warn on extension change:             $(defaults read com.apple.finder FXEnableExtensionChangeWarning 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "No .DS_Store on network:              $(defaults read com.apple.desktopservices DSDontWriteNetworkStores 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "No .DS_Store on USB:                  $(defaults read com.apple.desktopservices DSDontWriteUSBStores 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Music auto-launch disabled:           $(defaults read com.apple.Music dontAutomaticallyPlaySongsOnLaunch 2>/dev/null || echo 'NOT SET') (.macos: TRUE)"
echo "Skip disk verification:               $(defaults read com.apple.frameworks.diskimages skip-verify 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Skip disk verification (locked):      $(defaults read com.apple.frameworks.diskimages skip-verify-locked 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Skip disk verification (remote):      $(defaults read com.apple.frameworks.diskimages skip-verify-remote 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Auto-open RO volumes:                 $(defaults read com.apple.frameworks.diskimages auto-open-ro-root 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Auto-open RW volumes:                 $(defaults read com.apple.frameworks.diskimages auto-open-rw-root 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Auto-open removable disk:             $(defaults read com.apple.finder OpenWindowForNewRemovableDisk 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Preferred view style:                 $(defaults read com.apple.finder FXPreferredViewStyle 2>/dev/null || echo 'NOT SET') (.macos: Nlsv = list)"
echo "Warn before emptying trash:           $(defaults read com.apple.finder WarnOnEmptyTrash 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "AirDrop over Ethernet:                $(defaults read com.apple.NetworkBrowser BrowseAllInterfaces 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo ""

echo "Finder icon view settings (PlistBuddy):"
echo "  Desktop arrange by:                 $(/usr/libexec/PlistBuddy -c "Print :DesktopViewSettings:IconViewSettings:arrangeBy" ~/Library/Preferences/com.apple.finder.plist 2>/dev/null || echo 'NOT SET') (.macos: grid)"
echo "  Desktop grid spacing:               $(/usr/libexec/PlistBuddy -c "Print :DesktopViewSettings:IconViewSettings:gridSpacing" ~/Library/Preferences/com.apple.finder.plist 2>/dev/null || echo 'NOT SET') (.macos: 100)"
echo "  Desktop icon size:                  $(/usr/libexec/PlistBuddy -c "Print :DesktopViewSettings:IconViewSettings:iconSize" ~/Library/Preferences/com.apple.finder.plist 2>/dev/null || echo 'NOT SET') (.macos: 64)"
echo ""

###############################################################################
# Menu Bar
###############################################################################
echo "=== MENU BAR ==="
echo "Hide menu bar:                        $(defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Battery show percentage:              $(defaults read com.apple.controlcenter.plist BatteryShowPercentage 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Sound icon:                           $(defaults read com.apple.controlcenter.plist Sound 2>/dev/null || echo 'NOT SET') (.macos: 18)"
echo "Bluetooth icon:                       $(defaults read com.apple.controlcenter.plist Bluetooth 2>/dev/null || echo 'NOT SET') (.macos: 18)"
echo ""

###############################################################################
# Dock & Dashboard
###############################################################################
echo "=== DOCK & DASHBOARD ==="
echo "Mouse-over stack effect:              $(defaults read com.apple.dock mouse-over-hilite-stack 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Icon size (pixels):                   $(defaults read com.apple.dock tilesize 2>/dev/null || echo 'NOT SET') (.macos: 30)"
echo "Minimize effect:                      $(defaults read com.apple.dock mineffect 2>/dev/null || echo 'NOT SET') (.macos: scale)"
echo "Minimize to application:              $(defaults read com.apple.dock minimize-to-application 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Show process indicators:              $(defaults read com.apple.dock show-process-indicators 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Persistent apps (empty = cleared):    $(defaults read com.apple.dock persistent-apps 2>/dev/null | head -1 || echo 'NOT SET') (.macos: cleared)"
echo "Static only (open apps only):         $(defaults read com.apple.dock static-only 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Disable launch animation:             $(defaults read com.apple.dock launchanim 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Mission Control animation duration:   $(defaults read com.apple.dock expose-animation-duration 2>/dev/null || echo 'NOT SET') (.macos: 0.1)"
echo "Dashboard disabled:                   $(defaults read com.apple.dashboard mcx-disabled 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Dashboard in overlay:                 $(defaults read com.apple.dock dashboard-in-overlay 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Don't rearrange Spaces:               $(defaults read com.apple.dock mru-spaces 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Auto-hide delay:                      $(defaults read com.apple.dock autohide-delay 2>/dev/null || echo 'NOT SET') (.macos: 0)"
echo "Auto-hide animation time:             $(defaults read com.apple.dock autohide-time-modifier 2>/dev/null || echo 'NOT SET') (.macos: 0)"
echo "Auto-hide enabled:                    $(defaults read com.apple.dock autohide 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Show hidden app icons translucent:    $(defaults read com.apple.dock showhidden 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Show recent apps:                     $(defaults read com.apple.dock show-recents 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo ""

###############################################################################
# Safari & WebKit
###############################################################################
echo "=== SAFARI & WEBKIT ==="
echo "Universal search disabled:            $(defaults read com.apple.Safari UniversalSearchEnabled 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Suppress search suggestions:          $(defaults read com.apple.Safari SuppressSearchSuggestions 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "WebKit tab to links:                  $(defaults read com.apple.Safari WebKitTabToLinksPreferenceKey 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "WebKit2 tab to links:                 $(defaults read com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Show full URL:                        $(defaults read com.apple.Safari ShowFullURLInSmartSearchField 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Auto-open safe downloads:             $(defaults read com.apple.Safari AutoOpenSafeDownloads 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Proxies in bookmarks bar:             $(defaults read com.apple.Safari ProxiesInBookmarksBar 2>/dev/null || echo 'NOT SET') (.macos: ())"
echo "Include develop menu:                 $(defaults read com.apple.Safari IncludeDevelopMenu 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "WebKit developer extras:              $(defaults read com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "WebKit2 developer extras:             $(defaults read com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Global WebKit developer extras:       $(defaults read NSGlobalDomain WebKitDeveloperExtras 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Auto-correct disabled:                $(defaults read com.apple.Safari WebAutomaticSpellingCorrectionEnabled 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "AutoFill from address book:           $(defaults read com.apple.Safari AutoFillFromAddressBook 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "AutoFill passwords:                   $(defaults read com.apple.Safari AutoFillPasswords 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "AutoFill credit cards:                $(defaults read com.apple.Safari AutoFillCreditCardData 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "AutoFill forms:                       $(defaults read com.apple.Safari AutoFillMiscellaneousForms 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Warn about fraudulent sites:          $(defaults read com.apple.Safari WarnAboutFraudulentWebsites 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Java disabled:                        $(defaults read com.apple.Safari WebKitJavaEnabled 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "WebKit2 Java disabled:                $(defaults read com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "WebKit2 Java local disabled:          $(defaults read com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Block popups:                         $(defaults read com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "WebKit2 block popups:                 $(defaults read com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Inline media disabled:                $(defaults read com.apple.Safari WebKitMediaPlaybackAllowsInline 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Do Not Track:                         $(defaults read com.apple.Safari SendDoNotTrackHTTPHeader 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Auto-update extensions:               $(defaults read com.apple.Safari InstallExtensionUpdatesAutomatically 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo ""

###############################################################################
# Mail
###############################################################################
echo "=== MAIL ==="
echo "Disable reply animations:             $(defaults read com.apple.mail DisableReplyAnimations 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Disable send animations:              $(defaults read com.apple.mail DisableSendAnimations 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Addresses without name:               $(defaults read com.apple.mail AddressesIncludeNameOnPasteboard 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo "Disable inline attachments:           $(defaults read com.apple.mail DisableInlineAttachmentViewing 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Spell checking:                       $(defaults read com.apple.mail SpellCheckingBehavior 2>/dev/null || echo 'NOT SET') (.macos: NoSpellCheckingEnabled)"
echo ""

###############################################################################
# Terminal & iTerm 2
###############################################################################
echo "=== TERMINAL & ITERM 2 ==="
echo "Terminal string encodings:            $(defaults read com.apple.terminal StringEncodings 2>/dev/null | tr '\n' ' ' || echo 'NOT SET') (.macos: 4 = UTF-8)"
echo "iTerm prompt on quit:                 $(defaults read com.googlecode.iterm2 PromptOnQuit 2>/dev/null || echo 'NOT SET') (.macos: false)"
echo ""

###############################################################################
# Time Machine
###############################################################################
echo "=== TIME MACHINE ==="
echo "Don't offer new disks:                $(defaults read com.apple.TimeMachine DoNotOfferNewDisksForBackup 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo ""

###############################################################################
# Activity Monitor
###############################################################################
echo "=== ACTIVITY MONITOR ==="
echo "Open main window on launch:           $(defaults read com.apple.ActivityMonitor OpenMainWindow 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Dock icon type:                       $(defaults read com.apple.ActivityMonitor IconType 2>/dev/null || echo 'NOT SET') (.macos: 5 = CPU usage)"
echo "Show category:                        $(defaults read com.apple.ActivityMonitor ShowCategory 2>/dev/null || echo 'NOT SET') (.macos: 0 = all processes)"
echo "Sort column:                          $(defaults read com.apple.ActivityMonitor SortColumn 2>/dev/null || echo 'NOT SET') (.macos: CPUUsage)"
echo "Sort direction:                       $(defaults read com.apple.ActivityMonitor SortDirection 2>/dev/null || echo 'NOT SET') (.macos: 0)"
echo ""

###############################################################################
# Mac App Store
###############################################################################
echo "=== MAC APP STORE ==="
echo "WebKit developer extras:              $(defaults read com.apple.appstore WebKitDeveloperExtras 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Automatic update check:               $(defaults read com.apple.SoftwareUpdate AutomaticCheckEnabled 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Check frequency (days):               $(defaults read com.apple.SoftwareUpdate ScheduleFrequency 2>/dev/null || echo 'NOT SET') (.macos: 1 = daily)"
echo "Automatic download:                   $(defaults read com.apple.SoftwareUpdate AutomaticDownload 2>/dev/null || echo 'NOT SET') (.macos: 1)"
echo "Critical update install:              $(defaults read com.apple.SoftwareUpdate CriticalUpdateInstall 2>/dev/null || echo 'NOT SET') (.macos: 1)"
echo "App auto-update:                      $(defaults read com.apple.commerce AutoUpdate 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo ""

###############################################################################
# Photos
###############################################################################
echo "=== PHOTOS ==="
echo "Disable hot plug:                     $(defaults -currentHost read com.apple.ImageCapture disableHotPlug 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo ""

###############################################################################
# Google Chrome
###############################################################################
echo "=== GOOGLE CHROME ==="
echo "Expand print dialog:                  $(defaults read com.google.Chrome PMPrintingExpandedStateForPrint2 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo "Canary expand print dialog:           $(defaults read com.google.Chrome.canary PMPrintingExpandedStateForPrint2 2>/dev/null || echo 'NOT SET') (.macos: true)"
echo ""

echo "=============================================================================="
echo "  End of Diagnostic Report"
echo "=============================================================================="
echo ""
echo "TIP: Redirect output to file for easier review:"
echo "  ./check-settings.sh > settings-report.txt"
echo ""

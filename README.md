# awesome-tconfig
awesome 3.5 powerbar theme with toml configuration

## Synopsis

This is a modified version of esn89/powerarrow-dark. 
The configuration is provided by an awesome module called tconfig, written by mepholic.

Currently, tconfig allows configuration of multiple "profiles". 
The current profile can be changed by setting the AWESOME_PROFILE environment variable. 
tconfig has a default_profile, the settings of which are inherited by all other profiles. 
Any variable set explicitly in a profile will override the default profile; 
by not setting a variable in a profile, the variable will assume it's value from the default profile.

tconfig can be customized very easily due to it's simplicity as a module. 
I believe there are still uses to be discovered for it. 
I hope this project can be beneficial in many ways to the awesome community, 
so I'm putting this out here for everyone to use, contribute to, and share ideas!

## Code Example

The API is simple:

```lua
local tconfig = require("tconfig")
local default_profile = tconfig.default_profile
local other_profile = tconfig.profile.<name>
```

default_profile is a table a variables defining the default configuration.
Other profiles can be created, based on the default profile; any variable not set in a profile will be default.

In this example, we'll write a default config and two profiles to config.toml

```toml
[default_profile]
cfg_dir = "/home/user/.config/awesome/"
theme_dir = "powerarrowf/"
theme_script = "theme.lua"
panel_size = "16"
panel_pos = "top"
browser = "google-chrome"
editor = "emacs"
terminal = "urxvt256c"
font = "Inconsolata 11"
batt_name = ""
fs_mon = "/home"
if_wired = "eth0"
if_wlan = ""
alsa_name = "Master"
tags = [ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] ]
wallpaper = [ "/home/user/.config/awesome/res/default.jpg" ]

[profiles]

[profiles.yoda]
cfg_dir = "/home/yoda/.config/awesome/"
font = "Terminus 9"
if_wlan = "wlan0"
tags = [ [ 'web', 'term', 'work', 'misc' ], ['chat', 'mail', 'news', 'notes'] ]
wallpaper = [ "/home/yoda/.config/awesome/res/screen1.jpg", "/home/yoda/.config/awesome/res/screen2.jpg" ]

[profiles.luke]
cfg_dir = "/home/luke/.config/awesome/"
theme_dir = "dark-side/"
wallpaper = [ "/home/luke/.config/awesome/res/default.jpg" ]
```

These pieces of configuration data are mapped into rc.lua in a very simple manner.

```lua
-- mepholic's stuff
local tconfig = require("tconfig")
local default_profile = tconfig.default_profile
local env_profile = os.getenv("AWESOME_PROFILE")
if env_profile ~= nil then
   if tconfig.profile[env_profile] ~= nil then
      conf = tconfig.profile[env_profile]
   else
      conf = default_profile
   end
else
   conf = default_profile
end
```

Adding the above code near the top of any lua file that needs tconfig data should allow the file to use the current AWESOME_PROFILE, however this can be modified if necessary.

## Motivation

I run awesome on many different machines. Some of them I use slightly differently than others, so I have different tab names and layouts. I also use different wallpapers, and have other various different settings between different machines.

I wanted a way to simplify and unify the configurations, so I decided that templating parts of the awesome config in a markup language seemed like a reasonable idea.

I chose ToML as the markup language, because there was a readily available, seemingly-stable LUA module which makes for really simple dependancies. It also seems like a fairly reasonable choice for the job.

## Installation

1. If you have an existing awesome configuration directory at ~/.config/awesome, back it up and remove it
2. Run the following command: __git clone https://github.com/mepholic/awesome-tconfig.git ~/.config/awesome__
3. You may want to install some of the tools and programs ran in *~/.config/awesome/autostart.lua*
4. Configure *~/.config/awesome/config.toml* to your liking.
5. Export an appropriate AWESOME_PROFILE to environment. Usuaully ~/.xprofile or ~/.xsession, sometimes ~/.xinitrc
6. Restart awesome.

## Screenshots
![#1](https://raw.githubusercontent.com/mepholic/awesome-tconfig/master/screenshots/Awesome35_powerarrow_mod-1.png)

## Contributors

  + Maintainer: mepholic
  + Fork from: esn89/powerline-dark

Contact me on freenode, PM mepholic

## License

MIT License

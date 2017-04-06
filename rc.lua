-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")

-- mepholic's stuff
local conf = { }
local tconfig = require("tconfig")
local default_profile = tconfig.default_profile
local env_profile = os.getenv("AWESOME_PROFILE")
if env_profile ~= nil then
   if tconfig.profile[env_profile] ~= nil then
      naughty.notify({ preset = naughty.config.presets.low,
                       title = "Welcome to Awesome!",
                       text = "Your profile (".. env_profile ..") has been loaded!" })
      conf = tconfig.profile[env_profile]
   else
      naughty.notify({ preset = naughty.config.presets.critical,
                       title = "Undefined profile specified during startup!",
                       text = env_profile ..
                          " is an undefined AWESOME_PROFILE in config.toml.\n"..
                          "Loading default profile." })
      conf = default_profile
   end
else
   naughty.notify({ preset = naughty.config.presets.critical,
                    title = "No profile specified during startup!",
                    text = "Awesome was unable to read the AWESOME_PROFILE "..
                       "environment variable.\nLoading default profile." })
   conf = default_profile
end

-- Autostart
dofile(conf.cfg_dir .. "autostart.lua")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
                    title = "Oops, there were errors during startup!",
                    text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
                             -- Make sure we don't go into an endless error loop
                             if in_error then return end
                             in_error = true

                             naughty.notify({ preset = naughty.config.presets.critical,
                                              title = "Oops, an error happened!",
                                              text = err })
                             in_error = false
   end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers

--{{---| Theme | -------------------------------------

-- Set the config directory
config_dir = (conf.cfg_dir)

-- if the path starts with a /, treat it as absolute
if string.find(conf.theme_dir, "/") == 1 then
   themes_dir = (conf.theme_dir)
else
   themes_dir = (config_dir .. conf.theme_dir)
end

beautiful.init(themes_dir .. conf.theme_script)

-- This is used later as the default terminal, browser and editor to run.
terminal = conf.terminal
editor = os.getenv("EDITOR") or conf.editor
editor_cmd = terminal .. " -e " .. editor
browser = conf.browser

font = conf.panel_font

-- {{ These are the power arrow dividers/separators }} --
arr1 = wibox.widget.imagebox()
arr1:set_image(beautiful.arr1)
arr2 = wibox.widget.imagebox()
arr2:set_image(beautiful.arr2)
arr3 = wibox.widget.imagebox()
arr3:set_image(beautiful.arr3)
arr4 = wibox.widget.imagebox()
arr4:set_image(beautiful.arr4)
arr5 = wibox.widget.imagebox()
arr5:set_image(beautiful.arr5)
arr6 = wibox.widget.imagebox()
arr6:set_image(beautiful.arr6)
arr7 = wibox.widget.imagebox()
arr7:set_image(beautiful.arr7)
arr8 = wibox.widget.imagebox()
arr8:set_image(beautiful.arr8)
arr9 = wibox.widget.imagebox()
arr9:set_image(beautiful.arr9)


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
   {
      awful.layout.suit.floating,
      awful.layout.suit.tile,
      awful.layout.suit.tile.left,
      awful.layout.suit.tile.bottom,
      awful.layout.suit.tile.top,
      awful.layout.suit.max
   }
-- }}}

-- {{{ Wallpaper
if conf.wallpaper then
   for s = 1, screen.count() do
      gears.wallpaper.maximized(conf.wallpaper[s], s, true)
   end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
   -- Each screen has its own tag table.
   tags[s] = awful.tag(conf.tags[s], s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .." ".. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = {
                             { "awesome", myawesomemenu, beautiful.awesome_icon },
                             { "open terminal", terminal } }
                       })

mylauncher = awful.widget.launcher({ menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal
-- }}}

-- {{{ Wibox

--{{-- Time and Date Widget }} --
tdwidget = wibox.widget.textbox()

local strf = '<span font="'.. font ..'" color="#EEEEEE" '..
   'background="#777E76">%b %d %H:%M</span>'

vicious.register(tdwidget, vicious.widgets.date, strf, 20)

clockicon = wibox.widget.imagebox()
clockicon:set_image(beautiful.clock)

--{{ Net Widget }} --
netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net, function(widget, args)
                    local interface = ""
                    if args["{".. conf.if_wlan .." carrier}"] == 1 then
                       interface = conf.if_wlan
                    elseif args["{".. conf.if_wired .." carrier}"] == 1 then
                       interface = conf.if_wired
                    else
                       return ""
                    end
                    return '<span background="#C2C2A4">' ..
		       '<span font ="' .. font .. '" color="#FFFFFF">' ..
                       args["{"..interface.." down_kb}"]..'kbps'..'</span></span>'
                                                 end, -- ^ func
                 10) -- end vic.reg


---{{--|- Wifi Signal Widget -|--}}---
neticon = wibox.widget.imagebox()
vicious.register(neticon, vicious.widgets.wifi, function(widget, args)
                    local sigstrength = tonumber(args["{link}"])
                    if sigstrength > 69 then
                       neticon:set_image(beautiful.nethigh)
                    elseif sigstrength > 40 and sigstrength < 70 then
                       neticon:set_image(beautiful.netmedium)
                    else
                       neticon:set_image(beautiful.netlow)
                    end
                                                end, -- ^ func
                 120, conf.if_wlan) -- end vic.reg


--{{ Battery Widget }} --
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.baticon)

batwidget = wibox.widget.textbox()
if conf.batt_name == "" then
   -- TODO: This surely isn't right, if there's no battery, just display text
   vicious.register( batwidget, vicious.widgets.bat,
                     '<span background="#92B0A0"><span font="' .. font ..
                        '" color="#FFFFFF" background="#92B0A0">$1 ' ..
                        '</span></span>',
                     30, conf.batt_name )
else
   vicious.register( batwidget, vicious.widgets.bat,
                     '<span background="#92B0A0"><span font="' .. font ..
                        '" color="#FFFFFF" background="#92B0A0">$1$2% ' ..
                        '</span></span>',
                     30, conf.batt_name )
end

--{{---| File Size widget |-----
fswidget = wibox.widget.textbox()

vicious.register(fswidget, vicious.widgets.fs,
                 '<span background="#D0785D"><span font="' .. font ..
                    '" color="#EEEEEE">${' .. conf.fs_mon .. ' used_gb}/${' ..
                    conf.fs_mon .. ' avail_gb} GB </span></span>', 
                 800)

fsicon = wibox.widget.imagebox()
fsicon:set_image(beautiful.fsicon)

----{{--| Volume / volume icon |----------
volume = wibox.widget.textbox()
vicious.register(volume, vicious.widgets.volume,
                 '<span background="#4B3B51"><span font="' .. font ..
                    '" color="#EEEEEE"> Vol:$1 </span></span>',
                 10, conf.alsa_name)

volumeicon = wibox.widget.imagebox()
vicious.register(volumeicon, vicious.widgets.volume, function(widget, args)
                    local paraone = tonumber(args[1])

                    if args[2] == "♩" or paraone == 0 then
                       volumeicon:set_image(beautiful.mute)
                    elseif paraone >= 67 and paraone <= 100 then
                       volumeicon:set_image(beautiful.volhi)
                    elseif paraone >= 33 and paraone <= 66 then
                       volumeicon:set_image(beautiful.volmed)
                    else
                       volumeicon:set_image(beautiful.vollow)
                    end

                                                     end, -- ^ func
                 10, conf.alsa_name) -- end vic.reg

--{{---| CPU / sensors widget |-----------
cpuwidget = wibox.widget.textbox()

vicious.register(cpuwidget, vicious.widgets.cpu,
                 '<span background="#4B696D"><span font="' .. font ..
                    '" color="#DDDDDD">$1% </span></span>',
                 5)

cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.cpuicon)

--{{--| MEM widget |-----------------
memwidget = wibox.widget.textbox()

vicious.register(memwidget, vicious.widgets.mem,
                 '<span background="#777E76"><span font="' .. font ..
                    '" color="#EEEEEE" background="#777E76">$2 MB ' ..
                    '</span></span>',
                 20)

memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.mem)

--{{--| Mail widget |---------
mailicon = wibox.widget.imagebox()

vicious.register(mailicon, vicious.widgets.gmail, function(widget, args)
                    local newMail = tonumber(args["{count}"])
                    if newMail > 0 then
                       mailicon:set_image(beautiful.mail)
                    else
                       mailicon:set_image(beautiful.mailopen)
                    end
                                                  end, -- ^ func
                 15) -- end vic.reg

beautiful.bg_systray = "#313131"
mysystray = wibox.widget.systray()

-- to make GMail pop up when pressed:
--mailicon:buttons(awful.util.table.join(awful.button({ }, 1,
--                                        function ()
--                                           awful.util.spawn_with_shell(
--                                              browser .." gmail.com")  end)))


-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
   awful.button({ }, 1, awful.tag.viewonly),
   awful.button({ modkey }, 1, awful.client.movetotag),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, awful.client.toggletag),
   awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
   awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
         if c == client.focus then
            c.minimized = true
         else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() then
               awful.tag.viewonly(c:tags()[1])
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
         end
   end),
   awful.button({ }, 3, function ()
         if instance then
            instance:hide()
            instance = nil
         else
            instance = awful.menu.clients({ width=250 })
         end
   end),
   awful.button({ }, 4, function ()
         awful.client.focus.byidx(1)
         if client.focus then client.focus:raise() end
   end),
   awful.button({ }, 5, function ()
         awful.client.focus.byidx(-1)
         if client.focus then client.focus:raise() end
end))

for s = 1, screen.count() do
   -- Create a promptbox for each screen
   mypromptbox[s] = awful.widget.prompt()
   -- Create an imagebox widget which will contains an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   mylayoutbox[s] = awful.widget.layoutbox(s)
   mylayoutbox[s]:buttons(awful.util.table.join(
                             awful.button({ }, 1, function ()
                                   awful.layout.inc(layouts, 1) end),
                             awful.button({ }, 3, function ()
                                   awful.layout.inc(layouts, -1) end),
                             awful.button({ }, 4, function ()
                                   awful.layout.inc(layouts, 1) end),
                             awful.button({ }, 5, function ()
                                   awful.layout.inc(layouts, -1) end)))
   -- Create a taglist widget
   mytaglist[s] = awful.widget.taglist(s,awful.widget.taglist.filter.all,
                                       mytaglist.buttons)

   -- Create a tasklist widget
   mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags,
                                         mytasklist.buttons)

   -- Create the wibox
   mywibox[s] = awful.wibox({ position = conf.panel_pos, screen = s,
                              height = conf.panel_size })

   -- Widgets that are aligned to the left
   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(mylauncher)
   left_layout:add(mytaglist[s])
   left_layout:add(mypromptbox[s])

   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()
   right_layout:add(arr9)
   right_layout:add(mailicon)
   if s == 1 then right_layout:add(mysystray) end
   right_layout:add(arr8)
   right_layout:add(memicon)
   right_layout:add(memwidget)
   right_layout:add(arr7)
   right_layout:add(cpuicon)
   right_layout:add(cpuwidget)
   right_layout:add(arr6)
   right_layout:add(volumeicon)
   right_layout:add(volume)
   right_layout:add(arr5)
   right_layout:add(fsicon)
   right_layout:add(fswidget)
   right_layout:add(arr4)
   right_layout:add(baticon)
   right_layout:add(batwidget)
   right_layout:add(arr3)
   right_layout:add(neticon)
   right_layout:add(netwidget)
   right_layout:add(arr2)
   right_layout:add(clockicon)
   right_layout:add(tdwidget)
   right_layout:add(arr1)
   right_layout:add(mylayoutbox[s])

   -- Now bring it all together (with the tasklist in the middle)
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_middle(mytasklist[s])
   layout:set_right(right_layout)

   mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
                awful.button({ }, 3, function () mymainmenu:toggle() end),
                awful.button({ }, 4, awful.tag.viewnext),
                awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
   awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
   awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
   awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

   -- {{ Volume Control }} --

   awful.key({     }, "XF86AudioRaiseVolume", function()
         awful.util.spawn("amixer set Master 5%+", false)
   end),
   awful.key({     }, "XF86AudioLowerVolume", function()
         awful.util.spawn("amixer set Master 5%-", false)
   end),
   awful.key({     }, "XF86AudioMute", function()
         awful.util.spawn("amixer set Master toggle", false)
   end),

   -- {{ Vim-like controls:
   
   awful.key({ modkey,           }, "l",
      function ()  -- focus right window
         awful.client.focus.bydirection("right")
         if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey,           }, "h",
      function ()  -- focus left window
         awful.client.focus.bydirection("left")
         if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey,           }, "j",
      function ()  -- focus lower window
         awful.client.focus.bydirection("down")
         if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey,           }, "k",
      function ()  -- focus upper window
         awful.client.focus.bydirection("up")
         if client.focus then client.focus:raise() end
   end),

   -- Layout manipulation
   awful.key({ modkey, "Shift"   }, "j", function ()
         awful.client.swap.byidx(  1)  -- move window left
   end),
   awful.key({ modkey, "Shift"   }, "k", function ()
         awful.client.swap.byidx( -1)  -- move window right
   end),
   awful.key({ modkey, "Control" }, "j", function ()
         awful.screen.focus_relative( 1)  -- focus left monitor
   end),
   awful.key({ modkey, "Control" }, "k", function ()
         awful.screen.focus_relative(-1)  -- focus right monitor
   end),
   awful.key({ modkey,           }, "Tab",
      function ()  -- focus previous window on current pane
         awful.client.focus.history.previous()  
         if client.focus then
            client.focus:raise()
         end
   end),

   -- Standard program
   awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
   awful.key({ modkey, "Shift"   }, "r", awesome.restart),
   awful.key({ modkey, "Shift"   }, "e", awesome.quit),

   awful.key({ modkey,           }, "i",     function () awful.tag.incmwfact( 0.05)    end),
   awful.key({ modkey,           }, "u",     function () awful.tag.incmwfact(-0.05)    end),
   awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
   awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
   awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
   awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
   awful.key({ modkey, "Control" }, "space", function () awful.layout.inc(layouts,  1) end),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

   awful.key({ modkey, "Control" }, "n", awful.client.restore),

   -- Applications
   awful.key({ modkey, "Control" }, "Delete", function ()
         awful.util.spawn_with_shell("sync")
         awful.util.spawn_with_shell("xautolock -locknow")
   end),
   
   -- Prompt
   awful.key({ modkey },            "r",
      function () mypromptbox[mouse.screen]:run() end),

   awful.key({ modkey },            "x",
      function ()
         awful.prompt.run({ prompt = "Run Lua code: " },
            mypromptbox[mouse.screen].widget,
            awful.util.eval, nil,
            awful.util.getdir("cache") .. "/history_eval")
   end),
   -- Menubar
   awful.key({ modkey },            "p", function() menubar.show() end),

   -- dmenu
   awful.key(nil,            "Menu", function ()
                local f_reader = io.popen(
                   "dmenu_path | dmenu -b -fn '" .. font .. "' -p '>' -l 5 -nb '" ..
                      beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal .. "' -sb '" ..
                      beautiful.bg_focus .. "' -sf '" .. beautiful.fg_focus .. "'"
                )  -- dmenu skinned after your beautiful theme
                
                local command = assert(f_reader:read('*a'))
                f_reader:close()
                if command == "" then return end
                
                -- Check throught the clients if the class match the command
                local lower_command=string.lower(command)
                for k, c in pairs(client.get()) do
                   local class=string.lower(c.class)
                   if string.match(class, lower_command) then
                      for i, v in ipairs(c:tags()) do
                         awful.tag.viewonly(v)
                         c:raise()
                         c.minimized = false
                         return
                      end
                   end
                end
                awful.util.spawn(command)
   end)
   
)

clientkeys = awful.util.table.join(
   awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
   awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill()                         end),
   awful.key({ modkey,           }, "space",  awful.client.floating.toggle                     ),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
   awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
   awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
   awful.key({ modkey,           }, "n",
      function (c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
   end),
   awful.key({ modkey,           }, "m",
      function (c)
         c.maximized_horizontal = not c.maximized_horizontal
         c.maximized_vertical   = not c.maximized_vertical
         
   end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
   globalkeys = awful.util.table.join(globalkeys,
                                      awful.key({ modkey }, "#" .. i + 9,
                                         function ()
                                            local screen = mouse.screen
                                            local tag = awful.tag.gettags(screen)[i]
                                            if tag then
                                               awful.tag.viewonly(tag)
                                            end
                                      end),
                                      awful.key({ modkey, "Control" }, "#" .. i + 9,
                                         function ()
                                            local screen = mouse.screen
                                            local tag = awful.tag.gettags(screen)[i]
                                            if tag then
                                               awful.tag.viewtoggle(tag)
                                            end
                                      end),
                                      awful.key({ modkey, "Shift" }, "#" .. i + 9,
                                         function ()
                                            local tag = awful.tag.gettags(client.focus.screen)[i]
                                            if client.focus and tag then
                                               awful.client.movetotag(tag)
                                            end
                                      end),
                                      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                                         function ()
                                            local tag = awful.tag.gettags(client.focus.screen)[i]
                                            if client.focus and tag then
                                               awful.client.toggletag(tag)
                                            end
   end))
end

clientbuttons = awful.util.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
     properties = { border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                    focus = awful.client.focus.filter,
                    keys = clientkeys,
                    buttons = clientbuttons } },
   { rule = { class = "MPlayer" },
     properties = { floating = true } },
   { rule = { class = "pinentry" },
     properties = { floating = true } },
   { rule = { class = "linphone" },
     properties = { floating = true } },
   { rule = { class = "Msgcompose", "Icedove" },
     properties = { floating = true} }
}

-- Rules from config
if env_profile ~= nil and conf['awful_rules'] ~= false then
   for rule_num in pairs(conf.awful_rules) do
      -- get config rule
      local conf_rule = conf.awful_rules[rule_num]
      -- initialize real rule table
      local real_rule = { rule = {}, properties = {} };
      
      -- check for active rules
      local active = { rule_all = false, rule_any = false,
                       except_all = false, except_any = false}

      if conf_rule.rule_all ~= nil then active['rule_all'] = true end
      if conf_rule.rule_any ~= nil then active['rule_any'] = true end
      if conf_rule.except_all ~= nil then active['except_all'] = true end
      if conf_rule.except_any ~= nil then active['except_any'] = true end
      
      -- initialize conflict table
      local conflict = { rules = false, exceptions = false}
      
      -- check for conflicting rules
      if active['rule_all'] and active['rule_any'] then
         naughty.notify({ preset = naughty.config.presets.critical,
                          title = "Conflicting Awful rules!",
                          text = "You have some conflicting Awful rules.\n"..
                             "Please specify only one of either rule_all "..
                             "or rule_any per rule." })
         conflict['rules'] = true
      end
      
      -- check for conflicting exceptions
      if active['except_all'] and active['except_any'] then
         naughty.notify({ preset = naughty.config.presets.critical,
                          title = "Conflicting Awful rules!",
                          text = "You have some conflicting Awful rule exceptions.\n"..
                             "Please specify only one of either except_all "..
                             "or except_any per rule." })
         conflict['exceptions'] = true
      end
      
      -- parse rules
      if conflict['rules'] == false and conflict['exceptions'] == false then
         for rule_type in pairs(active) do
            if active[rule_type] == true then
               -- fix rule names
               local rule_dest = rule_type;
               if rule_type == 'rule_all' then rule_dest = 'rule'
               elseif rule_type == 'except_all' then rule_dest = 'except' end
               
               -- copy rule properties
               for rule_prop in pairs(conf_rule[rule_type]) do
                  real_rule[rule_dest] = conf_rule[rule_type][rule_prop] 
               end
            end
         end
      end
      
      -- check for loc to set the window location
      if conf_rule.loc ~= nil then
         local screen = conf_rule.loc.screen
         local tag    = conf_rule.loc.tag
         
         if screen ~= nil and tag ~= nil then
            real_rule['properties']['tag'] = tags[screen][tag]
         elseif screen ~= nil then
            real_rule['properties']['tag'] = tags[screen][1]
         elseif tag ~= nil then
            real_rule['properties']['tag'] = tags[1][tag]
         end
      end
      
      -- check for additional properties
      if conf_rule.props ~= nil then
         for key in pairs(conf_rule.props) do
            real_rule['properties'][key] = conf_rule['props'][key]
         end
      end
      
      -- insert rule
      table.insert(awful.rules.rules, real_rule)
   end   
end
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
                         -- Enable sloppy focus
                         c:connect_signal("mouse::enter", function(c)
                                             if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                                             and awful.client.focus.filter(c) then
                                                client.focus = c
                                             end
                         end)

                         if not startup then
                            -- Set the windows at the slave,
                            -- i.e. put it at the end of others instead of setting it master.
                            -- awful.client.setslave(c)

                            -- Put windows in a smart way, only if they does not set an initial position.
                            if not c.size_hints.user_position and not c.size_hints.program_position then
                               awful.placement.no_overlap(c)
                               awful.placement.no_offscreen(c)
                            end
                         end

                         local titlebars_enabled = conf.titlebars
                         if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
                            -- buttons for the titlebar
                            local buttons = awful.util.table.join(
                               awful.button({ }, 1, function()
                                     client.focus = c
                                     c:raise()
                                     awful.mouse.client.move(c)
                               end),
                               awful.button({ }, 3, function()
                                     client.focus = c
                                     c:raise()
                                     awful.mouse.client.resize(c)
                               end)
                            )

                            -- Widgets that are aligned to the left
                            local left_layout = wibox.layout.fixed.horizontal()
                            left_layout:add(awful.titlebar.widget.iconwidget(c))
                            left_layout:buttons(buttons)

                            -- Widgets that are aligned to the right
                            local right_layout = wibox.layout.fixed.horizontal()
                            right_layout:add(awful.titlebar.widget.floatingbutton(c))
                            right_layout:add(awful.titlebar.widget.maximizedbutton(c))
                            right_layout:add(awful.titlebar.widget.stickybutton(c))
                            right_layout:add(awful.titlebar.widget.ontopbutton(c))
                            right_layout:add(awful.titlebar.widget.closebutton(c))

                            -- The title goes in the middle
                            local middle_layout = wibox.layout.flex.horizontal()
                            local title = awful.titlebar.widget.titlewidget(c)
                            title:set_align("center")
                            middle_layout:add(title)
                            middle_layout:buttons(buttons)

                            -- Now bring it all together
                            local layout = wibox.layout.align.horizontal()
                            layout:set_left(left_layout)
                            layout:set_right(right_layout)
                            layout:set_middle(middle_layout)

                            awful.titlebar(c):set_widget(layout)
                         end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

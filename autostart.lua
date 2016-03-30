local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")

-- mepholic's stuff
local conf = { }
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


-- Run Once
function run_once(prg,arg_string,pname,screen)
   if not prg then
      do return nil end
   end
   
   if not pname then
      pname = prg
   end
   
   if not arg_string then
      awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")",screen)
   else
      awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. " ".. arg_string .."' || (" .. prg .. " " .. arg_string .. ")",screen)
   end
end

-- Autoload Here

-- {{ XRandr
if conf.xrandr_cfg ~= "" then
   for p = 1, table.getn(conf.xrandr_cfg) do
      local cfg_pair = conf.xrandr_cfg[p]
      
      if conf.xrandr_pri ~= "" then
	 if cfg_pair[1] == conf.xrandr_pri then cfg_pair[1] = cfg_pair[1] .." --primary" end
	 if cfg_pair[2] == conf.xrandr_pri then cfg_pair[2] = cfg_pair[2] .." --primary" end
      end
      
      awful.util.spawn_with_shell("xrandr --output ".. cfg_pair[1] .." --auto "
				     .."--output ".. cfg_pair[2]  .." --auto "
				     .. cfg_pair[3] .." ".. cfg_pair[4])
   end
elseif conf.xrandr_pri ~= "" then
   awful.util.spawn_with_shell("xrandr --output ".. conf.xrandr_pri .." --primary")
end
-- }}

awful.util.spawn_with_shell("xrdb ~/.Xdefaults")
awful.util.spawn_with_shell("xmodmap ~/.Xmodmap")

-- Lock screen
run_once("xautolock", "-detectsleep -time 5 -locker \"i3lock -t -i ".. conf.cfg_dir .."res/EagleNebula.png\" -notify 30 -notifier \"notify-send -u critical -t 10000 -- 'LOCKING screen in 30 seconds'\"")

-- Applets
run_once("nm-applet")


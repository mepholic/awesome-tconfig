local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")

-- mepholic's stuff
local tconfig = require("tconfig")
conf = tconfig.profile.work

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
awful.util.spawn_with_shell("xrandr ~/.Xdefaults")
awful.util.spawn_with_shell("xmodmap ~/.Xmodmap")
awful.util.spawn_with_shell("xrandr --output HDMI-1 --auto --left-of DVI-I-1 --auto")
awful.util.spawn_with_shell("xrandr --output HDMI-1 --primary")
run_once("xautolock", "-detectsleep -time 5 -locker \"i3lock -t -i ".. conf.cfg_dir .."res/EagleNebula.png\" -notify 30 -notifier \"notify-send -u critical -t 10000 -- 'LOCKING screen in 30 seconds'\"")
run_once("nm-applet")

-- {{ I need redshift to save my eyes }} -
run_once("redshift -l 49.26:-123.23")

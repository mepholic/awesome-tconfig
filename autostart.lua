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
awful.util.spawn_with_shell("xrandr --output DVI-I-1 --auto --right-of HDMI-1 --auto --primary")
awful.util.spawn_with_shell(conf.cfg_dir .. "bin/locker.sh")
run_once("nm-applet")

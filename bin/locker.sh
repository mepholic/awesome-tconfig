#!/bin/sh

exec xautolock -detectsleep -time 5 -locker "i3lock -t -i ~/.config/awesome/res/EagleNebula.png" -notify 30 -notifier "notify-send -u critical -t 10000 -- 'LOCKING screen in 30 seconds'"

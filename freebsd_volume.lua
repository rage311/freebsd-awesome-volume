--[[
Copyright (c) 2016, rage311
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]--


local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")

local volumewidget = awful.widget.progressbar()

volumewidget:set_width(40)
volumewidget:set_vertical(false)
volumewidget:set_ticks_gap(0)
volumewidget:set_max_value(100)
volumewidget.step = 1
volumewidget:set_background_color('#000000')
volumewidget:set_color('#CCCCCC')

-- initialize
local volumelayout = wibox.layout.margin(volumewidget, 2, 1, 1, 1)

local previousvol = nil
function volumelayout.toggle_mute()
  if tonumber(volval) > 0 then
    previousvol = volval
    os.execute("mixer vol 0:0")
    volumewidget:set_background_color('#880000')
  else
    os.execute("mixer vol " .. previousvol .. ":" .. previousvol)
    volumewidget:set_background_color('#000000')
  end
  volumelayout.get_vol()
end

function volumelayout.down()
  os.execute("mixer vol -5:-5")
  volumelayout.get_vol()
end

function volumelayout.up()
  os.execute("mixer vol +5:+5")
  volumelayout.get_vol()
end

function volumelayout.get_vol()
  local vol = awful.util.pread("/usr/sbin/mixer vol|/usr/bin/awk '{print $7}'|/usr/bin/cut -d: -f1")
  volumewidget:set_value(vol)
  volval = vol
end

volumewidget:buttons(awful.util.table.join(
  awful.button({ }, 1, volumelayout.toggle_mute),
  awful.button({ }, 4, volumelayout.up),
  awful.button({ }, 5, volumelayout.down)
))

mytimer = timer({ timeout = 1 })
mytimer:connect_signal("timeout", function() volumelayout.get_vol() end)
mytimer:start()

volumelayout.get_vol()

return volumelayout

--[[
Copyright (c) 2016 https://github.com/rage311
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.
]]--


local awful   = require("awful")
local naughty = require("naughty")
local wibox   = require("wibox")

local volumewidget = awful.widget.progressbar()

-- color constants for widget
local BG_COLOR_NORMAL = '#000000'
local BG_COLOR_MUTE   = '#880000'
local FG_COLOR_NORMAL = '#CCCCCC'

-- visual settings
volumewidget:set_width(40)
volumewidget:set_vertical(false)
volumewidget:set_ticks_gap(0)
volumewidget:set_max_value(100)
volumewidget.step = 1
volumewidget:set_background_color(BG_COLOR_NORMAL)
volumewidget:set_color(FG_COLOR_NORMAL)
 
-- initialize
local volumelayout = wibox.layout.margin(volumewidget, 2, 1, 1, 1)

-- previous volume to return to after unmuting
local previousvol = nil

-- toggle mute and store previous volume to return to when unmuting
function volumelayout.toggle_mute()
  if (tonumber(volval) > 0) then
    previousvol = volval
    awful.util.spawn(terminal .. " -e mixer vol 0:0")
  else
    awful.util.spawn(
      terminal .. " -e mixer vol " .. previousvol .. ":" .. previousvol)
  end
  volumelayout.get_vol()
end

-- incrementally decrease volume
function volumelayout.down()
  awful.util.spawn(terminal .. " -e mixer vol -5:-5")
  volumelayout.get_vol()
end

-- incrementally increase volume
function volumelayout.up()
  awful.util.spawn(terminal .. " -e mixer vol +5:+5")
  volumelayout.get_vol()
end

-- read volume from mixer and set widget accordingly
function volumelayout.get_vol()
  -- TODO: use GIO to do asynchronously for awesome 3.5
  local vol = awful.util.pread(
    "/usr/sbin/mixer vol | /usr/bin/awk '{print $7}' | /usr/bin/cut -d: -f1")
  volumewidget:set_value(vol)
  volval = vol
  if (tonumber(volval) > 0) then
    volumewidget:set_background_color(BG_COLOR_NORMAL)
  else
    volumewidget:set_background_color(BG_COLOR_MUTE)
  end
end

-- set mouse interaction assignments
volumewidget:buttons(awful.util.table.join(
  awful.button({ }, 1, volumelayout.toggle_mute),
  awful.button({ }, 4, volumelayout.up),
  awful.button({ }, 5, volumelayout.down)
))
 
-- set timer to update in case volume is changed elsewhere
mytimer = timer({ timeout = 1 })
mytimer:connect_signal("timeout", function() volumelayout.get_vol() end)
mytimer:start()

volumelayout.get_vol()

return volumelayout

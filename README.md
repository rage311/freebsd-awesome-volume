# freebsd-awesome-volume
A FreeBSD/OSS volume widget for the awesome window manager

This has only been tested on awesome 3.5.

## Usage

Copy `freebsd_volume.lua` into your `awesome` config folder.
By default, it should be:

    $HOME/.config/awesome/freebsd_volume.lua

Include the `freebsd_volume` widget in your awesome rc.lua config file:

    local freebsd_volume = require("freebsd_volume")

Add the widget to your layout:

    right_layout:add(freebsd_volume)

Optional bindings for controlling the volume widget from your keyboard's multimedia keys:

```
-- freebsd_volume
awful.key({ }, "XF86AudioRaiseVolume",  freebsd_volume.up),
awful.key({ }, "XF86AudioLowerVolume",  freebsd_volume.down),
awful.key({ }, "XF86AudioMute",         freebsd_volume.toggle_mute)
```

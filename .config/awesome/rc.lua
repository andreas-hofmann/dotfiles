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
vicious = require("vicious")
--Application Menu
require("debian.menu")


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
beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod1" -- Alt
mod_alt = "Mod4" -- Super

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
--tags = {}
tags = { names  = { "1:main",   "2:web",    "3:mail",   "4:terms",  "5:ssh",    "6:files",  "7:music",  "8:devel",   "9:vbox" },
         layout = { layouts[1], layouts[5], layouts[5], layouts[3], layouts[3], layouts[1], layouts[1], layouts[1], layouts[1] }
}

for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", awesome.quit },
    { "logout", os.getenv("HOME") .. "/.config/awesome/shutdown.sh" }
}

-- Freedesktop.org menu - Need some extra packages. Use the debian menu for now.
--menu_items = freedesktop.menu.new()
--table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
--mymainmenu = awful.menu.new({ items = menu_items, width = 200 })
mymainmenu = awful.menu.new({ items = {
    { "awesome", myawesomemenu, beautiful.awesome_icon },
    { "Debian", debian.menu.Debian_menu.Debian },
    { "open terminal", terminal }
} })
                                  
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Alsawidget

local alsawidget =
{
	channel = "Master",
	step = "5%",
	colors =
	{
		unmute = "#AECF96",
		mute = "#FF5656"
	},
	mixer = terminal .. " -e alsamixer", -- or whatever your preferred sound mixer is
	notifications =
	{
		icons =
		{
			-- the first item is the 'muted' icon
			"/usr/share/icons/gnome/48x48/status/audio-volume-muted.png",
			-- the rest of the items correspond to intermediate volume levels - you can have as many as you want (but must be >= 1)
			"/usr/share/icons/gnome/48x48/status/audio-volume-low.png",
			"/usr/share/icons/gnome/48x48/status/audio-volume-medium.png",
			"/usr/share/icons/gnome/48x48/status/audio-volume-high.png"
		},
		font = "Monospace 11", -- must be a monospace font for the bar to be sized consistently
		icon_size = 48,
		bar_size = 20 -- adjust to fit your font if the bar doesn't fit
	}
}
-- widget
alsawidget.bar = awful.widget.progressbar ()
alsawidget.bar:set_width (8)
alsawidget.bar:set_vertical (true)
alsawidget.bar:set_background_color ("#494B4F")
alsawidget.bar:set_color (alsawidget.colors.unmute)
alsawidget.bar:buttons (awful.util.table.join (
	awful.button ({}, 1, function()
		awful.util.spawn (alsawidget.mixer)
	end),
	awful.button ({}, 3, function()
                -- You may need to specify a card number if you're not using your main set of speakers.
                -- You'll have to apply this to every call to 'amixer sset'.
                -- awful.util.spawn ("amixer sset -c " .. yourcardnumber .. " " .. alsawidget.channel .. " toggle")
		awful.util.spawn ("amixer sset " .. alsawidget.channel .. " toggle")
		vicious.force ({ alsawidget.bar })
	end),
	awful.button ({}, 4, function()
		awful.util.spawn ("amixer sset " .. alsawidget.channel .. " " .. alsawidget.step .. "+")
		vicious.force ({ alsawidget.bar })
	end),
	awful.button ({}, 5, function()
		awful.util.spawn ("amixer sset " .. alsawidget.channel .. " " .. alsawidget.step .. "-")
		vicious.force ({ alsawidget.bar })
	end)
))
-- tooltip
alsawidget.tooltip = awful.tooltip ({ objects = { alsawidget.bar } })
-- naughty notifications
alsawidget._current_level = 0
alsawidget._muted = false
function alsawidget:notify ()
	local preset =
	{
		height = 75,
		width = 300,
		font = alsawidget.notifications.font
	}
	local i = 1;
	while alsawidget.notifications.icons[i + 1] ~= nil
	do
		i = i + 1
	end
	if i >= 2
	then
		preset.icon_size = alsawidget.notifications.icon_size
		if alsawidget._muted or alsawidget._current_level == 0
		then
			preset.icon = alsawidget.notifications.icons[1]
		elseif alsawidget._current_level == 100
		then
			preset.icon = alsawidget.notifications.icons[i]
		else
			local int = math.modf (alsawidget._current_level / 100 * (i - 1))
			preset.icon = alsawidget.notifications.icons[int + 2]
		end
	end
	if alsawidget._muted
	then
		preset.title = alsawidget.channel .. " - Muted"
	elseif alsawidget._current_level == 0
	then
		preset.title = alsawidget.channel .. " - 0% (muted)"
		preset.text = "[" .. string.rep (" ", alsawidget.notifications.bar_size) .. "]"
	elseif alsawidget._current_level == 100
	then
		preset.title = alsawidget.channel .. " - 100% (max)"
		preset.text = "[" .. string.rep ("|", alsawidget.notifications.bar_size) .. "]"
	else
		local int = math.modf (alsawidget._current_level / 100 * alsawidget.notifications.bar_size)
		preset.title = alsawidget.channel .. " - " .. alsawidget._current_level .. "%"
		preset.text = "[" .. string.rep ("|", int) .. string.rep (" ", alsawidget.notifications.bar_size - int) .. "]"
	end
	if alsawidget._notify ~= nil
	then
		
		alsawidget._notify = naughty.notify (
		{
			replaces_id = alsawidget._notify.id,
			preset = preset
		})
	else
		alsawidget._notify = naughty.notify ({ preset = preset })
	end
end
-- register the widget through vicious
vicious.register (alsawidget.bar, vicious.widgets.volume, function (widget, args)
	alsawidget._current_level = args[1]
	if args[2] == "♩"
	then
		alsawidget._muted = true
		alsawidget.tooltip:set_text (" [Muted] ")
		widget:set_color (alsawidget.colors.mute)
		return 100
	end
	alsawidget._muted = false
	alsawidget.tooltip:set_text (" " .. alsawidget.channel .. ": " .. args[1] .. "% ")
	widget:set_color (alsawidget.colors.unmute)
	return args[1]
end, 5, alsawidget.channel) -- relatively high update time, use of keys/mouse will force update

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


-- {{{ Wibox

-- seperator-widget
seperator = wibox.widget.textbox()
seperator:set_markup("<span color='#cad795'>|</span>")

--Spacer-widget
spacer = wibox.widget.textbox()
spacer:set_markup(" ")

--spacer = widget({ type = "textbox" })
--spacer.text = " | "

-- Create a battery widget
bat_widget = wibox.widget.textbox()
vicious.register(bat_widget, vicious.widgets.bat, "BAT $1$2 ", 32, "BAT1")

-- CPU Widget
cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, " CPU $1% ")

--Memory Usage
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, "MEM $1% ($2MB/$3MB) ", 13)

-- Create a textclock widget
mytextclock = awful.widget.textclock()

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
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(spacer)
    right_layout:add(seperator)
    right_layout:add(bat_widget)
    right_layout:add(seperator)
    right_layout:add(memwidget)
    right_layout:add(seperator)
    right_layout:add(cpuwidget)
    right_layout:add(seperator)
    right_layout:add(alsawidget.bar)
    right_layout:add(seperator)
    right_layout:add(mytextclock)
    right_layout:add(seperator)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "h",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "l",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "h", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Shift"   }, "l", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Control" }, "h", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey, "Control" }, "l", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control" }, "q", awesome.quit),
    awful.key({ modkey, "Shift"   }, "q", function () awful.util.spawn( "/home/andi/.config/awesome/shutdown.sh" ) end),

    awful.key({ modkey,           }, "k",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "j",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "k",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Shift"   }, "j",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Control" }, "k",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey, "Control" }, "j",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
    -- Dmenu
    awful.key({ modkey },            "d",     function() awful.util.spawn( "dmenu_run" ) end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),

    -- Program lauchers
    awful.key({ mod_alt,         }, "f", function () awful.util.spawn("firefox")            end),
    awful.key({ mod_alt,         }, "t", function () awful.util.spawn("icedove")            end),
    awful.key({ mod_alt,         }, "e", function () awful.util.spawn("evolution")          end),
    awful.key({ mod_alt,         }, "v", function () awful.util.spawn("gvim")               end),
    awful.key({ mod_alt,         }, "s", function () awful.util.spawn("spotify")            end),
    awful.key({ mod_alt,         }, "h", function () awful.util.spawn("thunar")             end),
    awful.key({ mod_alt,         }, "g", function () awful.util.spawn("google-chrome")      end),
    awful.key({ mod_alt,         }, "c", function () awful.util.spawn("chromium")           end),
    awful.key({ mod_alt,         }, "l", function () awful.util.spawn("xautolock -locknow") end),

    -- Multimedia keys
    --awful.key({ }, "XF86AudioMute",        function () awful.util.spawn("amixer set Master toggle") end),
    --awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer set Master 5%+") end),
    --awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer set Master 5%-") end),

    awful.key({ }, "XF86AudioPrev",
                    function () awful.util.spawn([[dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify
                                                   org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous]]) end),
    awful.key({ }, "XF86AudioNext",
                    function () awful.util.spawn([[dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify
                                                   org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next]]) end),
    awful.key({ }, "XF86AudioPlay",
                    function () awful.util.spawn([[dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify
                                                   org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause]]) end)
)

-- Join in key bindings for alsa widget 
globalkeys = awful.util.table.join(globalkeys, awful.key({ }, "XF86AudioRaiseVolume", function()
    awful.util.spawn("amixer sset " .. alsawidget.channel .. " " .. alsawidget.step .. "+")
    vicious.force({ alsawidget.bar })
    alsawidget.notify()
end))
globalkeys = awful.util.table.join(globalkeys, awful.key({ }, "XF86AudioLowerVolume", function()
    awful.util.spawn("amixer sset " .. alsawidget.channel .. " " .. alsawidget.step .. "-")
    vicious.force({ alsawidget.bar })
    alsawidget.notify()
end))
globalkeys = awful.util.table.join(globalkeys, awful.key({ }, "XF86AudioMute", function()
    awful.util.spawn("amixer sset " .. alsawidget.channel .. " toggle")
    -- The 2 following lines were needed at least on my configuration, otherwise it would get stuck muted
    -- However, if the channel you're using is "Speaker" or "Headpphone"
    -- instead of "Master", you'll have to comment out their corresponding line below.
    awful.util.spawn("amixer sset " .. "Speaker" .. " unmute")
    awful.util.spawn("amixer sset " .. "Headphone" .. " unmute")
    vicious.force({ alsawidget.bar })
    alsawidget.notify()
end))

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
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

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
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
    { rule = { class = "gimp" },
      properties = { floating = true } },

    -- Set some apps to go directly to specific screns/workspaces.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2], switchtotag=true } },
    { rule = { class = "Google-chrome" },
      properties = { tag = tags[1][2], switchtotag=true } },
    { rule = { class = "chromium-browser" },
      properties = { tag = tags[1][2], switchtotag=true } },
    { rule = { class = "Iceweasel" },
      properties = { tag = tags[1][2], switchtotag=true } },

    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][3], switchtotag=true } },
    { rule = { class = "Icedove" },
      properties = { tag = tags[1][3], switchtotag=true } },
    { rule = { class = "Evolution" },
      properties = { tag = tags[1][3], switchtotag=true } },

    { rule = { class = "Thunar" },
      properties = { tag = tags[1][6], switchtotag=true } },

    { rule = { class = "Spotify" },
      properties = { tag = tags[1][7] } },

    { rule = { class = "Steam" },
      properties = { tag = tags[1][8] } },
}
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

    local titlebars_enabled = true
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
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
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

--Autostart apps
awful.util.spawn_with_shell("dropbox start")
awful.util.spawn_with_shell("owncloud")
awful.util.spawn_with_shell("keynav daemonize")
awful.util.spawn_with_shell("start-pulseaudio-x11")
awful.util.spawn_with_shell("xautolock -time 5 -locker 'i3lock -c 000000'")
awful.util.spawn_with_shell("setxkbmap -model pc105 -layout de -variant nodeadkeys")
awful.util.spawn_with_shell("nm-applet")
awful.util.spawn_with_shell("blueman-applet")

-- vim: ft=lua ts=4 sw=4 sts=0 et

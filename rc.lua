-- utils
local log = function(text)
  print('[awesome-' .. awesome.version .. '] ' .. text)
end

local at_all_screens = function(func) for screen_n=1,screen.count() do func(screen_n) end end

log('============= starting =============')

-- awesome standard libs
require('awful')
require("awful.rules")
require("awful.remote")

-- variables
local confdir   = awful.util.getdir('config')
local conffile  = confdir .. '/rc.lua'
local themename = 'default'
local themefile = confdir .. '/themes/'.. themename .. '/theme.lua'

terminal = 'lilyterm'
modkey = "Mod4"

log("config directory: '" .. confdir   .. "'")
log("config file:      '" .. conffile .. "'")
log("theme file:       '" .. themefile .. "'")
log("theme name:       '" .. themename .. "'")

beautiful.init(themefile)

layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

-- tags
local taglist = {
  { name = "main", selected = true },
  { name = "www"  },
  { name = "im" },
}
tags = {}
at_all_screens(function(screen)
  for i,tagdef in ipairs(taglist) do
    log('adding tag(' .. tagdef.name .. ') to screen ' .. screen)

    local newtag    = tag({ name = tagdef.name })
    newtag.screen   = screen
    newtag.selected = tagdef.selected or false

    if not tags[screen] then tags[screen] = {} end
    tags[screen][i] = newtag
  end
end)
awful.layout.inc(layouts, 0)

-- widget boxes
topstatusbar = {}
bottomstatusbar = {}
-- widgets
taglistw = {}
taglistw.buttons = awful.util.table.join(
  -- 1 left mouse button
  -- 2 middle mouse button
  -- 3 right mouse button
  -- 4 mouse wheel forward
  -- 5 mouse wheel backward
  awful.button({ }, 1, awful.tag.viewonly)
)
delimiterw = widget({ type = "textbox" })
delimiterw.text = " | "
command_prompt = {}
tasklistw = {}
tasklistw.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end)
					  )
systrayw = widget({ type = "systray" })
textclockw = awful.widget.textclock()

at_all_screens(function(s)

  taglistw = awful.widget.taglist(s, awful.widget.taglist.label.all, taglistw.buttons)
  command_prompt[s] = awful.widget.prompt({})
  tasklistw[s] = awful.widget.tasklist(function(c)
    return awful.widget.tasklist.label.currenttags(c, s)
  end, tasklistw.buttons)

  bottomstatusbar[s] = awful.wibox({ position = 'bottom', screen = s })
  bottomstatusbar[s].widgets = {
    {
      taglistw,
      delimiterw,
      command_prompt[s],
      layout = awful.widget.layout.horizontal.leftright
    },
    textclockw,
    s==1 and systrayw or nil,
    delimiterw,
    tasklistw[s],
    layout = awful.widget.layout.horizontal.rightleft
  }
end)

-- keybindings
-- resize factor:
resf  = 10
movef = 10
log('loading keybindings')
globalkeys = awful.util.table.join(

    -- client switching bindings
    awful.key({ modkey,           }, "k",   function ()
      awful.client.focus.byidx(1)
      if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey,           }, "j",   function ()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey,           }, "Tab", function ()
      awful.client.focus.history.previous()
      if client.focus then client.focus:raise() end
    end),

    -- client move/resize
    awful.key({ modkey, "Shift"   }, "Up",    function() awful.client.moveresize( 0, 0, 0, resf) end),
    awful.key({ modkey, "Shift"   }, "Right", function() awful.client.moveresize( 0, 0, resf, 0) end),
    awful.key({ modkey, "Shift"   }, "Left",  function() awful.client.moveresize( 0, 0,-resf, 0) end),
    awful.key({ modkey, "Shift"   }, "Down",  function() awful.client.moveresize( 0, 0, 0,-resf) end),
    awful.key({ modkey, "Control" }, "Up",    function() awful.client.moveresize( 0,-movef, 0, 0) end),
    awful.key({ modkey, "Control" }, "Right", function() awful.client.moveresize( movef, 0, 0, 0) end),
    awful.key({ modkey, "Control" }, "Left",  function() awful.client.moveresize(-movef, 0, 0, 0) end),
    awful.key({ modkey, "Control" }, "Down",  function() awful.client.moveresize( 0, movef, 0, 0) end),

    -- misc bindings
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),

    -- awesome bindongs
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey            }, "r", function () command_prompt[mouse.screen]:run() end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end
-- tags switching bindings
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end))
end
root.keys(globalkeys)

-- clientkeys
clientkeys = awful.util.table.join(
    awful.key({ modkey,    }, "c", function (c) c:kill() end),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = { },
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = true,
      keys = clientkeys,
    }
  },
  { rule = { class = "Iceweasel" }, properties = { tag = tags[mouse.screen][2] } },
  { rule = { class = "Google-chrome" }, properties = { tag = tags[mouse.screen][2] } },
  { rule = { class = "Skype" }, properties = { tag = tags[mouse.screen][3] } },
  { rule = { class = "MPlayer" }, properties = { floating = true, border_width = 3, border_color='red' } },
  { rule = { class = "Gvim" }, properties = { maximized_vertical = true, maximized_horizontal = true, sticky = true } },
}
-- signals

client.add_signal("manage", function (c, startup)
  log(c.class .. ' * ' .. c.type .. ' * ' .. c.name)
  if c.class=="Skype" then awful.tag.viewonly(tags[mouse.screen][3])end
end)

log('------------- started --------------')

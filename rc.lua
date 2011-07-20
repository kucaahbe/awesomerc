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
local themefile = confdir .. '/themes/default/theme.lua'

terminal = 'lilyterm'
modkey = "Mod4"

log("config directory: '" .. confdir   .. "'")
log("theme file:       '" .. themefile .. "'")
log("config file:      '" .. conffile .. "'")

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
awful.layout.inc(layouts, 1)

-- widget boxes
topstatusbar = {}
bottomstatusbar = {}
-- widgets
command_prompt = {}
mysystray = widget({ type = "systray" })

at_all_screens(function(s)

  command_prompt[s] = awful.widget.prompt({})

  bottomstatusbar[s] = awful.wibox({ position = 'bottom', screen = s })
  bottomstatusbar[s].widgets = {
    {
      command_prompt[s],
      layout = awful.widget.layout.horizontal.leftright
    },
    s==1 and mysystray or nil,
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
root.keys(globalkeys)

-- clientkeys
clientkeys = awful.util.table.join(
    awful.key({ modkey,    }, "c", function (c) c:kill() end)
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
}

log('------------- started --------------')

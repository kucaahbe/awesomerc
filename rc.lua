-- utils
local log = function(text)
  print('[awesome-' .. awesome.version .. '] ' .. text)
end

local at_all_screens = function(func) for screen_n=1,screen.count() do func(screen_n) end end

log('============= starting =============')

-- awesome standard libs
require('awful')
require("awful.rules")

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

-- statusbars
topstatusbar = {}
command_prompt = {}
at_all_screens(function(screen)
  topstatusbar[screen] = awful.wibox.new({ position = 'top', screen = screen })

  command_prompt[screen] = awful.widget.prompt({})

  topstatusbar[screen].widgets = {
    command_prompt[screen]
  }
end)

-- keybindings
log('loading keybindings')
globalkeys = awful.util.table.join(
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
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
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

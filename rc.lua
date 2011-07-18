-- utils
local log = function(text)
  print('[awesome-' .. awesome.version .. '] ' .. text)
end

local at_all_screens = function(func) for screen_n=1,screen.count() do func(screen_n) end end

log('============= starting =============')

-- awesome standard libs
require('awful')

-- variables
local confdir   = awful.util.getdir('config')
local conffile  = confdir .. '/rc.lua'
local themefile = confdir .. '/themes/default/theme.lua'
modkey = "Mod4"

log("config directory: '" .. confdir   .. "'")
log("theme file:       '" .. themefile .. "'")
log("config file:      '" .. conffile .. "'")

-- tags
local taglist = {
  { name = "main", selected = true },
  { name = "www"  },
}
tags = {}
at_all_screens(function(screen)
  for i,tagdef in ipairs(taglist) do
    log('adding tag(' .. tagdef.name .. ') to screen ' .. screen)
    tags[screen] = {}
    tags[screen][i]          = tag({ name = tagdef.name })
    tags[screen][i].screen   = screen
    tags[screen][i].selected = tagdef.selected or false
  end
end)

-- statusbars
topstatusbar = {}
at_all_screens(function(screen)
  topstatusbar[screen] = awful.wibox.new({ position = 'top', screen = screen })
end)

awesome.spawn('google-chrome')

log('------------- started --------------')

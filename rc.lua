-- utils
local log = function(text)
  print('[awesome-' .. awesome.version .. '] ' .. text)
end

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

awesome.spawn('google-chrome')

log('------------- started --------------')

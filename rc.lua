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

-- tags
tags = {
  { name = "main", selected = true },
  { name = "www"  },
}
for screen_n=1,screen.count() do
  for i,mytag in ipairs(tags) do
    local newtag = tags[i]
    log('adding tag(' .. newtag.name .. ') to screen ' .. screen_n)
    tags[i]          = tag({ name = newtag.name })
    tags[i].screen   = screen_n
    tags[i].selected = newtag.selected or false
  end
end

awesome.spawn('google-chrome')

log('------------- started --------------')

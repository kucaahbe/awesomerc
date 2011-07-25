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
  --awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

-- tags
tags = {}
tags.settings = {
  { name = "main", layout = layouts[0] },
  { name = "term", layout = layouts[2] },
  { name = "www",  layout = layouts[0] },
  { name = "im",   layout = layouts[2] },
}
at_all_screens(function(screen)
  for i,tagdef in ipairs(tags.settings) do
    log('adding tag(' .. tagdef.name .. ') to screen ' .. screen)

    local newtag    = tag({ name = tagdef.name })
    newtag.screen   = screen
    awful.tag.setproperty(newtag, "layout",   tagdef.layout)

    if not tags[screen] then tags[screen] = {} end
    tags[screen][i] = newtag
  end
end)
tags[mouse.screen][1].selected = true

-- widget boxes
topstatusbar = {}
bottomstatusbar = {}
-- widgets
layoutboxw = {}
ctitle = widget({ type = "textbox" })
ctitle.text = ''
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

  layoutboxw[s] = awful.widget.layoutbox(s)
  layoutboxw[s]:buttons(awful.util.table.join(
			 awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
			 awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
			 awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
			 awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

  taglistw = awful.widget.taglist(s, awful.widget.taglist.label.all, taglistw.buttons)
  command_prompt[s] = awful.widget.prompt({})
  tasklistw[s] = awful.widget.tasklist(function(c)
    return awful.widget.tasklist.label.currenttags(c, s)
  end, tasklistw.buttons)

  topstatusbar[s] = awful.wibox({ position = 'top', screen = s })
  topstatusbar[s].widgets = {
    {
      ctitle,
      layout = awful.widget.layout.horizontal.leftright
    },
    layout = awful.widget.layout.horizontal.rightleft
  }

  bottomstatusbar[s] = awful.wibox({ position = 'bottom', screen = s })
  bottomstatusbar[s].widgets = {
    {
      layoutboxw[s],
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
      local visible = awful.client.visible(mouse.screen)
      awful.client.focus.byidx(1)
      if not client.focus then client.focus = visible[1] end
      client.focus:raise()
    end),
    awful.key({ modkey,           }, "j",   function ()
      local visible = awful.client.visible(mouse.screen)
      awful.client.focus.byidx(-1)
      if not client.focus then client.focus = awful.util.table.reverse(visible)[1] end
      client.focus:raise()
    end),
    awful.key({ modkey,           }, "Tab", function ()
      awful.client.focus.history.previous()
      if client.focus then client.focus:raise() end
    end),

    -- misc bindings
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "d", function ()
      local clients = client.get(mouse.screen)
      for i,c in ipairs(clients) do
	c.minimized = not c.minimized
      end
    end),

    -- awesome bindings
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
clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
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
      buttons = clientbuttons,
    }
  },

  { rule = { class = "Iceweasel" }, properties = { tag = tags[mouse.screen][3] } },
  { rule = { class = "Google-chrome" }, properties = { tag = tags[mouse.screen][3] } },

  { rule = { class = "Skype", role = 'Chats'      }, properties = { tag = tags[mouse.screen][4], focus = false, minimized = true } },
  { rule = { class = "Skype", role = 'MainWindow' }, properties = { tag = tags[mouse.screen][4], switchtotag = true, floating = true } },

  { rule = { class = "MPlayer" }, properties = { floating = true, border_width = 3, border_color='red' } },

  { rule = { class = "Gvim" }, properties = { maximized_vertical = true, maximized_horizontal = true, float = tru, tag = tags[mouse.screen][1], } },
}

-- signals
client.add_signal("manage", function (c, startup)
  log('\t' .. c.class .. ((c.role and ('.' .. c.role)) or '') .. '(' .. c.type .. ')' .. '\t' .. c.name)

  ctitle.text = c.class
  if startup then
  end
end)
client.add_signal("unmanage", function (c)
  ctitle.text = ''
end)

client.add_signal("focus", function (c)
  ctitle.text = c.class
end)

awful.tag.attached_add_signal(mouse.screen, "property::selected", function(t)
end)

log('------------- started --------------')

# Wolfe Labs SDM: Simple Display Manager

This project is intended to be an low-level graphics utility that works for both the SVG-based Screens (and cockpits!) and ones with [the new Render Scripts](https://board.dualthegame.com/index.php?/topic/22643-lua-screen-units-api-and-instructions/). It also aims to be an successor for [DU-Screenmancy](https://github.com/wolfe-labs/DU-Screenmancy)'s Screen-related functions but without any UI-related tools, these will be moved into an specific module.

The way SDM works is very similar to the new Render Scripts, as you will create your own render script in SDM's syntax, except that it includes a few abstractions and improvements to make working with Render Scripts easier.

SDM will also handle any changes on the rendering API and allow you to reuse your render scripts both in places that accept Render Scripts and SVG. This is done through the provided drivers `Native` and `SVG`.
Your code will include a copy of the proper driver containing all of SDM's methods adapted for that usage and all output (such as SVG) is automatically routed to the Screen.

Please note that this is under development and quite a few functions aren't available everywhere, such as animations. Since the goal is to have a library compatible with both options we need to carefully consider before implementing anything.

**Note:** To compile from the source you **must** use [DU-LuaC](https://github.com/wolfe-labs/DU-LuaC).

## Sample Code

Let's say you want to draw a rectangle on your Screen. To do that, you can use the following render script:

```lua
local layer = Context:createLayer()
  :setFill(1.0, 0.0, 0.0)
  :setStroke(2, 0.0, 1.0, 1.0)

layer:drawRect(50, 50, 400, 300)
```

Now, let's prepare the code that will go, let's say, in our Programming Board:

```lua
local SDM = require('@wolfe-labs/SDM:SDM')

local renderScript = [[YOUR CODE WILL GO HERE]]

local display = SDM(screen, Driver)
display:setRenderScript(renderScript)

if unit then unit.exit() end
```

In the `renderScript` variable you should embed your SDM render script code (keep the `[[` and `]]` around it!). When executing, you should see the contents being rendered on your screen using the SVG renderer.

Now, let's suppose things change and you need to use the new Render Script system. No need for rewrites or worries! Since SDM sits in between your render script and the underlying engine (SVG/Render Script), it will just work, as it will already do all translation automatically!
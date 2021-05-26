-- Stub that renders the SVG to the console if no screen is found (like when testing on IDE)
if not print then print = system.print end
if not screen then
  screen = {
    setHTML = (function (html) print(html) end)
  }
end
--------------------------------------------------------------------------------------------
-- Actual script starts now
--------------------------------------------------------------------------------------------

local SDM = require('@wolfe-labs/SDM:SDM')

local renderScript = [[
local layer = Context:createLayer()
  :setFill(1.0, 0.0, 0.0)
  :setStroke(2, 0.0, 1.0, 1.0)

layer:drawRect(50, 50, 400, 300)
]]

local display = SDM(screen)
display:setRenderScript(renderScript)

if unit then unit.exit() end
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
local fontMontserrat = Context:loadFont('Montserrat', 24)
local imgTest = Context:loadImage('https://assets.prod.novaquark.com/71523/0af8f5e9-dda4-46df-8f92-7131cd779ead.png')

local res = Context:getResolution()

local layer1 = Context:createLayer()
  :setFill(1.0, 0.0, 0.0)
  :setStroke(2, 0.0, 1.0, 1.0)
  :drawRect(0, 0, res.w, res.h)

local layer2 = Context:createLayer()
  :setFill(0.0, 0.0, 0.0)
  :drawText('Hello, World!', 150, 150)
  :drawText('Another Font!', 150, 170, fontMontserrat)
  
  :setStroke(10, 1.0, 1.0, 0.0)
  :drawLine(150, 150, 350, 450)
  
  :setFill(1.0, 0.0, 1.0)
  :setStroke(4, 0.0, 1.0, 0.0)
  :drawQuad(50, 25, 150, 25, 150, 100, 75, 50)

  :drawImage(imgTest, 180, 180, 150, 150)

  :setFill(0.0, 1.0, 0.0)
  :setStroke(4, 1.0, 0.0, 0.0)
  :drawCircle(100, 100, 50)
]]

local display = SDM(screen)
display:setRenderScript(renderScript)

if unit then unit.exit() end
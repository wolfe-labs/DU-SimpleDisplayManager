-- Stub that renders the SVG to the console if no screen is found (like when testing on IDE)
if not print then print = system.print end
if not screen then
  screen = {
    setHTML = (function (html) print('Running in headless mode, printing output:'); print(html) end)
  }
end
--------------------------------------------------------------------------------------------
-- Actual script starts now
--------------------------------------------------------------------------------------------

local SDM = require('@wolfe-labs/SDM:SDM')
local RenderScript = require('@wolfe-labs/SDM:Builder')

-- Creates the Render Script instance
local Context = RenderScript()

-- Gets Context resolution in pixels
local res = Context:getResolution()

-- Sets base font size to 1/32 of the resolution (responsive font)
local fontBaseSize = res.h / 32

-- Creates a default font for our layers
local fontDefault = Context:loadFont('Play', fontBaseSize)

-- Adds a new font a little larger than our previous one
local fontMontserrat = Context:loadFont('Montserrat', fontBaseSize * 1.4)

-- Creates background layer
local background = Context:createLayer()
  :setFill(0.2, 0.2, 0.2)
  :setStroke(10, 0.4, 0.4, 0.4)
  :drawRect(0, 0, res.w, res.h)
  
-- Loads test images
local imgTest1 = Context:loadImage('https://assets.prod.novaquark.com/71523/0af8f5e9-dda4-46df-8f92-7131cd779ead.png')
local imgTest2 = Context:loadImage('https://assets.prod.novaquark.com/71523/ebfc9b55-9312-4c1c-ad09-18f64e4f4784.png')
local imgTest3 = Context:loadImage('https://assets.prod.novaquark.com/71523/19c7be9b-d6ca-4458-b3f5-79e3ba412e10.png')

-- Creates left side playground
local leftSide = Context:createLayer()
  :setFont(fontDefault)
  :setFill(0.0, 0.0, 0.0)
  :drawText('Hello, World!', 150, 150)
  :drawText('Another Font!', 150, 170, fontMontserrat)
  
  :setStroke(10, 1.0, 1.0, 0.0)
  :drawLine(150, 150, 350, 450)
  
  :setFill(1.0, 0.0, 1.0)
  :setStroke(4, 0.0, 1.0, 0.0)
  :drawQuad(50, 25, 150, 25, 150, 100, 75, 50)

  :drawImage(imgTest1, 180, 180, 150, 150)

  :setFill(0.0, 1.0, 0.0)
  :setStroke(4, 1.0, 0.0, 0.0)
  :drawCircle(100, 100, 50)

-- Creates right side panel
local rightSideBackground = Context:createLayer()
  :setFill(0.5, 0.5, 0.5)
  :drawRect(res.w / 2 + 20, 20, res.w / 2 - 40, res.h - 40)
  
local rightSide = Context:createLayer()
  :setFill(1.0, 0.0, 0.0)
  :drawText('Sample Text', res.w / 2 + 20, 50)
  :drawImage(imgTest2, res.w / 2 + 20, 40, res.w / 2 - 40, 200)
  :drawImage(imgTest3, res.w / 2 + 20, 240, res.w / 2 - 40, 200)

-- Loads SDM into the Screen Unit at slot 'screen'
local display = SDM(screen)

-- Sents the render script to the new Render Script instance
display:setRenderScript(Context)
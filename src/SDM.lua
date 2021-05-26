local DriverSVG = require('@wolfe-labs/SDM:DriverSVG')
local DriverNative = require('@wolfe-labs/SDM:DriverNative')

-- Creates a new instance of an class
local function make(classDef)
  -- Sets the index function
  local metatable = {
    __index = classDef,
  }

  -- Creates instance
  local self = setmetatable({}, metatable)

  -- Optionally initializes it
  if self.init then self:init() end

  -- Returns instance
  return self
end

local Display = {}

function Display:init()
  self.driver = nil
  self.display = nil
end

function Display:setRenderScript(script)
  -- Updates the script
  self.script = script

  -- Triggers a first render
  self:render()
end

function Display:render()
  -- If we're dealing with a return-type driver (which will return source-code such as SVG), we'll process it right now
  if self.driver.returns then
    -- Creates the render script
    local renderScript = self.driver.driverHead .. ';' .. self.script .. ';--[[]]' .. self.driver.driverFoot

    -- Compiles the render script
    local renderFunction, err = load(renderScript)

    -- If any error is found, returns it
    if err then error(err) end

    -- Runs the code
    local renderOutput = renderFunction()

    -- Now we decide what to do with the output
    if 'svg' == self.driver.driverType then
      -- If we're dealing with something with a setHTML method (such as Screen elements), use it
      if  self.display.setHTML then
        self.display.setHTML(renderOutput)
        -- If we're dealing with something with a setContent method (such as system), which renders to the user, then use it
      elseif self.display.setHTML then
        self.display.setContent(renderOutput)
      end
    end
  end
end

local function SDM(displayEntity)
  -- Instantiates a Display
  local self = make(Display)

  -- Setup display
  self.display = displayEntity

  -- Figures out which driver to use
  if self.display and self.display.setRenderScript then
    self.driver = DriverNative
  else
    self.driver = DriverSVG
  end

  -- Returns it for usage
  return self
end

return SDM
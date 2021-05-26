-- Comment the next line on your IDE when developing, this converts the entire source into a string that is later embedded on SDM's render script
return { driverType = 'svg', returns = true, driverHead = [[Context = (function ()

-- Creates a new instance of an class
local function make(classDef)
  -- Sets the index function
  local metatable = {
    __index = classDef,
  }

  -- Creates instance
  local self = setmetatable({}, metatable)

  -- Returns instance
  return self
end

-- Creates a color table
local function makeColor(r, g, b, a)
  -- If alpha is not present, assume 100%
  if not a then a = 1.0 end

  -- Sets colors, maps them from 0..1 to 0..255
  return {
    r = math.floor(255 * r),
    g = math.floor(255 * g),
    b = math.floor(255 * b),
    a = a,
  }
end

local Context = {
  -- Default Screen Unit resolution on legacy SVGs
  resolution = { w = 1024, h = 612},

  -- The layers of the Context object
  layers = {},

  -- Current context
  current = nil
}

local Layer = {
  contents = '',
  strokeWidth = 1,
  strokeColor = makeColor(1, 1, 1),
  fillColor = makeColor(0, 0, 0),
}

-- Creates a new Context object
function Context.create()
  return make(Context)
end

-- Renders the current Context
function Context:render()
  -- Gets viewport size
  local res = self:getResolution()

  -- Starts SVG output
  local output = '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">'
  -- output = output .. '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="' .. w .. '" height="' .. h .. '">'
  output = output .. '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="100%" height="100%" viewbox="0 0 ' .. res.w .. ' ' .. res.h .. '">'

  -- Processes each of the layers
  for _, layer in pairs(self.layers) do
    output = output .. layer.contents
  end

  -- Closes SVG and returns
  output = output .. '</svg>'
  return output
end

-- Returns only default Screen size from DU
function Context:getResolution()
  return self.resolution
end

-- Creates a new layer
function Context:createLayer()
  -- Creates a new Layer instance
  local layer = make(Layer)

  -- Saves into layer list
  table.insert(self.layers, layer)

  -- Returns instance of the said layer
  return layer
end

-- Sets current color for fill
function Layer:setFill(r, g, b, a)
  -- Updates fill color
  self.fillColor = makeColor(r, g, b, a)

  -- Returns self instance for chaining
  return self
end

-- Sets current width and color for stroke
function Layer:setStroke(width, r, g, b, a)
  -- Updates width and color at same time
  self:setStrokeWidth(width)
  self:setStrokeColor(r, g, b, a)

  -- Returns self instance for chaining
  return self
end

-- Sets current width for stroke
function Layer:setStrokeColor(r, g, b, a)
  -- Updates stroke color
  self.strokeColor = makeColor(r, g, b, a)

  -- Returns self instance for chaining
  return self
end

-- Sets current color for stroke
function Layer:setStrokeWidth(width)
  -- Updates stroke color
  self.strokeWidth = width

  -- Returns self instance for chaining
  return self
end

-- Adds a rectangle to a layer
function Layer:drawRect(x, y, width, height)
  -- Load stroke color
  local s = self.strokeColor

  -- Load fill color
  local f = self.fillColor

  -- "Draws"
  self.contents = self.contents .. '<rect x="' .. x .. '" y="' .. y .. '" width="' .. width .. '" height="' .. height .. '" style="fill:rgba(' .. f.r .. ', ' .. f.g .. ', ' .. f.b .. ', ' .. f.a .. ');stroke:rgba(' .. s.r .. ', ' .. s.g .. ', ' .. s.b .. ', ' .. s.a .. ');stroke-width:' .. self.strokeWidth .. ';" />'

  -- Returns self instance for chaining
  return self
end

-- Generates a context for working with gfx
return Context.create()
end)()]], driverFoot = 'return Context:render()' }
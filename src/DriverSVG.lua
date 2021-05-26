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

  -- Optionally initializes it
  if self.init then self:init() end

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
  current = nil,
}

local Layer = {}

-- Creates a new Context object
function Context.create()
  return make(Context)
end

-- Initializes the Context
function Context:init()
  self.currentFont = {
    name = 'Play',
    size = 14,
  }
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
    output = output .. '<g style="position:relative;">'
    output = output .. layer.contents.image
    output = output .. layer.contents.rect
    output = output .. layer.contents.circle
    output = output .. layer.contents.line
    output = output .. layer.contents.triangle
    output = output .. layer.contents.quad
    output = output .. layer.contents.text
    output = output .. '</g>'
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

  -- Marks as parent
  layer.context = self

  -- Saves into layer list
  table.insert(self.layers, layer)

  -- Returns instance of the said layer
  return layer
end

-- Loads a font for usage
function Context:loadFont(font, size)
  -- Creates the new font, since we're on SVG all we need is name and size anyways
  return { name = font, size = size }
end

-- Loads an image for usage
function Context:loadImage(path)
  -- Creates the new image, since we're on SVG all we need is the path
  return { path = path }
end

-- Initializes the layer
function Layer:init()
  self.contents = {
    image = '',
    rect = '',
    circle = '',
    line = '',
    triangle = '',
    quad = '',
    text = '',
  }
  self.strokeWidth = 1
  self.strokeColor = makeColor(1, 1, 1)
  self.fillColor = makeColor(0, 0, 0)
  self.currentFont = nil
end

-- Gets active font from layer
function Layer:getCurrentFont()
  if self.currentFont then
    return self.currentFont
  else
    return self.context.currentFont
  end
end

-- Sets active font for layer
function Layer:setFont(font)
  -- Updates active font for entire layer
  self.currentFont = font

  -- Returns self instance for chaining
  return self
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
  self.contents.rect = self.contents.rect .. '<rect x="' .. x .. '" y="' .. y .. '" width="' .. width .. '" height="' .. height .. '" style="fill:rgba(' .. f.r .. ', ' .. f.g .. ', ' .. f.b .. ', ' .. f.a .. ');stroke:rgba(' .. s.r .. ', ' .. s.g .. ', ' .. s.b .. ', ' .. s.a .. ');stroke-width:' .. self.strokeWidth .. ';" />'

  -- Returns self instance for chaining
  return self
end

-- Adds a circle to a layer
function Layer:drawCircle(centerX, centerY, radius)
  -- Load stroke color
  local s = self.strokeColor

  -- Load fill color
  local f = self.fillColor

  -- "Draws"
  self.contents.circle = self.contents.circle .. '<circle cx="' .. centerX .. '" cy="' .. centerY .. '" r="' .. radius .. '" style="fill:rgba(' .. f.r .. ', ' .. f.g .. ', ' .. f.b .. ', ' .. f.a .. ');stroke:rgba(' .. s.r .. ', ' .. s.g .. ', ' .. s.b .. ', ' .. s.a .. ');stroke-width:' .. self.strokeWidth .. ';" />'

  -- Returns self instance for chaining
  return self
end

-- Adds a line to a layer
function Layer:drawLine(x1, y1, x2, y2)
  -- Load stroke color
  local s = self.strokeColor

  -- Load fill color
  local f = self.fillColor

  -- "Draws"
  self.contents.line = self.contents.line .. '<line x1="' .. x1 .. '" y1="' .. y1 .. '" x2="' .. x2 .. '" y2="' .. y2 .. '" style="fill:rgba(' .. f.r .. ', ' .. f.g .. ', ' .. f.b .. ', ' .. f.a .. ');stroke:rgba(' .. s.r .. ', ' .. s.g .. ', ' .. s.b .. ', ' .. s.a .. ');stroke-width:' .. self.strokeWidth .. ';" />'

  -- Returns self instance for chaining
  return self
end

-- Adds a quadrilateral to a layer
function Layer:drawQuad(x1, y1, x2, y2, x3, y3, x4, y4)
  -- Load stroke color
  local s = self.strokeColor

  -- Load fill color
  local f = self.fillColor

  -- "Draws"
  self.contents.quad = self.contents.quad .. '<path d="M' .. x1 .. ' ' .. y1 .. ' L' .. x2 .. ' ' .. y2 .. ' L' .. x3 .. ' ' .. y3 .. ' L' .. x4 .. ' ' .. y4 .. ' Z" class="quad" style="fill:rgba(' .. f.r .. ', ' .. f.g .. ', ' .. f.b .. ', ' .. f.a .. ');stroke:rgba(' .. s.r .. ', ' .. s.g .. ', ' .. s.b .. ', ' .. s.a .. ');stroke-width:' .. self.strokeWidth .. ';" />'

  -- Returns self instance for chaining
  return self
end

-- Adds a triangle to a layer
function Layer:drawTriangle(x1, y1, x2, y2, x3, y3)
  -- Load stroke color
  local s = self.strokeColor

  -- Load fill color
  local f = self.fillColor

  -- "Draws"
  self.contents.triangle = self.contents.triangle .. '<path d="M' .. x1 .. ' ' .. y1 .. ' L' .. x2 .. ' ' .. y2 .. ' L' .. x3 .. ' ' .. y3 .. ' Z" class="tri" style="fill:rgba(' .. f.r .. ', ' .. f.g .. ', ' .. f.b .. ', ' .. f.a .. ');stroke:rgba(' .. s.r .. ', ' .. s.g .. ', ' .. s.b .. ', ' .. s.a .. ');stroke-width:' .. self.strokeWidth .. ';" />'

  -- Returns self instance for chaining
  return self
end

-- Adds a text to a layer
function Layer:drawText(text, x, y, font)
  -- Load fill color
  local f = self.fillColor

  -- Load active font from the Layer or Context
  if not font then
    font = self:getCurrentFont()
  end

  -- "Draws"
  self.contents.text = self.contents.text .. '<text x="' .. x .. '" y="' .. y .. '" style="font-size:' .. font.size .. 'px;font-family:\'' .. font.name .. '\';fill:rgba(' .. f.r .. ', ' .. f.g .. ', ' .. f.b .. ', ' .. f.a .. ');">' .. text .. '</text>'

  -- Returns self instance for chaining
  return self
end

-- Adds an image
function Layer:drawImage(image, x, y, width, height)
  -- "Draws"
  self.contents.image = self.contents.image .. '<image x="' .. x .. '" y="' .. y .. '" width="' .. width .. '" height="' .. height .. '" href="' .. image.path .. '" />'

  -- Returns self instance for chaining
  return self
end

-- Generates a context for working with gfx
return Context.create()
end)()]], driverFoot = 'return Context:render()' }
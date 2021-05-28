-- Comment the next line on your IDE when developing, this converts the entire source into a string that is later embedded on SDM's render script
return { driverType = 'native', returns = false, driverHead = [[Context = (function ()

-- Stub function as we don't have that on screens yet
local function setmetatable(obj, table)
  local newObj = {}
  
  -- Add properties from obj
  for k, v in pairs(obj) do
    newObj[k] = v
  end
  
  -- Add properties from metatable
  for k, v in pairs(table.__index) do
    newObj[k] = v
  end

  return newObj
end

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

  -- Sets colors, no need for mapping here
  return {
    r = r,
    g = g,
    b = b,
    a = a,
  }
end

local Context = {
  -- Default Screen Unit resolution on legacy SVGs
  resolution = { w = 1024, h = 612 },

  -- The layers of the Context object
  layers = {},

  -- Current context
  current = nil
}

local Layer = {}

-- Creates a new Context object
function Context.create()
  return make(Context)
end

-- Handles Context initialization
function Context:init()
  self.currentFont = loadFont('Play', 14)
end

-- Returns only default Screen size from DU
function Context:getResolution()
  return getResolution()
end

-- Creates a new layer
function Context:createLayer()
  -- Creates a new Layer instance
  local layer = make(Layer)

  -- Marks as parent
  layer.context = self
  
  -- Assigns a native layer to it
  layer._layer = createLayer()

  -- Saves into layer list
  table.insert(self.layers, layer)

  -- Returns instance of the said layer
  return layer
end

-- Loads a font for usage
function Context:loadFont(font, size)
  -- Creates the new font and returns the internal handle to it
  return loadFont(font, size)
end

-- Loads an image for usage
function Context:loadImage(path)
  -- Loads the new image and returns the internal handle to it
  return loadImage(path)
end

-- Initializes the layer
function Layer:init()
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

-- Prepares to draw a shape
function Layer:prepareForDrawing()
  -- Sets next stroke color
  if self.strokeColor.a > 0 and self.strokeWidth > 0 then
    -- Load stroke color
    local s = self.strokeColor

    -- Sends calls downstream
    setNextStrokeWidth(self._layer, self.strokeWidth)
    setNextStrokeColor(self._layer, s.r, s.g, s.b, s.a)
  end

  -- Sets next fill color
  if self.fillColor.a > 0 then
    -- Load fill color
    local f = self.fillColor

    -- Sends calls downstream
    setNextFillColor(self._layer, f.r, f.g, f.b, f.a)
  end
end

-- Adds a rectangle to a layer
function Layer:drawRect(x, y, width, height)
  -- Prepares strokes and fill colors
  self:prepareForDrawing()

  -- Sends draw call downstream
  addBox(self._layer, x, y, width, height)

  -- Returns self instance for chaining
  return self
end

-- Adds a circle to a layer
function Layer:drawCircle(centerX, centerY, radius)
  -- Prepares strokes and fill colors
  self:prepareForDrawing()

  -- Sends draw call downstream
  addCircle(self._layer, centerX, centerY, radius)

  -- Returns self instance for chaining
  return self
end

-- Adds a line to a layer
function Layer:drawLine(x1, y1, x2, y2)
  -- Prepares strokes and fill colors
  self:prepareForDrawing()

  -- Sends draw call downstream
  addLine(self._layer, x1, y1, x2, y2)

  -- Returns self instance for chaining
  return self
end

-- Adds a quadrilateral to a layer
function Layer:drawQuad(x1, y1, x2, y2, x3, y3, x4, y4)
  -- Prepares strokes and fill colors
  self:prepareForDrawing()

  -- Sends draw call downstream
  addQuad(self._layer, x1, y1, x2, y2, x3, y3, x4, y4)

  -- Returns self instance for chaining
  return self
end

-- Adds a triangle to a layer
function Layer:drawTriangle(x1, y1, x2, y2, x3, y3)
  -- Prepares strokes and fill colors
  self:prepareForDrawing()

  -- Sends draw call downstream
  addTriangle(self._layer, x1, y1, x2, y2, x3, y3)

  -- Returns self instance for chaining
  return self
end

-- Adds a text to a layer
function Layer:drawText(text, x, y, font)
  -- Prepares strokes and fill colors
  self:prepareForDrawing()

  -- Load active font from the Layer or Context
  if not font then
    font = self:getCurrentFont()
  end

  -- Sends draw call downstream
  addText(self._layer, font, text, x, y)

  -- Returns self instance for chaining
  return self
end

-- Adds an image
function Layer:drawImage(image, x, y, width, height)
  -- Prepares strokes and fill colors
  self:prepareForDrawing()

  -- Sends draw call downstream
  addImage(self._layer, image, x, y, width, height)

  -- Returns self instance for chaining
  return self
end

-- Generates a context for working with gfx
return Context.create()
end)()]], driverFoot = '' }
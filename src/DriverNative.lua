-- Comment the next line on your IDE when developing, this converts the entire source into a string that is later embedded on SDM's render script
return { driverType = 'native', returns = false, driverHead = [[Context = (function ()

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
  resolution = { w = 1024, h = 612},

  -- The layers of the Context object
  layers = {},

  -- Current context
  current = nil
}

local Layer = {
  strokeWidth = 1,
  strokeColor = makeColor(1, 1, 1),
  fillColor = makeColor(0, 0, 0),
}

-- Creates a new Context object
function Context.create()
  return make(Context)
end

-- Returns only default Screen size from DU
function Context:getResolution()
  return getResolution()
end

-- Creates a new layer
function Context:createLayer()
  -- Creates a new Layer instance
  local layer = make(Layer)
  
  -- Assigns a native layer to it
  layer._layer = createLayer()

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

-- Prepares to draw a shape
function Layer:prepareForDrawing()
  -- Sets next stroke color
  if self.strokeColor.a > 0 && self.strokeWidth > 0 then
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

-- Generates a context for working with gfx
return Context.create()
end)()]], driverFoot = 'return Context:render()' }
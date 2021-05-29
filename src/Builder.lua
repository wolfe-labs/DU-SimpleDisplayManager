-- Global instance ID
local nextInstance = 1

-- Gets next instance
local function getInstance(type, id)
  -- Optionally gets the next global id
  if not id then
    id = nextInstance
    nextInstance = nextInstance + 1
  end
  
  -- Returns proper UID
  return '_' .. type:sub(1, 1) .. id
end

-- Creates a new instance of an class
local function make(type, classDef, metatable)
  -- Allows custom metatables
  if not metatable then
    metatable = {}
    metatable.__index = classDef
  end

  -- Creates instance
  local self = setmetatable({}, metatable)

  -- Sets internal ID
  self.id = nextInstance
  self.type = type
  self.uuid = getInstance(self.type, self.id)
  nextInstance = nextInstance + 1

  -- Optionally initializes it
  if classDef.init then self:init() end

  -- Returns instance
  return self
end

local Script = {}
local Layer = {}
local Command = {}
local Reference = {
  isRecursing = false
}

--------------------
-- Reference API
--------------------

function Reference:__index(k)
  if Reference[k] then
    return Reference[k]
  end

  return Reference.make(self.script, self.uuid .. '["' .. k .. '"]')
end

function Reference:__add(value)
  return Reference.make(self.script, self.uuid .. '+' .. value)
end

function Reference:__sub(value)
  return Reference.make(self.script, self.uuid .. '-' .. value)
end

function Reference:__mul(value)
  return Reference.make(self.script, self.uuid .. '*' .. value)
end

function Reference:__div(value)
  return Reference.make(self.script, self.uuid .. '/' .. value)
end

function Reference:__mod(value)
  return Reference.make(self.script, self.uuid .. '%' .. value)
end

function Reference:__pow(value)
  return Reference.make(self.script, self.uuid .. '**' .. value)
end

function Reference.getMetatable()
  return {
    __index = Reference.__index,
    __add = Reference.__add,
    __sub = Reference.__sub,
    __mul = Reference.__mul,
    __div = Reference.__div,
    __mod = Reference.__mod,
    __pow = Reference.__pow,
  }
end

function Reference.make(script, code, type)
  -- Optionally accept custom typings
  if not type then type = 'Ref' end

  -- If a command, convert to lua
  if code.toLua then code = code:toLua() end

  -- Creates reference
  local ref = make(type, Reference, Reference.getMetatable())

  -- Saves reference code and script
  ref.code = code
  ref.script = script

  -- Registers lua
  table.insert(script.header, ref.uuid .. '=' .. code)

  -- Returns reference for later usage
  return ref
end

--------------------
-- Command API
--------------------

function Command.make(obj, fn)
  local cmd = make('Command', Command)
  cmd.arg = {}
  cmd.obj = obj.uuid
  cmd.fn = fn
  return cmd
end

function Command:args(...)
  self.arg = table.pack(...)

  -- Filtering on args
  for _, arg in pairs(self.arg) do
    -- Refs to UID
    if 'table' == type(arg) and arg.uuid then
      self.arg[_] = arg.uuid

    -- Strings
    elseif 'string' == type(arg) then
      local escaped = ''
      for idx = 1, #arg do
        local char = arg:sub(idx, idx)
        if '"' == char then char = '\\"' end
        escaped = escaped .. char
      end
      self.arg[_] = '"' .. arg .. '"'
    end
  end

  -- Done
  return self
end

function Command:toLua()
  return self.obj .. ':' .. self.fn .. '(' .. table.concat(self.arg, ',') .. ');'
end

--------------------
-- Layer API
--------------------

function Layer:init()
  self.commands = {}
end

function Layer:toLua()
  return self.uuid .. '=Context:createLayer();'
end

function Layer:getRenderScript()
  local script = self:toLua()
  for _, command in pairs(self.commands) do
    script = script .. command:toLua()
  end
  return script
end

function Layer:setFont(font)
  table.insert(self.commands, (Command.make(self, 'setFont'):args(font)))
  return self
end

function Layer:setFill(r, g, b, a)
  table.insert(self.commands, (Command.make(self, 'setFill'):args(r, g, b, a)))
  return self
end

function Layer:setStroke(width, r, g, b, a)
  table.insert(self.commands, (Command.make(self, 'setStroke'):args(width, r, g, b, a)))
  return self
end

function Layer:setStrokeColor(r, g, b, a)
  table.insert(self.commands, (Command.make(self, 'setStrokeColor'):args(r, g, b, a)))
  return self
end

function Layer:setStrokeWidth(width)
  table.insert(self.commands, (Command.make(self, 'setStrokeWidth'):args(width)))
  return self
end

function Layer:drawRect(x, y, width, height)
  table.insert(self.commands, (Command.make(self, 'drawRect'):args(x, y, width, height)))
  return self
end

function Layer:drawCircle(x, y, radius)
  table.insert(self.commands, (Command.make(self, 'drawCircle'):args(x, y, radius)))
  return self
end

function Layer:drawLine(x1, y1, x2, y2)
  table.insert(self.commands, (Command.make(self, 'drawLine'):args(x1, y1, x2, y2)))
  return self
end

function Layer:drawQuad(x1, y1, x2, y2, x3, y3, x4, y4)
  table.insert(self.commands, (Command.make(self, 'drawQuad'):args(x1, y1, x2, y2, x3, y3, x4, y4)))
  return self
end

function Layer:drawTriangle(x1, y1, x2, y2, x3, y3)
  table.insert(self.commands, (Command.make(self, 'drawTriangle'):args(x1, y1, x2, y2, x3, y3)))
  return self
end

function Layer:drawText(text, x, y, font)
  table.insert(self.commands, (Command.make(self, 'drawText'):args(text, x, y, font)))
  return self
end

function Layer:drawImage(image, x, y, width, height)
  table.insert(self.commands, (Command.make(self, 'drawImage'):args(image, x, y, width, height)))
  return self
end

--------------------
-- Script API
--------------------

function Script.make()
  local script = make('Script', Script)
  return script
end

function Script:init()
  self.uuid = 'Context'
  self.layers = {}
  self.header = {}
end

function Script:getRenderScript()
  local script = ''
  for _, header in pairs(self.header) do
    script = script .. header .. ';'
  end
  for _, layer in pairs(self.layers) do
    script = script .. layer:getRenderScript()
  end
  return script
end

function Script:registerLua(code, type)
  return Reference.make(self, code, type)
end

function Script:createLayer()
  local layer = make('Layer', Layer)
  table.insert(self.layers, layer)
  return layer
end

function Script:getResolution()
  return Reference.make(self, (Command.make(self, 'getResolution')))
end

function Script:loadFont(font, size)
  return self:registerLua((Command.make(self, 'loadFont'):args(font, size)), 'Font')
end

function Script:loadImage(source)
  return self:registerLua((Command.make(self, 'loadImage'):args(source)), 'Image')
end

-- Returns by default a new instance of the render script
return Script.make
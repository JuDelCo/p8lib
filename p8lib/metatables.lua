
--------------------------------
-- metatables
--------------------------------

__setmetatable = setmetatable
__metatables = {}

function setmetatable(object, mt)
  __metatables[object] = mt
  return __setmetatable(object, mt)
end

function getmetatable(object)
  return __metatables[object]
end

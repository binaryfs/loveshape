local BASE = (...):gsub("[^%.]*$", "")

--- @type loveshape.utils
local utils = require(BASE .. "utils")

--- Abstract base class for all loveshape objects.
--- This class is used internally.
--- @class loveshape.Object
--- @field protected _typename string
--- @field protected _parentClass loveshape.Object
local Object = utils.class("loveshape.Object")

--- Get the type of the object as a string.
--- @return string typename
--- @nodiscard
function Object:type()
  return self._typename
end

--- Determine if the object is of a certain type.
--- @param typename string
--- @return boolean
--- @nodiscard
function Object:typeOf(typename)
  if self._typename == typename then
    return true
  end

  if self._parentClass then
    return self._parentClass:typeOf(typename)
  end

  return false
end

return Object
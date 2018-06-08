--[[--
 Additions to the math module.
 @module std.math
]]

local M -- forward declaration

local _floor = math.floor


--- Extend `math.floor` to take the number of decimal places.
-- @function floor
-- @param n number
-- @param p number of decimal places to truncate to (default: 0)
-- @return `n` truncated to `p` decimal places
local function floor (n, p)
  if p and p ~= 0 then
    local e = 10 ^ p
    return _floor (n * e) / e
  else
    return _floor (n)
  end
end


--- Overwrite core methods with `std` enhanced versions.
--
-- Replaces core `math.floor` with `std.math` version.
-- @tparam[opt=_G] table namespace where to install global functions
-- @treturn table the module table
local function monkey_patch (namespace)
  namespace = namespace or _G
  assert (type (namespace) == "table",
          "bad argument #1 to 'monkey_patch' (table expected, got " .. type (namespace) .. ")")

  namespace.math.floor = floor
  return M
end


--- Round a number to a given number of decimal places
-- @function round
-- @param n number
-- @param p number of decimal places to round to (default: 0)
-- @return `n` rounded to `p` decimal places
local function round (n, p)
  local e = 10 ^ (p or 0)
  return _floor (n * e + 0.5) / e
end


local M = {
  floor        = floor,
  monkey_patch = monkey_patch,
  round        = round,
}

for k, v in pairs (math) do
  M[k] = M[k] or v
end

return M

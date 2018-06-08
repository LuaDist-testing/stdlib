--[[--
 Extensions to the table module.
 @module std.table
]]

local base = require "std.base"
local func = require "std.functional"

-- No need to pull all of std.list into memory.
local elems = base.elems


--- Make a shallow copy of a table, including any metatable.
--
-- To make deep copies, use @{std.tree.clone}.
-- @function clone
-- @tparam table t source table
-- @tparam[opt={}] table map table of `{old_key=new_key, ...}`
-- @tparam boolean nometa if non-nil don't copy metatable
-- @return copy of *t*, also sharing *t*'s metatable unless *nometa*
--   is true, and with keys renamed according to *map*
local clone = base.clone


-- DEPRECATED: Remove in first release following 2015-04-15.
-- Clone a table, renaming some keys.
-- @function clone_rename
-- @tparam table map table `{old_key=new_key, ...}`
-- @tparam table t   source table
-- @return copy of *table*
local clone_rename = base.deprecate (base.clone_rename, nil,
  "table.clone_rename is deprecated, use the new `map` argument to table.clone instead.")


--- Make a partial clone of a table.
--
-- Like `clone`, but does not copy any fields by default.
-- @function clone_select
-- @tparam table t source table
-- @tparam[opt={}] table selection list of keys to copy
-- @return copy of fields in *selection* from *t*, also sharing *t*'s
--   metatable unless *nometa*
local function clone_select (t, map, nometa)
  assert (type (t) == "table",
          "bad argument #1 to 'clone_select' (table expected, got " .. type (t) .. ")")
  map = map or {}
  if type (map) ~= "table" then
    map, nometa = {}, map
  end

  local r = {}
  if not nometa then
    setmetatable (r, getmetatable (t))
  end
  for i in elems (map) do
    r[i] = t[i]
  end
  return r
end


--- Destructively merge another table's fields into *table*.
-- @function merge
-- @tparam table t destination table
-- @tparam table u table with fields to merge
-- @return table   `t` with fields from `u` merged in
local merge = base.merge


-- Preserve core table sort function.
local _sort = table.sort

--- Make table.sort return its result.
-- @tparam table    t unsorted table
-- @tparam function c comparator function
-- @return `t` with keys sorted accordind to `c`
local function sort (t, c)
  _sort (t, c)
  return t
end


--- Return whether table is empty.
-- @tparam table t any table
-- @return `true` if `t` is empty, otherwise `false`
local function empty (t)
  return not next (t)
end


--- Turn a tuple into a list.
-- @param ... tuple
-- @return list
local function pack (...)
  return {...}
end


--- Find the number of elements in a table.
-- @tparam table t any table
-- @return number of non-nil values in `t`
local function size (t)
  local n = 0
  for _ in pairs (t) do
    n = n + 1
  end
  return n
end


--- Make the list of keys in table.
-- @tparam  table t any table
-- @treturn table   list of keys
local function keys (t)
  local l = {}
  for k, _ in pairs (t) do
    table.insert (l, k)
  end
  return l
end


--- Make the list of values of a table.
-- @tparam  table t any table
-- @treturn table   list of values
local function values (t)
  local l = {}
  for _, v in pairs (t) do
    table.insert (l, v)
  end
  return l
end


--- Invert a table.
-- @tparam  table t a table with `{k=v, ...}`
-- @treturn table   inverted table `{v=k, ...}`
local function invert (t)
  local i = {}
  for k, v in pairs (t) do
    i[v] = k
  end
  return i
end


--- An iterator like ipairs, but in reverse.
-- @tparam  table    t any table
-- @treturn function   iterator function
-- @treturn table      the table, `t`
-- @treturn  number    `#t + 1`
local function ripairs (t)
  return function (t, n)
           n = n - 1
           if n > 0 then
             return n, t[n]
           end
         end,
  t, #t + 1
end


--- Turn an object into a table according to __totable metamethod.
-- @tparam  std.object x object to turn into a table
-- @treturn table resulting table or `nil`
local function totable (x)
  local m = func.metamethod (x, "__totable")
  if m then
    return m (x)
  elseif type (x) == "table" then
    return x
  elseif type (x) == "string" then
    local t = {}
    x:gsub (".", function (c) t[#t + 1] = c end)
    return t
  else
    return nil
  end
end


--- Make a table with a default value for unset keys.
-- @param         x default entry value (default: `nil`)
-- @tparam  table t initial table (default: `{}`)
-- @treturn table   table whose unset elements are x
local function new (x, t)
  return setmetatable (t or {},
                       {__index = function (t, i)
                                    return x
                                  end})
end


--- @export
local Table = {
  clone        = clone,
  clone_select = clone_select,
  empty        = empty,
  invert       = invert,
  keys         = keys,
  merge        = merge,
  new          = new,
  pack         = pack,
  ripairs      = ripairs,
  size         = size,
  sort         = sort,
  totable      = totable,
  values       = values,

  -- Core Lua table.sort function
  _sort        = _sort,
}

-- Deprecated and undocumented.
Table.clone_rename = clone_rename

for k, v in pairs (table) do
  Table[k] = Table[k] or v
end

return Table

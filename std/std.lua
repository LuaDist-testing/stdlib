--- Lua standard library
-- <ul>
-- <li>TODO: Write a style guide (indenting/wrapping, capitalisation,
--   function and variable names); library functions should call
--   error, not die; OO vs non-OO (a thorny problem).</li>
-- <li>TODO: Add tests for each function immediately after the function;
--   this also helps to check module dependencies.</li>
-- <li>TODO: pre-compile.</li>
-- </ul>
local version = "General Lua libraries / 35"

for _, m in ipairs (require "std.modules") do
  if m:match "_ext$" ~= nil then
    -- Inject stdlib extensions directly into global package namespaces.
    local t = m:match "std%.(.*)_ext$"
    for k, v in pairs (require (m)) do
      _G[t][k] = v
    end
  else
    _G[m:match "std%.(.*)$"] = require (m)
  end
end

-- Add io functions to the file handle metatable.
local file_metatable = getmetatable (io.stdin)
file_metatable.readlines  = io.readlines
file_metatable.writelines = io.writelines

-- Maintain old global interface access points.
for _, api in ipairs {
  "assert",
  "ileaves",
  "leaves",
  "pickle",
  "prettytostring",
  "render",
  "require_version",
  "tostring",
} do
  _G[api] = list[api] or _G[api]
  _G[api] = string[api] or _G[api]
end

local M = {
  version = version,
}

return M

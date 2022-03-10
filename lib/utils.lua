-- utilities
local _r = {}

function _r.fileExists(fname)
  local fi = io.open(fname)
  if not fi then return end
  fi:close()
  return true
end

return _r

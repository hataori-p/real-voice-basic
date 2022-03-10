-- FIR filter module
local _r = {}

function _r:new(response)
  local o = {}
  setmetatable(o, self)
  self.__index = self

  assert(#response > 1)

  local coefs = {}
  for i = 1, #response do
    table.insert(coefs, response[i])
  end
               -- mirrored second half
  for i = #response - 1, 1, -1 do
    table.insert(coefs, response[i])
  end

  o.coefs = coefs
  o.taps = 2 * (#response - 1) + 1
  assert(o.taps == #coefs)
  return o
end

function _r:filter(data) -- do the filtering
  local out, buff = {}, {}
  local smptr = 1
                   -- init buffer
  local d = data[1]
  for i = 1, self.taps do
    table.insert(buff, d)
  end
                 -- do one sample
  local function sample()
    local d
    if smptr <= #data then
      d = data[smptr]
      smptr = smptr + 1
    else
      d = data[#data]
    end

    table.insert(buff, 1, d) -- new sample
    table.remove(buff) -- last sample
              -- convolution
    local sum = 0
    for i = 1, self.taps do
      sum = sum + self.coefs[i] * buff[i]
    end

    return sum
  end
              -- prefilter to be zero phase
  for i = 1, math.floor(self.taps / 2) do
    sample()
  end

  for i = 1, #data do
    local d = sample()
    table.insert(out, d)
  end

  return out
end

return _r

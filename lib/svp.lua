-- SVP manipulation library
local _r = {}

local QUARTER = 705600000

local JSON = require("JSON")
JSON.strictTypes = true
function JSON:onTrailingGarbage(json_text, location, parsed_value, etc)
  return parsed_value
end

local function blick2Quarter(b)
  return b / QUARTER
end

local function blick2Seconds(b, bpm)
  return b / QUARTER * 60 / bpm
end

local function quarter2Blick(q)
  return q * QUARTER
end

local function seconds2Blick(s, bpm)
  return s / 60 * bpm * QUARTER
end

local function automationGetPoints(au, bg, en)
  local res = {}
  for i = 1, #au, 2 do
    local bl = au[i]
    if bl >= bg and bl <= en then
      table.insert(res, {
        b = bl,
        v = au[i + 1],
        i = i
      })
    end
  end
  return res
end

function _r:loadSVP(fnam) -- constructor
  local o = {}
  setmetatable(o, self)
  self.__index = self

  local fi = io.open(fnam)
  local txt = fi:read("*a")
  fi:close()

  o.js = JSON:decode(txt)

  local tms = o.js.time.tempo
  local tmpmarks = {}
  local t = 0
  for i, tm in ipairs(tms) do
    if i > 1 then
      t = t + blick2Seconds(tm.position, tms[i - 1].bpm)
    end

    table.insert(tmpmarks, {
      pos_b = tm.position,
      pos_t = t,
      bpm = tm.bpm
    })
  end

  o.tmpmarks = tmpmarks
  return o
end

function _r:saveSVP(fnam)
  local js = self.js
  local jstxt = JSON:encode(js)

  local fi = io.open(fnam, "w")
  fi:write(jstxt)
  fi:close()
end

function _r:getTempoMarkAt(b)
  local tms = self.tmpmarks
  local i = #tms
  while i > 1 do
    if tms[i].pos_b <= b then
      break
    else
      i = i - 1
    end
  end
  return {
    position = tms[i].pos_b,
    positionSeconds = tms[i].pos_t,
    bpm = tms[i].bpm
  }
end

function _r:getSecondsFromBlick(b)
  local tms = self.tmpmarks
  local i = #tms
  while i > 1 do
    if tms[i].pos_b <= b then
      break
    else
      i = i - 1
    end
  end
  return tms[i].pos_t + blick2Seconds(b - tms[i].pos_b, tms[i].bpm)
end

function _r:getBlickFromSeconds(t)
  local tms = self.tmpmarks
  local i = #tms
  while i > 1 do
    if tms[i].pos_t <= t then
      break
    else
      i = i - 1
    end
  end
  return math.floor(tms[i].pos_b + seconds2Blick(t - tms[i].pos_t, tms[i].bpm))
end

function _r:getTrackByName(name)
  local tracks = self.js.tracks
  local i = 1
  while i <= #tracks do
    if tracks[i].name == name then
      break
    end
    i = i + 1
  end

  if i <= #tracks then
    return tracks[i]
  end
end
               -- public consts & functions
_r.QUARTER = QUARTER
_r.blick2Quarter = blick2Quarter
_r.blick2Seconds = blick2Seconds
_r.quarter2Blick = quarter2Blick
_r.seconds2Blick = seconds2Blick
_r.automationGetPoints = automationGetPoints

return _r

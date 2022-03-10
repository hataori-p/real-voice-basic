-- Praat module

local _r = {}

function _r:getTimeRange(t1, t2) -- ret: list of points
  local res = {}
  for i = 1, self.header.nx do
    if self.data[i].t >= t1 and self.data[i].t <= t2 then
      table.insert(res, self.data[i])
    end
  end
  return res
end

------------ LFCC - cepstral coefs

local LFCCheader = {
{n="File_type", v="File type = \"ooTextFile\"", t="del"},
{n="Object_class", v="Object class = \"LFCC 1\"", t="del"},
{t="del"},
{n="xmin", t="num"},
{n="xmax", t="num"},
{n="nx", t="num"},
{n="dx", t="num"},
{n="x1", t="num"},
{n="fmin", t="num"},
{n="fmax", t="num"},
{n="maximumNumberOfCoefficients", t="num"}
}

function _r:loadLFCC(fnam) -- constructor, short text format, data: { {c0, c1 ... cn}, ... }
  local o = {}
  setmetatable(o, self)
  self.__index = self

  local data, header = {}, {}

  local fi = io.open(fnam)
  for i = 1, #LFCCheader do
    local lin = fi:read("*l")
    local h = LFCCheader[i]

    if h.v then
      assert(lin == h.v)
    elseif h.t == "num" then
      lin = tonumber(lin)
    end

    if h.n and h.t ~= "del" then
      header[h.n] = lin
    end
  end

  header["fileType"] = "ooTextFile"
  header["objectClass"] = "LFCC 1"
  assert(header.nx)

  for n = 1, header.nx do
    local ccnum = fi:read("*n", "*l")
    local ccs = {}
    if ccnum == 0 then
      fi:read("*l")
      for i = 0, header.maximumNumberOfCoefficients do
        table.insert(ccs, 0)
      end
    else
      for ci = 0, ccnum do
        local cc = fi:read("*n", "*l")
        table.insert(ccs, cc)
      end
    end
    table.insert(data, ccs)
  end
  fi:close()

  o.header = header
  o.data = data
  return o
end

------------ MFCC - mel cepstral coefs

local MFCCheader = {
{n="File_type", v="File type = \"ooTextFile\"", t="del"},
{n="Object_class", v="Object class = \"MFCC 1\"", t="del"},
{t="del"},
{n="xmin", t="num"},
{n="xmax", t="num"},
{n="nx", t="num"},
{n="dx", t="num"},
{n="x1", t="num"},
{n="fmin", t="num"},
{n="fmax", t="num"},
{n="maximumNumberOfCoefficients", t="num"}
}

function _r:loadMFCC(fnam) -- constructor, short text format, data: { {c0, c1 ... cn}, ... }
  local o = {}
  setmetatable(o, self)
  self.__index = self

  local data, header = {}, {}

  local fi = io.open(fnam)
  for i = 1, #MFCCheader do
    local lin = fi:read("*l")
    local h = MFCCheader[i]

    if h.v then
      assert(lin == h.v)
    elseif h.t == "num" then
      lin = tonumber(lin)
    end

    if h.n and h.t ~= "del" then
      header[h.n] = lin
    end
  end

  header["fileType"] = "ooTextFile"
  header["objectClass"] = "MFCC 1"
  assert(header.nx)

  for n = 1, header.nx do
    local ccnum = fi:read("*n", "*l")
    local ccs = {}
    if ccnum == 0 then
      fi:read("*l")
      for i = 0, header.maximumNumberOfCoefficients do
        table.insert(ccs, 0)
      end
    else
      for ci = 0, ccnum do
        local cc = fi:read("*n", "*l")
        table.insert(ccs, cc)
      end
    end
    table.insert(data, ccs)
  end
  fi:close()

  o.header = header
  o.data = data
  return o
end

------------ Pitch

local PitchHeader = {
{n="File_type", v="File type = \"ooTextFile\"", t="del"},
{n="Object_class", v="Object class = \"Pitch 1\"", t="del"},
{t="del"},
{n="xmin", t="num"},
{n="xmax", t="num"},
{n="nx", t="num"},
{n="dx", t="num"},
{n="x1", t="num"},
{n="ceiling", t="num"},
{n="maxnCandidates", t="num"}
}

function _r:loadPitch(fnam) -- constructor, short text format
  local o = {}
  setmetatable(o, self)
  self.__index = self

  local data, header = {}, {}

  local fi = io.open(fnam)
  for i = 1, #PitchHeader do
    local lin = fi:read("*l")
    local h = PitchHeader[i]

    if h.v then
      assert(lin == h.v)
    elseif h.t == "num" then
      lin = tonumber(lin)
    end

    if h.n and h.t ~= "del" then
      header[h.n] = lin
    end
  end

  header["fileType"] = "ooTextFile"
  header["objectClass"] = "Pitch 1"
  assert(header.nx)

  for i = 1, header.nx do
    local pitch = { i = i }
    pitch.t = (i - 1) * header.dx + header.x1

    local int = fi:read("*n", "*l") -- intensity
    local cand = fi:read("*n", "*l") -- candidates

    for k = 1, cand do
      local f = fi:read("*n", "*l")
      if k == 1 then
        pitch.f = f
      end
      fi:read("*n", "*l")
    end

    table.insert(data, pitch)
  end;
  fi:close()

  o.header = header
  o.data = data
  return o
end

function _r:pitchFromArray(arr, dx, x1, ceiling) -- constructor, short text format, 1 candidate
  assert(type(arr) == "table" and #arr > 0)
  assert(dx and dx > 0)
  x1 = x1 or 0
  ceiling = ceiling or 1000

  local o = {}
  setmetatable(o, self)
  self.__index = self

  local data, header = {}, {}

  header["fileType"] = "ooTextFile"
  header["objectClass"] = "Pitch 1"
  header["maxnCandidates"] = 1
  header["dx"] = dx
  header["x1"] = x1
  header["ceiling"] = ceiling
  header["nx"] = #arr
  header["xmin"] = 0
  header["xmax"] = (header.nx - 1) * header.dx + header.x1

  for i = 1, header.nx do
    local pitch = { i = i }
    pitch.t = (i - 1) * header.dx + header.x1
    pitch.f = arr[i]

    table.insert(data, pitch)
  end;

  o.header = header
  o.data = data
  return o
end

function _r:getPitch(t) -- ret: f0 [Hz]
  if t < self.data[1].t then return 0 end
  if t > self.data[#self.data].t then return 0 end

  local ll, rr = 1, #self.data
  while (rr-ll) > 1 do
    local cc = math.floor((rr + ll) / 2)
    if t <= self.data[cc].t then
      rr = cc
    else
      ll = cc
    end
  end

  local pf, pt = self.data[ll].f, self.data[rr].f
  if pf == 0 or pt == 0 then return 0 end

  local pf, pt = math.log(pf), math.log(pt)
  local fro, til = self.data[ll].t, self.data[rr].t

  return math.exp(pf + (pt - pf) / (til - fro) * (t - fro))
end

function _r:medianPitch(t_from, t_to)
  local points = _r.getTimeRange(self, t_from, t_to)
  local mnotes = {}

  for _, pt in ipairs(points) do
    if pt.f > 0 then
      table.insert(mnotes, pt.f)
    end
  end
  if #mnotes == 0 then return 0 end
                              -- median
  table.sort(mnotes)

  local i = math.floor(#mnotes / 2)
  return mnotes[i + 1]
end;

function _r:savePitch(fnam) -- short text format
  local data, header = self.data, self.header
  assert(#data == header.nx)
  local fi = io.open(fnam, "w")

  fi:write('File type = "ooTextFile"\n')
  fi:write('Object class = "Pitch 1"\n')
  fi:write("\n")
  fi:write(header.xmin.."\n")
  fi:write(header.xmax.."\n")
  fi:write(header.nx.."\n")
  fi:write(header.dx.."\n")
  fi:write(header.x1.."\n")
  fi:write(header.ceiling.."\n")
  fi:write(header.maxnCandidates.."\n")

  for _, pitch in ipairs(data) do
    fi:write("1.0\n") -- intensity
    fi:write("1\n") -- candidates

    local f = pitch.f
    if f < 20 then f = 0 end

    fi:write(f.."\n")
    if pitch.f == 0 then
      fi:write("0\n")
    else
      fi:write("1.0\n")
    end
  end;
  fi:close()
end

----------------- Intensity

local IntensityHeader = {
{n="File_type", v="File type = \"ooTextFile\"", t="del"},
{n="Object_class", v="Object class = \"Intensity 2\"", t="del"},
{t="del"},
{n="xmin", t="num"},
{n="xmax", t="num"},
{n="nx", t="num"},
{n="dx", t="num"},
{n="x1", t="num"},
{n="ymin", t="num"},
{n="ymax", t="num"},
{n="ny", t="num"},
{n="dy", t="num"},
{n="y1", t="num"}
}

function _r:loadIntensity(fnam) -- constructor, short text format
  local o = {}
  setmetatable(o, self)
  self.__index = self

  local data, header = {}, {}

  local fi = io.open(fnam)
  for i = 1, #IntensityHeader do
    local lin = fi:read("*l")
    local h = IntensityHeader[i]

    if h.v then
      assert(lin == h.v)
    elseif h.t == "num" then
      lin = tonumber(lin)
    end

    if h.n and h.t ~= "del" then
      header[h.n] = lin
    end
  end

  header["fileType"] = "ooTextFile"
  header["objectClass"] = "Intensity 2"
  assert(header.nx)

  for i = 1, header.nx do
    local int = { i = i }
    int.t = (i - 1) * header.dx + header.x1

    local ii = fi:read("*n", "*l") -- intensity
    int.db = ii
    table.insert(data, int)
  end;
  fi:close()

  o.header = header
  o.data = data
  return o
end

function _r:getIntensity(t) -- ret: I [dB]
  if t < self.data[1].t then return -100 end
  if t > self.data[#self.data].t then return -100 end

  local ll, rr = 1, #self.data
  while (rr-ll) > 1 do
    local cc = math.floor((rr + ll) / 2)
    if t <= self.data[cc].t then
      rr = cc
    else
      ll = cc
    end
  end

  local intf, intt = self.data[ll].db, self.data[rr].db
  if not intf or not intt then return -100 end

  local fro, til = self.data[ll].t, self.data[rr].t

  return intf + (intt - intf) / (til - fro) * (t - fro)
end

------------ Praat textGrid

local TextGridHeader = {
{n="File_type", v="File type = \"ooTextFile\"", t="del"},
{n="Object_class", v="Object class = \"TextGrid\"", t="del"},
{t="del"},
{n="xmin", t="num"},
{n="xmax", t="num"},
{v="<exists>", t="del"},
{n="tireCnt", t="num"},
{n="tireType", v="\"IntervalTier\""},
{n="tireName"},
{n="txmin", t="num"},
{n="txmax", t="num"},
{n="nx", t="num"},
}

function _r:loadFirstIntervalGridTier(fnam) -- constructor, short text format
  local o = {}
  setmetatable(o, self)
  self.__index = self

  local data, header = {}, {}

  local fi = io.open(fnam)
  for i = 1, #TextGridHeader do
    local lin = fi:read("*l")
    local h = TextGridHeader[i]

    if h.v then
      assert(lin == h.v)
    elseif h.t == "num" then
      lin = tonumber(lin)
    end

    if h.n and h.t ~= "del" then
      header[h.n] = lin
    end
  end

  header["fileType"] = "ooTextFile"
  header["objectClass"] = "TextGrid"
  assert(header.nx)

  for i = 1, header.nx do
    local interval = {}

    local time_from = fi:read("*n", "*l")
    local time_to = fi:read("*n", "*l")
    local txt = fi:read("*l")
    txt = txt:match("\"([^\"]+)\"") or ""

    table.insert(data, {
      fr = time_from,
      to = time_to,
      tx = txt
    })
  end;
  fi:close()

  o.header = header
  o.data = data
  return o
end

return _r

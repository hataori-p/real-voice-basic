-- SCRIPT_TITLE = "RV Notes to TextGrid"
-- Ver.1 - exports notes and lyrics to Praat's textGrid object, pitch encoded in lyrics,
--   after editing in Praat it can be loaded back by "RV Notes from TextGrid" ver.2
-- author = "Hataori@protonmail.com"
-- versionNumber = 1

local utils = require("utils")
local praat = require("praat")
local SVP = require("svp")
           -- script arguments
local arg = {...}
                                 -- show help
if #arg ~= 3 then
  print("RV: Exports notes from SVP track to Praat textGrid object")
  print("usage: rv notesToTextGrid <input_SVP_project> <track_name> <output_grid_file>")
  return
end
                                -- args to vars
local inputSVP, trackName, gridFileName = arg[1], arg[2], arg[3]

if not utils.fileExists(inputSVP) then
  print("Error: Cannot open the input SVP file '"..inputSVP.."'")
  return
end

local svp = SVP:loadSVP(inputSVP) -- project file

local track = svp:getTrackByName(trackName)
if not track then
  print("Error: track not found '"..trackName.."'")
  return
end

if track.mainRef.isInstrumental then
  print("Error: track is instrumental")
  return
end

local svpnotes = track.mainGroup.notes

local notes, maxtime = {}, 0
for i = 1, #svpnotes do
  local note = svpnotes[i]

  local lyr = note.lyrics
  local pitch = note.pitch - 69 -- midi offset
  local blOnset, blEnd = note.onset, note.onset + note.duration

  local tons = svp:getSecondsFromBlick(blOnset) -- start time
  local tend = svp:getSecondsFromBlick(blEnd) -- end time

  table.insert(notes, {
    lyr = lyr,
    pitch = pitch,
    tstart = tons,
    tend = tend
  })

  if tend > maxtime then maxtime = tend end
end
maxtime = maxtime + 1.0
        -- number of intervals
local cnt = 0
local pretim = 0
for _, nt in ipairs(notes) do
  if math.abs(nt.tstart - pretim) > 0.0001 then
    cnt = cnt + 1
  end
  cnt = cnt + 1

  pretim = nt.tend
end
cnt = cnt + 1
          -- write to file
local fo = io.open(gridFileName, "w")
fo:write("File type = \"ooTextFile\"\n")
fo:write("Object class = \"TextGrid\"\n")
fo:write("\n")
fo:write("0\n")
fo:write(maxtime.."\n")
fo:write("<exists>\n")
fo:write("1\n")
fo:write("\"IntervalTier\"\n")
fo:write("\"Notes\"\n")
fo:write("0\n")
fo:write(maxtime.."\n")
fo:write(cnt.."\n")

local pretim = 0
for _, nt in ipairs(notes) do
  if math.abs(nt.tstart - pretim) > 0.0001 then
    fo:write(pretim.."\n")
    fo:write(nt.tstart.."\n")
    fo:write("\"\"\n")

    fo:write(nt.tstart.."\n")
    fo:write(nt.tend.."\n")
    fo:write("\""..nt.lyr.." ("..nt.pitch..")\"\n")
  else
    fo:write((nt.tstart).."\n")
    fo:write(nt.tend.."\n")
    fo:write("\""..nt.lyr.." ("..nt.pitch..")\"\n")
  end

  pretim = nt.tend
end

fo:write(pretim.."\n")
fo:write((pretim + 1.0).."\n")
fo:write("\"\"\n")

fo:close()
print("done")

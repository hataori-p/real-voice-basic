# real-voice-basic
These scripts are intended as an extension of [Synthesizer V Studio Basic](https://dreamtonics.com/en/synthesizerv/) (a free version of Synthesizer V Studio Pro) from [Dreamtonics](https://dreamtonics.com/en/) to work with real voices similar way as [real-voice](https://github.com/hataori-p/real-voice) repo.

## Scripts ##
- _notesToTextGrid.lua_ - extracts notes from SVP project's track to Praat's textGrid object
  ~~~
  rv notesToTextGrid <input_SVP_project> <track_name> <output_grid_file>
  ~~~
- _notesFromTextGrid.lua_ - imports Praat's textGrid & pitch objects to specified track into a new SVP project file
  ~~~
  rv notesFromTextGrid <input_grid_file> <input_pitch_file> <scale> <input_SVP_project> <track_name> <output_SVP_project>
  ~~~
- _filterPitch.lua_ - filters Praat's pitch object file by low pass filter to lower noise
  ~~~
  rv filterPitch <input_pitch_file> <filtered_output_pitch_file>
  ~~~

## Installation (Windows)
Everything is tested only on Windows, but it should work on other platforms where [Lua](https://lua.org/) is working.

- Download this [zip archive](https://github.com/hataori-p/real-voice-basic/archive/refs/heads/main.zip),
- unzip it,
- and copy/move whole folder _real-voice-basic-main_ wherever you want and rename it to whatever you want, eg. _RealVoice_,
- if you don't have Lua installed on you computer, 
  - download last release of [Lua Binaries](http://luabinaries.sourceforge.net/) from its page, version >= 5.4 (eg. direct link to [lua-5.4.2_Win64_bin.zip](https://sourceforge.net/projects/luabinaries/files/5.4.2/Tools%20Executables/lua-5.4.2_Win64_bin.zip/download)),
  - from zip file extract and copy two binary files - _lua54.exe_ and _lua54.dll_ to your RealVoice directory (where rv.bat file is),
- edit the _rv.bat_ file and change the paths C:/RealVoice/ to your actual path
- append the RealVoice directory path into your system environment PATH variable in order to be able to run the rv batch script from your project directory

## Running scripts ##
from command prompt using _rv.bat_:

- run command prompt
- change to your SynthV project directory
- run script like this
  ~~~
  rv <script_name_without_lua_extension> <script_param1> <script_param2> ...
  ~~~
- eg.
  ~~~
  C:\projects\sakuranbo>rv notesFromTextGrid sb_TextGrid.txt sb_Pitch.txt chroma sb.svp "synth tuned" sb_tst.svp
  ~~~

## Installation (Linux, Mac)
I am not able provide instruction for installation on these systems.

Follow instructions on this Lua [Getting Started](https://www.lua.org/start.html) page:
> If you use Linux or Mac OS X, Lua is either already installed on your system or there is a Lua package for it. Make sure you get the latest release of Lua (currently 5.4.4).
>
> Lua is also quite easy to build from source, as explained below.

#### !!! It would be very appreciated if someone could figure out how to install it on these systems and perhaps write a short guide !!! ####

## Other software needed
You will also need [Praat](https://www.fon.hum.uva.nl/praat/) phonetic program installed and be able to run it.
It is available for many platforms.

## Demo videos
For the instructions how to use these scripts refer to my demonstration videos on Youtube
[playlist](https://youtube.com/playlist?list=PLHA_yIumhQPDJ3PULhXeE-gypioT-eear)

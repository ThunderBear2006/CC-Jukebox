local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()
local speaker = peripheral.find("speaker")

local selection = {}

local selection_index = 0

local function play_audio(path)
    for chunk in io.lines(path, 16 * 1024) do
        local buffer = decoder(chunk)
        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end

local function build_selection()
    local list = fs.list("music")
    for index = 1, #list do
        table.insert(selection, (list[index]:gsub(".dfpwm", "")))
    end
end

local function change_selection(index)
    local previous = index - 1
    local previous2 = index - 2
    local next = index + 1
    local next2 = index + 2
    selection_index = index

    if previous <= 0 then previous = #selection end
    if next > #selection then next = 1 end
    if previous2 <= 0 then previous2 = #selection end
    if next2 > #selection then next2 = 1 end

    term.setCursorPos(5,5)
    term.clear()
    term.write("     ^ "..selection[previous2])
    term.setCursorPos(5,6)
    term.write("     | "..selection[previous])
    term.setCursorPos(5,7)
    term.write("     | "..selection[index].."    <")
    term.setCursorPos(5,8)
    term.write("     | "..selection[next])
    term.setCursorPos(5,9)
    term.write("     v "..selection[next2])
end

local function print_playing(name)
    term.setCursorPos(0,5)
    term.clear()
    print("     Now playing: "..name)
end

if not speaker then 
  term.clear()
  error("Please attach a speaker") 
end

build_selection()

if #selection < 1 then error("No music to play") end

change_selection(1)

while true do

    local event = {os.pullEvent()}

    if event[1] == "key" then

      if event[2] == keys.up then
          if selection_index - 1 < 1 then
              change_selection(#selection)
          else
              change_selection(selection_index - 1)
          end
      elseif event[2] == keys.down then
          if selection_index + 1 > #selection then
              change_selection(1)
          else
              change_selection(selection_index + 1)
          end
      elseif event[2] == keys.enter then
          print_playing(selection[selection_index])
          play_audio("music/"..selection[selection_index]..".dfpwm")
          change_selection(selection_index)
      end
    end

end

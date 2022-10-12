-- Seeking that takes into account playback speed. I.e., if seeking 3 second
-- backwards, it will actually seek 3 perceived seconds, as opposed to 3
-- seconds in the video.
function seek_back_three()
  mp.commandv("seek", -1 * 3 * mp.get_property_number("speed"), "exact")
end
function seek_forward_three()
  mp.commandv("seek", 3 * mp.get_property_number("speed"), "exact")
end

mp.add_key_binding("LEFT", "seek_back_three", seek_back_three)
mp.add_key_binding("RIGHT", "seek_forward_three", seek_forward_three)


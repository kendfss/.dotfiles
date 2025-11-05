function debug_metadata()
	local metadata = mp.get_property_native("metadata") or {}
	print("=== Available Metadata ===")
	for k, v in pairs(metadata) do
		print(k .. ": " .. tostring(v))
	end
	print("==========================")
end

function notify_track_change()
	-- Debug: print all available metadata
	debug_metadata()

	-- Try different property names for metadata
	local title = mp.get_property("media-title")
		or mp.get_property("metadata/title")
		or mp.get_property("metadata/TITLE")
		or "Unknown Title"

	local artist = mp.get_property("metadata/artist")
		or mp.get_property("metadata/ARTIST")
		or mp.get_property("metadata/album_artist")
		or "Unknown Artist"

	local album = mp.get_property("metadata/album") or mp.get_property("metadata/ALBUM") or "Unknown Album"

	local year = mp.get_property("metadata/date")
		or mp.get_property("metadata/YEAR")
		or mp.get_property("metadata/originaldate")
		or "Unknown Year"

	-- Build notification
	local message = string.format("Artist: %s\nAlbum: %s\nYear: %s", artist, album, year)

	-- Escape for shell
	title = title:gsub('"', '\\"'):gsub("`", "\\`")
	message = message:gsub('"', '\\"'):gsub("`", "\\`")

	-- Send notification with longer timeout
	local cmd = string.format('notify-send -t 8000 -u low -i audio-x-generic "%s" "%s"', title, message)
	print("Executing: " .. cmd)
	os.execute(cmd)
end

-- Multiple triggers to catch different scenarios
mp.register_event("file-loaded", function()
	mp.add_timeout(0.5, notify_track_change)
end)

mp.observe_property("playlist-pos", "number", function(name, value)
	if value then
		mp.add_timeout(0.3, notify_track_change)
	end
end)

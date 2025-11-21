function listdir(directory)
	local i, t, popen = 0, {}, io.popen
	local pfile = popen('ls -1a "' .. directory .. '"')
	if pfile then
		for filename in pfile:lines() do
			i = i + 1
			t[i] = filename
		end
		pfile:close()
	end
	return t
end

function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

function base_name(path)
	parts = split(path, "/")
	return parts[parts.len()]
end

function on_path(name)
	local path = os.getenv("PATH")
	local parts = split(path, ":")
	for dir in parts do
		local items = listdir(dir)
		for item in items do
			base = base_name(item)
			if base == name then
				return true
			end
		end
	end
	return false
end

local last_id = nil
function notify_track()
	if !on_path("notify-send") then
		return
	end
	local path = mp.get_property("path") or ""
	local title = mp.get_property("media-title") or ""
	local id = path .. "|" .. title

	if id == last_id then
		return
	end
	last_id = id
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
	os.execute(cmd)
end

-- Multiple triggers to catch different scenarios
mp.register_event("file-loaded", function()
	mp.add_timeout(0.5, notify_track)
end)

mp.observe_property("playlist-pos", "number", function(name, value)
	if value then
		mp.add_timeout(0.3, notify_track)
	end
end)

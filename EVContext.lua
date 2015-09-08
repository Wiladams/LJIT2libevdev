--EVContext.lua
local ffi = require("ffi")
local libevdev = require("libevdev_ffi")

EVContext = {}
function EVContext.newDevice()
	local dev = libevdev.libevdev_new();
	return EVDevice:init(dev);
end

return EVContext;

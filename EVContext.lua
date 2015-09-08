--EVContext.lua
local ffi = require("ffi")
local libevdev = require("libevdev_ffi")

EVContext = {}
function EVContext.newDevice(self)
	local dev = libevdev.libevdev_new();
	ffi.gc(dev, libevdev.libevdev_free);

	return EVDevice:init(dev);
end

function EVContext.setLogFunction(self, logfunc, data)
	libevdev.libevdev_set_log_function(logfunc, data);

	return true;
end

function EVContext.logPriority(self, priority)
	if not priority then
		return tonumber(libevdev.libevdev_get_log_priority());
	end

	libevdev.libevdev_set_log_priority(priority);
end

return EVContext;

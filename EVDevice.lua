
local ffi = require("ffi")

local libevdev = require("libevdev_ffi")
local EVDevice = {}
setmetatable(EVDevice, {
	__call = function(self, ...)
		return self:new(...);
	end,
})
local EVDevice_mt = {
	__index = EVDevice;
}

function EVDevice.init(self, handle)
	local obj = {
		Handle = handle;
	}
	setmetatable(obj, EVDevice_mt);

	return obj;
end

--[[
	Can be constructed a couple of different ways
	EVDevice(fd) - pass in an already opened file handle
	EVDevice(name, access) - pass in a device name and intended access
--]]
function EVDevice.new(self, ...)
end


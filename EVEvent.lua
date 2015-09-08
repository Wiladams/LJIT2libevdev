-- EVEvent.lua

local ffi = require("ffi")
local bit = require("bit")
local band, bor = bit.band, bit.bor;

local libevdev = require("libevdev_ffi")
local libc = require("libc")


local EVEvent = {}
setmetatable(EVEvent, {
	__call = function(self, ...)
		return self:new(...);
	end,
})
local EVEvent_mt = {
	__index = EVEvent;
}

function EVEvent.init(self, handle)
	local obj = {
		Handle = handle;
	}
	setmetatable(obj, EVEvent_mt);

	return obj;
end

function EVEvent.new(self, handle)
	return self:init(handle);
end

function EVEvent.typeName(self, aname)
    local str = libevdev.libevdev_event_type_get_name(self.Handle.type);
    return ffi.string(str);
end

function EVEvent.codeName(self, aname)
	local str = libevdev.libevdev_event_code_get_name(self.Handle.type, self.Handle.code);
	return ffi.string(str);
end

function EVEvent.value(self, value)
	return tonumber(self.Handle.value);
end

return EVEvent;

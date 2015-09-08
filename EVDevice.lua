--[[
	EVDevice 
	Represents a single libevdev device
	You can create a blank one, and fill it in, as if creating one for event injection
	Or you can create one from a filename
	Or you can create one from an existing file descriptor
--]]

local ffi = require("ffi")
local bit = require("bit")
local band, bor = bit.band, bit.bor;

local libevdev = require("libevdev_ffi")
local libc = require("libc")
local EVEvent = require("EVEvent")


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
	local dev = nil;
	local fd = 0;

	if select('#', ...) < 1 then
		return nil, "not enough arguments specified"
	end

	
	if type(select(1, ...)) == "string" then
		-- a filename was specified
		local access = select(2, ...) or bor(libc.O_RDONLY,libc.O_NONBLOCK);
		fd = libc.open(select(1,...), access);	
	end

	local dev = ffi.new("struct libevdev *[1]")
	local rc = libevdev.libevdev_new_from_fd(fd, dev);
	if (rc < 0) then
         return nil, string.format("Failed to init libevdev (%s)\n", libc.strerror(-rc));
	end
	dev = dev[0];
	ffi.gc(dev, libevdev.libevdev_free);

	return EVDevice:init(dev);
end

-- Qualities
function EVDevice.hasEventPending(self)
	return libevdev.libevdev_has_event_pending(self.Handle) == 1;
end

function EVDevice.hasEventType(self, atype)
	return libevdev.libevdev_has_event_type(self.Handle, atype) == 1;
end

-- Attributes
function EVDevice.busType(self)
	return tonumber(libevdev.libevdev_get_id_bustype(self.Handle));
end

function EVDevice.vendorId(self)
	return tonumber(libevdev.libevdev_get_id_vendor(self.Handle));
end

function EVDevice.productId(self)
    return tonumber(libevdev.libevdev_get_id_product(self.Handle));
end

function EVDevice.name(self, name)
	local str = libevdev.libevdev_get_name(self.Handle);
	return ffi.string(str);
end

function EVDevice.physical(self, name)
	local str = libevdev.libevdev_get_phys(self.Handle)
	return ffi.string(str)
end

function EVDevice.unique(self, name)
	local str = libevdev.libevdev_get_uniq(self.Handle)
	return ffi.string(str)
end


-- Events

-- Iterator of events
-- will block until an even comes
function EVDevice.events(self, flags, ev)
	local function iter_gen(param, state)
		local flags = flags or ffi.C.LIBEVDEV_READ_FLAG_NORMAL;
		local ev = ev or ffi.new("struct input_event");
		local rc = 0;
		repeat
			rc = libevdev.libevdev_next_event(param.Handle, flags, ev);
		until rc ~= -libc.EAGAIN
		if (rc == ffi.C.LIBEVDEV_READ_STATUS_SUCCESS) or (rc == ffi.C.LIBEVDEV_READ_STATUS_SYNC) then
			return ev, EVEvent(ev);
		end

		return nil, rc;
	end

	return iter_gen, self, state 
end

return EVDevice

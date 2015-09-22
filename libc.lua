--[[
	Just some simple definitions used by the data structures
	or convenience functions.

	If these are defined somewhere else in a larger project, then
	this file can go away.
--]]
local ffi = require("ffi")
local bit = require("bit")
local band, bor = bit.band, bit.bor
local lshift, rshift = bit.lshift, bit.rshift


-- very x86_64 specific
local IOC = {
  DIRSHIFT = 30;
  TYPESHIFT = 8;
  NRSHIFT = 0;
  SIZESHIFT = 16;
}

local function ioc(dir, ch, nr, size)
  if type(ch) == "string" then ch = ch:byte() end

  return bor(lshift(dir, IOC.DIRSHIFT), 
       lshift(ch, IOC.TYPESHIFT), 
       lshift(nr, IOC.NRSHIFT), 
       lshift(size, IOC.SIZESHIFT))
end

local function _IOC(a,b,c,d) 
  return ioc(a,b,c,d);
end

local _IOC_NONE  = 0;
local _IOC_WRITE = 1;
local _IOC_READ  = 2;

local function _IO(a,b) return _IOC(_IOC_NONE,a,b,0) end
local function _IOW(a,b,c) return _IOC(_IOC_WRITE,a,b,ffi.sizeof(c)) end
local function _IOR(a,b,c) return _IOC(_IOC_READ,a,b,ffi.sizeof(c)) end
local function _IOWR(a,b,c) return _IOC(bor(_IOC_READ,_IOC_WRITE),a,b,ffi.sizeof(c)) end


local function octal(value)
	return tonumber(value, 8);
end

--[[
	ioctl for input
--]]

-- TODO
-- As struct timeval is in common libc headers, this definition can 
-- go away if it's already defined
-- Also, this definition may not be correct for 32-bit
ffi.cdef[[
typedef long time_t;
typedef long suseconds_t;

struct timeval { time_t tv_sec; suseconds_t tv_usec; };
]]

ffi.cdef[[
int printf(const char *__restrict, ...);
int open(const char *, int, ...);
extern char *strerror (int __errnum);
]]

local function safeffistring(value)
	if value == nil then
		return nil;
	end

	return ffi.string(value);
end

local exports = {
	-- Constants
	O_NONBLOCK		= octal('04000');
	O_RDONLY  		= 00;
	O_WRONLY		= 01;
	O_RDWR			= 02;

	EAGAIN			= 11;

	-- library functions
	open = ffi.C.open;
	printf = ffi.C.printf;
	strerror = ffi.C.strerror;

	-- Local functions
	octal = octal;
	safeffistring = safeffistring;

	-- ioctl
	_IOC_NONE = _IOC_NONE;
	_IOC_READ = _IOC_READ;
	_IOC_WRITE = _IOC_WRITE;

	_IOC = _IOC;
	_IO = _IO;
	_IOR = _IOR;
	_IOW = _IOW;
	_IOWR = _IOWR;
}

setmetatable(exports, {
	__call = function(self, tbl)
		tbl = tbl or _G;
		for k,v in pairs(self) do
			tbl[k] = v;
		end
		return self;
	end,
})

return exports

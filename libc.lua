--[[
	Just some simple definitions used by the data structures
	or convenience functions.

	If these are defined somewhere else in a larger project, then
	this file can go away.
--]]
local ffi = require("ffi")

local function octal(value)
	return tonumber(value, 8);
end

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
	safeffistring = safeffistring;
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

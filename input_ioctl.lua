
local ffi = require("ffi")
local bit = require("bit")
local band, bor = bit.band, bit.bor
local lshift, rshift = bit.lshift, bit.rshift

local input = require("linux_input")
local libc = require("libc")

-- Straight from the linux/input.h header

local EVIOCGVERSION   = _IOR('E', 0x01, ffi.typeof("int"));     -- get driver version 
local EVIOCGID        = _IOR('E', 0x02, ffi.typeof("struct input_id")); -- get device ID 
local EVIOCGREP       = _IOR('E', 0x03, ffi.typeof("unsigned int[2]")); -- get repeat settings 
local EVIOCSREP       = _IOW('E', 0x03, ffi.typeof("unsigned int[2]")); -- set repeat settings 

local EVIOCGKEYCODE   = _IOR('E', 0x04, ffi.typeof("unsigned int[2]"));        -- get keycode 
local EVIOCGKEYCODE_V2= _IOR('E', 0x04, ffi.typeof("struct input_keymap_entry"));
local EVIOCSKEYCODE   = _IOW('E', 0x04, ffi.typeof("unsigned int[2]"));        -- set keycode 
local EVIOCSKEYCODE_V2= _IOW('E', 0x04, ffi.typeof("struct input_keymap_entry"));

local EVIOCGNAME = function(len)  return _IOC(_IOC_READ, 'E', 0x06, len) end    -- get device name 
local EVIOCGPHYS = function(len)  return _IOC(_IOC_READ, 'E', 0x07, len) end    -- get physical location 
local EVIOCGUNIQ = function(len)  return _IOC(_IOC_READ, 'E', 0x08, len) end    -- get unique identifier 
local EVIOCGPROP = function(len)  return _IOC(_IOC_READ, 'E', 0x09, len) end    -- get device properties 


--[[
local EVIOCGMTSLOTS(len)  _IOC(_IOC_READ, 'E', 0x0a, len)

local EVIOCGKEY(len)    _IOC(_IOC_READ, 'E', 0x18, len)   -- get global key state 
local EVIOCGLED(len)    _IOC(_IOC_READ, 'E', 0x19, len)   -- get all LEDs 
local EVIOCGSND(len)    _IOC(_IOC_READ, 'E', 0x1a, len)   -- get all sounds status 
local EVIOCGSW(len)   _IOC(_IOC_READ, 'E', 0x1b, len)   -- get all switch states 

local EVIOCGBIT(ev,len) _IOC(_IOC_READ, 'E', 0x20 + (ev), len)  -- get event bits 
local EVIOCGABS(abs)    _IOR('E', 0x40 + (abs), struct input_absinfo) -- get abs value/limits 
local EVIOCSABS(abs)    _IOW('E', 0xc0 + (abs), struct input_absinfo) -- set abs value/limits 

local EVIOCSFF    _IOC(_IOC_WRITE, 'E', 0x80, sizeof(struct ff_effect)) -- send a force effect to a force feedback device 
local EVIOCRMFF   _IOW('E', 0x81, int)      -- Erase a force effect 
local EVIOCGEFFECTS   _IOR('E', 0x84, int)      -- Report number of effects playable at the same time 

local EVIOCGRAB   _IOW('E', 0x90, int)      -- Grab/Release device 
local EVIOCREVOKE   _IOW('E', 0x91, int)      -- Revoke device access 

local EVIOCSCLOCKID   _IOW('E', 0xa0, int)      -- Set clockid to be used for timestamps 
--]]


--[[
local bit = require "bit"

local band = bit.band
local function bor(...)
  local r = bit.bor(...)
  if r < 0 then r = r + 4294967296 end -- TODO see note in NetBSD
  return r
end
local lshift = bit.lshift
local rshift = bit.rshift

-- these can vary by architecture
local IOC = arch.IOC or {
  SIZEBITS = 14,
  DIRBITS = 2,
  NONE = 0,
  WRITE = 1,
  READ = 2,
}

IOC.READWRITE = IOC.READ + IOC.WRITE

IOC.NRBITS	= 8
IOC.TYPEBITS	= 8

IOC.NRMASK	= lshift(1, IOC.NRBITS) - 1
IOC.TYPEMASK	= lshift(1, IOC.TYPEBITS) - 1
IOC.SIZEMASK	= lshift(1, IOC.SIZEBITS) - 1
IOC.DIRMASK	= lshift(1, IOC.DIRBITS) - 1

IOC.NRSHIFT   = 0
IOC.TYPESHIFT = IOC.NRSHIFT + IOC.NRBITS
IOC.SIZESHIFT = IOC.TYPESHIFT + IOC.TYPEBITS
IOC.DIRSHIFT  = IOC.SIZESHIFT + IOC.SIZEBITS

local function ioc(dir, ch, nr, size)
  if type(ch) == "string" then ch = ch:byte() end
  return bor(lshift(dir, IOC.DIRSHIFT), 
	     lshift(ch, IOC.TYPESHIFT), 
	     lshift(nr, IOC.NRSHIFT), 
	     lshift(size, IOC.SIZESHIFT))
end

local singletonmap = {
  int = "int1",
  char = "char1",
  uint = "uint1",
  uint32 = "uint32_1",
  uint64 = "uint64_1",
}
local sizes = {
	int1 = ffi.sizeof("int");
	char1 = ffi.sizeof("char");
	uint1 = ffi.sizeof("unsigned int");
	uint32 = ffi.sizeof("uint32_t");
	uint64 = ffi.sizeof("uint54_t");
}

local function _IOC(dir, ch, nr, tp)
  if not tp or type(tp) == "number" then return ioc(dir, ch, nr, tp or 0) end
  local size = sizes[tp]
  local singleton = singletonmap[tp] ~= nil
  tp = singletonmap[tp] or tp
  return {number = ioc(dir, ch, nr, size),
          read = dir == IOC.READ or dir == IOC.READWRITE, write = dir == IOC.WRITE or dir == IOC.READWRITE,
          type = t[tp], singleton = singleton}
end

-- used to create numbers
local _IO    = function(ch, nr)		return _IOC(IOC.NONE, ch, nr, 0) end
local _IOR   = function(ch, nr, tp)	return _IOC(IOC.READ, ch, nr, tp) end
local _IOW   = function(ch, nr, tp)	return _IOC(IOC.WRITE, ch, nr, tp) end
local _IOWR  = function(ch, nr, tp)	return _IOC(IOC.READWRITE, ch, nr, tp) end

-- used to decode ioctl numbers..
local _IOC_DIR  = function(nr) return band(rshift(nr, IOC.DIRSHIFT), IOC.DIRMASK) end
local _IOC_TYPE = function(nr) return band(rshift(nr, IOC.TYPESHIFT), IOC.TYPEMASK) end
local _IOC_NR   = function(nr) return band(rshift(nr, IOC.NRSHIFT), IOC.NRMASK) end
local _IOC_SIZE = function(nr) return band(rshift(nr, IOC.SIZESHIFT), IOC.SIZEMASK) end

-- ...and for the drivers/sound files...

IOC.IN		= lshift(IOC.WRITE, IOC.DIRSHIFT)
IOC.OUT		= lshift(IOC.READ, IOC.DIRSHIFT)
IOC.INOUT		= lshift(bor(IOC.WRITE, IOC.READ), IOC.DIRSHIFT)
local IOCSIZE_MASK	= lshift(IOC.SIZEMASK, IOC.SIZESHIFT)
local IOCSIZE_SHIFT	= IOC.SIZESHIFT
--]]

--[[
-- event system
  EVIOCGVERSION   = _IOR('E', 0x01, "int");		-- get driver version
  EVIOCGID        = _IOR('E', 0x02, "input_id");	-- get device ID
  EVIOCGREP       = _IOR('E', 0x03, "uint2");		-- get repeat settings
  EVIOCSREP       = _IOW('E', 0x03, "uint2");		-- set repeat settings

  EVIOCGKEYCODE   = _IOR('E', 0x04, "uint2");	-- get keycode
  EVIOCGKEYCODE_V2 = _IOR('E', 0x04, "input_keymap_entry");
  EVIOCSKEYCODE   = _IOW('E', 0x04, "uint2");	-- set keycode
  EVIOCSKEYCODE_V2 = _IOW('E', 0x04, "input_keymap_entry");
  
  EVIOCGNAME = function(len) return _IOC(IOC.READ, 'E', 0x06, len) end;		-- get device name
  EVIOCGPHYS = function(len) return _IOC(IOC.READ, 'E', 0x07, len) end;		-- get physical location
  EVIOCGUNIQ = function(len) return _IOC(IOC.READ, 'E', 0x08, len) end;		-- get unique identifier
  EVIOCGPROP = function(len) return _IOC(IOC.READ, 'E', 0x09, len) end;		-- get device properties
  EVIOCGKEY  = function(len) return _IOC(IOC.READ, 'E', 0x18, len) end;
  EVIOCGLED  = function(len) return _IOC(IOC.READ, 'E', 0x19, len) end;
  EVIOCGSND  = function(len) return _IOC(IOC.READ, 'E', 0x1a, len) end;
  EVIOCGSW   = function(len) return _IOC(IOC.READ, 'E', 0x1b, len) end;
  EVIOCGBIT  = function(ev, len) return _IOC(IOC.READ, 'E', 0x20 + ev, len) end;
  EVIOCGABS  = function(abs) return _IOR('E', 0x40 + abs, "input_absinfo") end;
  EVIOCSABS  = function(abs) return _IOW('E', 0xc0 + abs, "input_absinfo") end;
  EVIOCSFF   = _IOC(IOC.WRITE, 'E', 0x80, "ff_effect");
  EVIOCRMFF  = _IOW('E', 0x81, "int");
  EVIOCGEFFECTS = _IOR('E', 0x84, "int");
  EVIOCGRAB  = _IOW('E', 0x90, "int");
-- input devices
  UI_DEV_CREATE  = _IO ('U', 1);
  UI_DEV_DESTROY = _IO ('U', 2);
  UI_SET_EVBIT   = _IOW('U', 100, "int");
  UI_SET_KEYBIT  = _IOW('U', 101, "int");
--]]





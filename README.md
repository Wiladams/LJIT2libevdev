# LJIT2libevdev
LuaJIT binding to libevdev

libevdev is a library which primarily wraps all the low level ioctl calls that
support getting raw input device data (keyboard, mouse, joystick) on a Linux system.
This binding brings the libevdev functions into the luajit environment.

There are two levels of interface.  At the lowest level, there are fairly raw ffi.cdef
definitions for all the functions found within the library.  If you want to program 
against an interface that is familiar to 'C' programming, then you can use the 'libevdev_ffi'
module directly, and be happy.

If you prefer a more Lua like experience, where the low level C strings are turned into
Lua strings, and iterators are used to get streams of events, then you can program against
the more object oriented interface represented by the EVDevice module.

Here is a typical usage, where we want to track mouse activity using the low level interface.

```lua
local ffi = require("ffi")
local bit = require("bit")
local bor, band = bit.bor, bit.band;
local libevdev = require("libevdev_ffi")(_G);
local input = require("linux_input")(_G);
local setup = require("test_setup")();



local fd = open("/dev/input/event5", bor(O_RDONLY,O_NONBLOCK));
local dev = ffi.new("struct libevdev *[1]")
local rc = libevdev_new_from_fd(fd, dev);
if (rc < 0) then
         printf("Failed to init libevdev (%s)\n", strerror(-rc));
         error(1);
end
dev = dev[0];

printf("Input device name: \"%s\"\n", libevdev_get_name(dev));
printf("Input device ID: bus %#x vendor %#x product %#x\n",
        libevdev_get_id_bustype(dev),
        libevdev_get_id_vendor(dev),
        libevdev_get_id_product(dev));

if (libevdev_has_event_type(dev, EV_REL)==0 or libevdev_has_event_code(dev, EV_KEY, BTN_LEFT)==0) then
         printf("This device does not look like a mouse\n");
         error(1);
end

local ev = ffi.new("struct input_event");
repeat 
    rc = libevdev_next_event(dev, ffi.C.LIBEVDEV_READ_FLAG_NORMAL, ev);
    if (rc == 0) then
        printf("Event: %s %s %d\n",
            libevdev_event_type_get_name(ev.type),
            libevdev_event_code_get_name(ev.type, ev.code),
            ev.value);
    end
until (rc ~= 1 and rc ~= 0 and rc ~= -EAGAIN);
```


And here is the code version if you choose to use the more objectified
version of the API.

```lua
local input = require("linux_input")(_G);
local EVDevice = require("EVDevice")


local dev, err = EVDevice("/dev/input/event3")

assert(dev, err)

print(string.format("Input device name: \"%s\"\n", dev:name()));
print(string.format("Input device ID: bus %#x vendor %#x product %#x\n",
        dev:busType(),
        dev:vendorId(),
        dev:productId()));

if (not dev:hasEventType(EV_REL) or not dev:hasEventType(EV_KEY, BTN_LEFT)) then
    print(string.format("This device does not look like a mouse\n"));
    error(1);
end

for _, ev in dev:events() do
    print(string.format("Event: %s %s %d\n",
        ev:typeName(),
        ev:codeName(),
        ev:value()));
end
```

And finally, the brain dead simple version (trackdevice.lua) which can be used to track the 
events on any known device:

```bash
$ trackdevice.lua /dev/input/event3
```

The code for trackdevice.lua looks like this:

```lua
package.path = package.path..";../?.lua"

local dev = require("EVDevice")(arg[1])
assert(dev)
local utils = require("utils")


utils.printDevice(dev);
print("===== ===== =====")

-- filter out the non-essential event reports
local function filter(ev)
    return ev:typeName() ~= "EV_SYN" and ev:typeName() ~= "EV_MSC"
end

for _, ev in dev:events(filter) do
    print(string.format("{'%s', '%s', %d};",ev:typeName(),ev:codeName(),ev:value()));
end
```

In this case, you can almost forget you're using a native C library, and just
enjoy the ease of programming with script.  All garbage collection, string conversion
and the like is handled by the object interface.

Device Selection
----------------
If you don't know which specific /dev/input/eventxxx represents your device, but you know the kind of device, such as mouse, you could use the device query/filtering in the following way:

```lua
local EVContext = require("EVContext")

local dev = EVContext:getMouse();

print(string.format("Input device name: \"%s\"", dev:name()));
print(string.format("Input device ID: bus %#x vendor %#x product %#x\n",
        dev:busType(),
        dev:vendorId(),
        dev:productId()));

-- print out a constant stream of events
for _, ev in dev:events() do
    print(string.format("Event: %s %s %d",
        ev:typeName(),
        ev:codeName(),
        ev:value()));
end
```
This last makes it fairly easy to get a quick handle on generic devices.  You can go further and provide a filtering function to target a more specific mouse, such as 'Logitech', or you could filter on any aspect of the device, such as "has three axes".  This filtering characteristic makes it very convenient to get a handle on a device based on required characteristics.

References
----------
* http://www.freedesktop.org/software/libevdev/doc/0.4/index.html
* http://www.freedesktop.org/wiki/InputArchitecture/
* http://who-t.blogspot.com/2013/09/libevdev-handling-input-events.html
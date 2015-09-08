package.path = package.path..";../?.lua"
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

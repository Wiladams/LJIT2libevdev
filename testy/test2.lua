--[[
    Use the object interface to simplify making the library calls.
--]]
package.path = package.path..";../?.lua"
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

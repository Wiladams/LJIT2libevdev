--[[
    Use the object interface to simplify making the library calls.
    Open up something that might be a mouse, and track it
--]]
package.path = package.path..";../?.lua"
local input = require("linux_input");

local EVContext = require("EVContext")

local function isTrackPad(dev)
	return dev:hasProperty(input.Constants.INPUT_PROP_SEMI_MT)
end

local dev = EVContext:getDevice(isTrackPad);

assert(dev, "no trackpad found")

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

--[[
    Use the object interface to simplify making the library calls.
    Open up something, and track it

    Usage:
    $ sudo luajit trackdevice /dev/input/eventxxx

    where 'xxx' is the event number you want to track.
--]]

package.path = package.path..";../?.lua"

local dev = require("EVDevice")(arg[1])
assert(dev)


print(string.format("Input device name: \"%s\"", dev:name()));
print(string.format("Input device ID: bus %#x vendor %#x product %#x\n",
        dev:busType(),
        dev:vendorId(),
        dev:productId()));

-- print out a constant stream of events
local function filter(ev)
--	print("TYPENAME: ", ev:typeName(), ev:typeName() ~= "EV_SYN")
	return ev:typeName() ~= "EV_SYN" and ev:typeName() ~= "EV_MSC"
end

for _, ev in dev:events(filter) do
    print(string.format("{'%s', '%s', %d};",ev:typeName(),ev:codeName(),ev:value()));
end

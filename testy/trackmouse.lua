--[[
    Open up something that might be a mouse, and track it
--]]
package.path = package.path..";../?.lua"

local EVContext = require("EVContext")

-- This predicate function can be passed into getMouse(isLogitech)
-- if you want to get a mouse that is from Logitech
local function isLogitech(dev)
	return dev:name():lower():find("logitech") ~= nil
end

local dev = EVContext:getMouse();

assert(dev, "no mouse found")

print(string.format("Input device name: \"%s\"", dev:name()));
print(string.format("Input device ID: bus %#x vendor %#x product %#x\n",
        dev:busType(),
        dev:vendorId(),
        dev:productId()));

-- print out a constant stream of events
for _, ev in dev:events() do
	if ev:typeName() == "EV_REL" or ev:typeName() == "EV_KEY" then
    	print(string.format("Event: %s %s %d",
        ev:typeName(),
        ev:codeName(),
        ev:value()));
	end
end

--enumdevs.lua
--[[
	Enumerate all the /dev/input/event devices
	printing something interesting about each one
--]]
package.path = package.path..";../?.lua"
local EVContext = require("EVContext")

for _, dev in EVContext:devices() do
	print("==== Device ====")
	print("    Node: ", dev.NodeName)
	print("    Name: ", dev:name())
	print("Physical: ", dev:physical())
	dev:printProperties();
end

print("== DONE ==")
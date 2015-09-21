#!/usr/bin/env luajit
--[[
    Use this script to continuously tracky any kind of input device
    that is generating events.  It will print out the meta data for 
    the event.  This is convenient when you've got a new input device
    and you want to discover the series of event types and codes that
    it generates.

    Usage:
    $ sudo trackdevice.lua /dev/input/eventxxx

    where 'xxx' is the event number you want to track.
--]]

package.path = package.path..";../?.lua"

local dev = require("EVDevice")(arg[1])
assert(dev)
local utils = require("utils")


utils.printDevice(dev);
print("===== ===== =====")

-- print out a constant stream of events
local function filter(ev)
--	print("TYPENAME: ", ev:typeName(), ev:typeName() ~= "EV_SYN")
	return ev:typeName() ~= "EV_SYN" and ev:typeName() ~= "EV_MSC"
end

for _, ev in dev:events(filter) do
    print(string.format("{'%s', '%s', %d};",ev:typeName(),ev:codeName(),ev:value()));
end

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

local EVEvent = require("EVEvent")
local dev = require("EVDevice")(arg[1])
assert(dev)

local utils = require("utils")
local fun = require("fun")

-- print out the device particulars before 
-- printing out the stream of events
utils.printDevice(dev);
print("===== ===== =====")

-- perform the actual printing of the event
local function printEvent(ev)
    print(string.format("{'%s', '%s', %d};",ev:typeName(),ev:codeName(),ev:value()));
end

-- decide whether an event is interesting enough to 
-- print or not
local function isInteresting(ev)
	return ev:typeName() ~= "EV_SYN" and ev:typeName() ~= "EV_MSC"
end

-- convert from a raw 'struct input_event' to the EVEvent object
local function toEVEvent(rawev)
    return EVEvent(rawev)
end


fun.each(printEvent, fun.filter(isInteresting, fun.map(toEVEvent,dev:rawEvents())));

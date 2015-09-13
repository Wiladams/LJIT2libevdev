#!/usr/bin/env luajit
--enumdevs.lua
--[[
	Enumerate all the /dev/input/event devices
	printing something interesting about each one
--]]
package.path = package.path..";../?.lua"
local EVContext = require("EVContext")
local utils = require("utils")


for _, dev in EVContext:devices() do
	utils.printDevice(dev)
end

print("== DONE ==")

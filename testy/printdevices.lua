#!/usr/bin/env luajit

--[[
	Enumerate all the /dev/input/event devices
	printing something interesting about each one

	In this case we use the functional program 'each' construct
	just to demonstrate that iterators can be easily chained
--]]
package.path = package.path..";../?.lua"
local EVContext = require("EVContext")
local utils = require("utils")
local fun = require("fun")()

each(utils.printDevice, EVContext:devices())


print("== DONE ==")

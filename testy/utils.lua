local function printDevice(dev)
	print("==== Device ====")
print(string.format("      ID: bus %#x vendor %#x product %#x",
        dev:busType(),
        dev:vendorId(),
        dev:productId()));
	print("    Node: ", dev.NodeName)
	print("    Name: ", dev:name())
	print("Physical: ", dev:physical())
	dev:printProperties();
	print("Like")
	print("  Flight Stick: ", dev:isLikeFlightStick());
	print("      Keyboard: ", dev:isLikeKeyboard());
	print("        Tablet: ", dev:isLikeTablet())
	print("         Mouse: ", dev:isLikeMouse())
end

local exports = {
	printDevice = printDevice;
}

return exports

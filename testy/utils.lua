local function printProperties(dev)
	print("Properties:");

	local function printProperty(prop)
		if not self:hasProperty(prop) then
			return;
		end

		print(string.format("  Property type %d (%s)", prop, input.getValueName(prop, input.Properties)));
	end

	for _, prop, nameValue in dev:properties() do
		print(string.format("  Property type %d (%s)", prop, nameValue));	
	end
end

local function printDevice(dev)
	print("==== Device ====")
print(string.format("      ID: bus %#x vendor %#x product %#x",
        dev:busType(),
        dev:vendorId(),
        dev:productId()));
	print("    Node: ", dev.NodeName)
	print("    Name: ", dev:name())
	print("Physical: ", dev:physical())
	printProperties(dev);
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

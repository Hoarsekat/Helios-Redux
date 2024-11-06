local roact = require("@packages/roact")
local button = require("@components/button")

return function(target)
	local btn = roact.mount(button, target)

	return function()
		roact.unmount(btn)
	end
end

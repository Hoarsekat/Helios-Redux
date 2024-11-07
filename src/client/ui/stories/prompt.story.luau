local roact = require("@packages/roact")
local prompt = require("@components/prompt")

return function(target)
	local prmpt = roact.mount(prompt, target)

	return function()
		roact.unmount(prmpt)
	end
end

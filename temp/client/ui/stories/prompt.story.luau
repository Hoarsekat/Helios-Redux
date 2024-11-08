local roact = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('roact'))
local prompt = require(script.Parent.Parent:WaitForChild('components'):WaitForChild('prompt'))

return function(target)
	local prmpt = roact.mount(prompt, target)

	return function()
		roact.unmount(prmpt)
	end
end

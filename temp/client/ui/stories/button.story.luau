local roact = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('roact'))
local button = require(script.Parent.Parent:WaitForChild('components'):WaitForChild('button'))

return function(target)
	local btn = roact.mount(button, target)

	return function()
		roact.unmount(btn)
	end
end

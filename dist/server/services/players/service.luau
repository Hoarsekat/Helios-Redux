local knit = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('knit'))

local service = knit.CreateService({
	Name = "PlayerService",
	Client = {},
})

return service

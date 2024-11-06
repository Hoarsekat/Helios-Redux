local knit = require("@packages/knit")

local service = knit.CreateService({
	Name = "PlayerService",
	Client = {},
})

return service

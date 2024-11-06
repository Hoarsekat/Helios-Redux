local classpp = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('classpp'))
local class = classpp.class

local player = class("Player")({
	constructor = function(self, name, character, humanoid)
		self.Name = name
		self.Character = character
		self.Humanoid = humanoid
	end,
	Public = {
		Name = "",
		Character = "",
		Humanoid = "",
		setupCharacter = function(self)
			local description = self.Humanoid:GetAppliedDescription()

			description.Head = 0
			description.LeftArm = 0
			description.RightArm = 0
			description.LeftLeg = 0
			description.RightLeg = 0
			description.Torso = 0

			self.Humanoid:ApplyDescription(description)
		end,
	},
})

return player

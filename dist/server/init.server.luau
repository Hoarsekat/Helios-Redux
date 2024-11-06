local knit = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('knit'))
local promise = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('promise'))

local runtime = os.clock()

for _, v in ipairs(script.services:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:find("service$") then
		require(v)
	end
end

promise
	.try(knit.Start)
	:andThen(function()
		print(string.format("[Server] Took %.4f seconds to initialize services.", os.clock() - runtime))
	end)
	:catch(warn)

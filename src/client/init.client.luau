local indium = require("@packages/indium")
local promise = require("@packages/promise")

local runtime = os.clock()

for _, v in ipairs(script.controllers:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:find("controller$") then
		require(v)
	end
end

promise
	.try(indium.Start)
	:andThen(function()
		print(string.format("[Client] Took %.4f seconds to initialize controllers.", os.clock() - runtime))
	end)
	:catch(warn)

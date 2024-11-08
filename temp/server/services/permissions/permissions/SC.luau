local securityClearances = {
	[0] = 4,
	[1] = 5,
	[2] = 6,
	[3] = 7,
	[4] = 8,
	[5] = 9, -- SC-5 is for Installation Director+
}

return function(player, permissionService, clearanceNumber)
	local clearance = tonumber(clearanceNumber)

	if clearance and securityClearances[clearance] then
		local check = { ("Group:SCPF:%d-255"):format(securityClearances[clearance]) }

		return permissionService:HasPermission(player, check)
	else
		return false
	end
end

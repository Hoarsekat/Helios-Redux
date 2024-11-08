local groups = {
	["Test"] = {
		"Group:SCPF:1-255",
	},
}

return function(player, permissionService, groupName)
	local group = groups[groupName]

	return permissionService:HasPermission(player, group)
end

local marketplaceService = game:GetService("MarketplaceService")

return function(player, _, gamepassId)
	return marketplaceService:UserOwnsGamePassAsync(
		typeof(player) == "number" and player or player.UserId,
		tonumber(gamepassId)
	)
end

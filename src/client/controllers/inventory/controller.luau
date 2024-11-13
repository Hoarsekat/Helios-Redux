local players = game:GetService("Players")
local starterGui = game:GetService("StarterGui")
local contextActionService = game:GetService("ContextActionService")

local indium = require("@packages/indium")
local janitor = require("@packages/janitor")

local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backpack = player.Backpack

local playerGui = player:WaitForChild("PlayerGui")
local inventoryUi = playerGui:WaitForChild("Inventory")
local inventoryFrame = inventoryUi:WaitForChild("Frame")

local uiSlot = script.Parent:WaitForChild("Slot")

local lastSend = tick()
local changedPreferences = false

local keycodes = {
	[Enum.KeyCode.Zero] = 10,
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
}

local inventoryService

local controller = indium.CreateController({
	Name = "InventoryController",
})

function controller:getInventoryItemsSorted()
	local slots = {}

	for _, item in ipairs(character:GetChildren()) do
		if item:IsA("Tool") then
			table.insert(slots, item)
		end
	end

	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") then
			table.insert(slots, item)
		end
	end

	table.sort(slots, function(a, b)
		return a.Name:lower() < b.Name:lower()
	end)

	return slots
end

function controller:getInventorySlotPreferences()
	if not self._preferences then
		local serverPreferences = inventoryService:GetLoadout(player)
		if serverPreferences then
			self._preferences = serverPreferences
		else
			self._preferences = {}
		end
	end

	return self._preferences
end

function controller:getInventoryItemsSlotted()
	local sortedItems = self:getInventoryItemsSorted()
	local preferences = self:getInventorySlotPreferences()

	local slots = {}
	slots[10] = true

	local itemCount = #sortedItems

	for i, item in ipairs(sortedItems) do
		if preferences[item.Name] and not slots[preferences[item.Name]] and preferences[item.Name] <= itemCount then
			slots[preferences[item.Name]] = item
			sortedItems[i] = nil
		end
	end

	local counter = 0

	for _, item in ipairs(sortedItems) do
		counter += 1
		if slots[counter] then
			repeat
				counter += 1
			until not slots[counter]
			slots[counter] = item
		end
	end

	self.state.currentSlots = slots
	return slots
end

function controller:getHotbarItems()
	local totalSlots = self:getInventoryItemsSlotted()
	local slots = {}

	for i = 1, 9 do
		table.insert(slots, i, totalSlots[i])
	end

	return slots
end

function controller:getBackpackItems()
	local totalSlots = self:getInventoryItemsSlotted()
	local slots = {}

	for i, item in ipairs(totalSlots) do
		if i > 10 then
			table.insert(slots, i, item)
		end
	end

	return slots
end

function controller:renderItem(slot, item, i)
	slot.Num.Text = (i < 10 and tostring(i) or i == 10 and "0" or "")
	slot.LayoutOrder = i
	slot.Label.Text = item.Name
	slot.Parent = inventoryFrame
	slot.Visible = true
end

function controller:renderHotbar()
	local slots = self:getHotbarItems()
	local _backpack = self:getBackpackItems()

	if tick() - lastSend >= 15 and changedPreferences then
		changedPreferences, lastSend = false, tick()
		task.spawn(function()
			inventoryService:UpdateLoadout(player, self._preferences)
		end)
	end

	for _, item in pairs(inventoryFrame:GetChildren()) do
		if not item:IsA("UIGridLayout") then
			item:Destroy()
		end
	end

	for i, item in ipairs(slots) do
		local _slot = uiSlot:Clone()
		self:renderItem(_slot, item, i)
	end

	local backpackUsed = false

	for i, item in pairs(_backpack) do
		backpackUsed = true
		local _slot = uiSlot:Clone()
		self:renderItem(_slot, item, i)
	end

	inventoryFrame.UIGridLayout.HorizontalAlignment = backpackUsed and Enum.HorizontalAlignment.Left
		or Enum.HorizontalAlignment.Center
end

function controller.registerKey(_, inputState, inputObject)
	local key = keycodes[inputObject.KeyCode]

	if controller.state.editMode then
		return
	end

	if not inventoryUi.Enabled then
		return
	end

	if key and inputState == Enum.UserInputState.Begin then
		if controller.state.currentSlots[key] then
			if controller.state.equipped then
				character.Humanoid:UnequipTools()

				if controller.state.equippedSlot == key then
					controller.state.equipped = false
					controller.state.equippedSlot = false

					controller:renderHotbar()

					return
				end
			end

			character.Humanoid:EquipTool(controller.state.currentSlots[key])
			controller.state.equipped = true
			controller.state.equippedSlot = key
			controller:renderHotbar()
		end
	end
end

function controller:IndiumInit()
	inventoryService = indium.GetService("InventoryService")

	self.state = {
		editMode = false,
		equippedSlot = false,
		equipped = false,
		backpack = false,
		editItem = nil,
		currentSlots = {},
	}

	local backpackChildAdded = backpack.ChildAdded:Connect(function()
		self:renderHotbar()
	end)

	local backpackChildRemoved = backpack.ChildRemoved:Connect(function()
		self:renderHotbar()
	end)

	self._janitor = janitor.new()
	self._janitor:Add(backpackChildAdded)
	self._janitor:Add(backpackChildRemoved)

	task.spawn(function()
		task.wait(0.25)

		pcall(function()
			starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		end)

		contextActionService:BindAction(
			"InventoryKey",
			controller.registerKey,
			false,
			Enum.KeyCode.Zero,
			Enum.KeyCode.One,
			Enum.KeyCode.Two,
			Enum.KeyCode.Three,
			Enum.KeyCode.Four,
			Enum.KeyCode.Five,
			Enum.KeyCode.Six,
			Enum.KeyCode.Seven,
			Enum.KeyCode.Eight,
			Enum.KeyCode.Nine
		)

		self:renderHotbar()
	end)
end

return controller

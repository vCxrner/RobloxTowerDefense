-- Louis stinkt

local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

local partySystemFolder = localPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("PartySystem")
local partySidebarCanvas = partySystemFolder:WaitForChild("partySidebar")
local playerHolder = partySidebarCanvas:WaitForChild("playerHolder")
local playerTemplate = playerHolder:WaitForChild("playerTemplate")
local partyButton = partySystemFolder.Parent:WaitForChild("menuButtonsHolder"):WaitForChild("partyButton")
local partyTable = {}
local localPlayerGui = playerHolder:WaitForChild("localPlayer")
local addNewPlayerButton = partySidebarCanvas:WaitForChild("playerHolder"):WaitForChild("addMorePlayersButton")
local partyList = playerHolder:WaitForChild("partyList")

local playerListModal = partySystemFolder.Parent:WaitForChild("ModalHolder"):WaitForChild("partyAddPlayersModal")
local playerListHolder = playerListModal:WaitForChild("playerHolderBackground"):WaitForChild("playerHolder")
local playerListTemplate = playerListModal:WaitForChild("playerHolderBackground"):WaitForChild("playerHolder"):WaitForChild("playerTemplate")
local playerListCloseButton = playerListModal:WaitForChild("closeButton")
local currentPlayers = {}

local debounce = false
local debounce_timer = 0.1

local function playerTableContains(userID:string)
	for _, player in currentPlayers do
		if not player:IsA("Player") then continue end
		if player.UserId == userID then
			return true
		end
	end
	return false
end

local function getNewPlayerFrame(playerForNewFrame:Player)
	local newFrame = playerListTemplate:Clone()
	newFrame.Name = playerForNewFrame.Name .. '_' .. tostring(playerForNewFrame.UserId)
	newFrame:WaitForChild("displayName").Text = playerForNewFrame.DisplayName
	newFrame:WaitForChild("name").Text = '@' .. playerForNewFrame.Name
	newFrame:WaitForChild("playerIcon").Image = players:GetUserThumbnailAsync(playerForNewFrame.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size352x352)
	return newFrame
end

local function addNewPlayerToList(playerToAdd:Player)
	if not playerTableContains(tostring(playerToAdd.UserId)) then
		table.insert(currentPlayers, playerToAdd)
		local newPlayerFrame = getNewPlayerFrame(playerToAdd)
		newPlayerFrame.Parent = playerListHolder
		newPlayerFrame.Visible = true
	end
end

local function refreshPlayerList()
	for _, v in pairs(playerListHolder:GetChildren()) do
		if v:IsA("Frame") and v.Name ~= "playerTemplate" then
			v:Destroy()
		end
	end
	for _, player in pairs(players:GetPlayers()) do
		addNewPlayerToList(player)
	end
end

local function removePlayerFromList(playerToRemove:Player)
	if playerTableContains(playerToRemove.UserId) then
		table.remove(currentPlayers, table.find(currentPlayers, playerToRemove))
		local playerFrame = playerListHolder:WaitForChild(playerToRemove.Name .. '_' .. tostring(playerToRemove.UserId))
		playerFrame:WaitForChild("invite").Activated:Disconnect()
		playerFrame:Destroy()
	end
end

local function loadLocalPlayer()
	localPlayerGui:WaitForChild("playerIcon").Image = players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	localPlayerGui:WaitForChild("displayName").Text = localPlayer.DisplayName
	localPlayerGui:WaitForChild("name").Text = '@' .. localPlayer.Name
end

---------------------------------------------
-- 	P A R T Y - I N V I T E - S Y S T E M
---------------------------------------------
local RemoteHandler = require(game:GetService("ReplicatedStorage"):WaitForChild("RemoteHandler"))
local InviteEvent: RemoteEvent = RemoteHandler.getEvent("InviteEvent")

local function handleInvite(targetPlayername:string)
	print(localPlayer.Name .. " invited " .. targetPlayername:split("_")[1])
	InviteEvent:FireServer(targetPlayername:split("_")[2])
end


--[[
	connect the inviteButton to the corrosponding event
]]
local function linkInviteButton(Button:TextButton)
	 if Button:IsA("TextButton") then
		Button.Activated:Connect(handleInvite(Button.Parent.Name))
	end
end

---------------------------------------------
-- 	C O N N E C T S
---------------------------------------------

players.PlayerAdded:Connect(function(player:Player)
	print(player.DisplayName .. " joined the game.")
	addNewPlayerToList(player)
end)

players.PlayerRemoving:Connect(function(player:Player)
	print(player.DisplayName .. " is leaving the game.")
	removePlayerFromList(player)
end)

partyButton.Activated:Connect(function()
	if debounce then return end
	debounce = true
	partySidebarCanvas.Visible = not partySidebarCanvas.Visible
	if not partySidebarCanvas.Visible then
		playerListModal.Visible = false
	else
		loadLocalPlayer()
	end
	task.wait(debounce_timer)
	debounce = false
end)

playerListCloseButton.Activated:Connect(function()
	playerListModal.Visible = false
end)

local addPlayerButtonDebounce = false

addNewPlayerButton.Activated:Connect(function()
	if addPlayerButtonDebounce then return end
	addPlayerButtonDebounce = true
	playerListModal.Visible = true
	task.wait(debounce_timer)
	addPlayerButtonDebounce = false
end)

print("--- start refresh ---")
refreshPlayerList()
loadLocalPlayer()
print("--- end refresh ---")
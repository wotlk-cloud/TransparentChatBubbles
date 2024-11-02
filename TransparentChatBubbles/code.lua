local thisAddon = ...
local select = select
local pairs = pairs
local GetCVarBool = GetCVarBool

local isBubble = function(frame)
	if frame:GetName() then return end
	if not frame:GetRegions() then return end
	local region = frame:GetRegions()
	return region:GetTexture() == [[Interface\Tooltips\ChatBubble-Background]]
end

local skinBubbles
skinBubbles = function(frame, ...)
	if not frame.isTransparentBubble and isBubble(frame) then 
		for i=1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region:GetObjectType() == "Texture" then
				region:SetTexture(nil)
			elseif region:GetObjectType() == "FontString" then
				local f, s = region:GetFont()
				region:SetFont(f, s, 'OUTLINE')
			end
		end
		frame.isTransparentBubble =true
	end
	if (...) then 
		skinBubbles(...)
	end
end

local f = CreateFrame'Frame'
local numChildren = -1
local WorldFrame = WorldFrame
local events = {
	CHAT_MSG_SAY = "chatBubbles", CHAT_MSG_YELL = "chatBubbles",
	CHAT_MSG_PARTY = "chatBubblesParty", CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
	CHAT_MSG_MONSTER_SAY = "chatBubbles", CHAT_MSG_MONSTER_YELL = "chatBubbles", CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
}

f:SetScript('OnEvent', function(self, event, addon)
	if addon ~= thisAddon then return end
	self:UnregisterEvent'ADDON_LOADED'
	self:Show()
	self:SetScript('OnEvent', function(self, event)
		if GetCVarBool(events[event]) then
			local count = WorldFrame:GetNumChildren()
			if(count ~= numChildren) then
				numChildren = count
				self.elapsed = 0
				if not self:IsShown() then
					self:Show()
				end
			end
		end
	end)
	for k, v in pairs(events) do
		self:RegisterEvent(k)
	end
end)
f:RegisterEvent'ADDON_LOADED'

f:Hide()
f.elapsed = 0
f:SetScript('OnUpdate', function(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed > 0.1 then
		self:Hide()
		skinBubbles(WorldFrame:GetChildren())
	end
end)
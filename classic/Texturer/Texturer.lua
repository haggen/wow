-- Texturer
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

local function AllowMoveAndResize(frame)
    frame:SetMovable(true);
    frame:EnableMouse(true);
	frame:RegisterForDrag("LeftButton");
	frame:HookScript("OnDragStart", function()
		if (not frame.isLocked) then
			frame:StartMoving();
		end
	end);
	frame:HookScript("OnDragStop", function()
		frame:StopMovingOrSizing();
	end);
end

--
--
--

TexturerButtonMixin = {};

function TexturerButtonMixin:GetTopLevelFrame()
	return self:GetParent():GetParent():GetParent();
end

function TexturerButtonMixin:SetData(data)
	self.data = data;
end

function TexturerButtonMixin:ClearData()
	self.data = nil;
end

function TexturerButtonMixin:SetSelected()
	self.isSelected = true;
end

function TexturerButtonMixin:ClearSelected()
	self.isSelected = nil;
end

function TexturerButtonMixin:Update()
	if (self.data) then
		self:Show();
		if (self.isSelected) then
			self:LockHighlight();
		else
			self:UnlockHighlight();
		end
		self.Path:SetText(self.data);
	else
		self:Hide();
		self.Path:SetText("");
	end
end

function TexturerButtonMixin:OnEnter()
end

function TexturerButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:GetTopLevelFrame():SelectTexture(self.index);
	self:GetTopLevelFrame():Update();
end

function TexturerButtonMixin:OnLeave()
end

--
--
--

TexturerPreviewMixin = {};

function TexturerPreviewMixin:ResetTexture(path)
	self.Texture:SetWidth(0);
	self.Texture:SetHeight(0);
	self.Texture:SetTexture(path);
	self.pendingConstraint = true;
end

function TexturerPreviewMixin:ClearTexture()
	self.Texture:SetWidth(0);
	self.Texture:SetHeight(0);
	self.Texture:SetTexture(nil);
end

local function ApplyDimensionConstraint(value, maxValue)
	if (value > 0 and value > maxValue) then
		return maxValue, (maxValue / value);
	end
	return value, 1;
end

function TexturerPreviewMixin:ApplyTextureConstraints()
	if (not self.pendingConstraint) then
		return;
	end
	if (not self.Texture:IsObjectLoaded()) then
		return;
	end

	local width, height = self.Texture:GetSize();

	if (width > height) then
		local maxWidth = self:GetWidth();
		local newWidth, ratio = ApplyDimensionConstraint(width, maxWidth);
		self.Texture:SetSize(newWidth, height * ratio);
	else
		local maxHeight = self:GetHeight();
		local newHeight, ratio = ApplyDimensionConstraint(height, maxHeight);
		self.Texture:SetSize(width * ratio, newHeight);
	end

	self.pendingConstraint = false;
end

function TexturerPreviewMixin:OnLoad()
	AllowMoveAndResize(self);
end

function TexturerPreviewMixin:OnUpdate()
	self:ApplyTextureConstraints();
end

--
--
--

TexturerMixin = {};

function TexturerMixin:SelectFirstTexture()
	self:SelectTexture(1);
end

function TexturerMixin:SelectLastTexture()
	self:SelectTexture(#self.ScrollFrame.textureData);
end

function TexturerMixin:SelectPreviousTexture()
	self:SelectTexture(self.ScrollFrame.selectedTexture - 1);
end

function TexturerMixin:SelectNextTexture()
	self:SelectTexture(self.ScrollFrame.selectedTexture + 1);
end

function TexturerMixin:SelectTexture(index)
	local total = #self.ScrollFrame.textureData;
	if (index < 1) then
		index = total;
	elseif (index > total) then
		index = 1;
	end
	self.ScrollFrame.selectedTexture = index;

	self:ScrollToTexture(index);
end

function TexturerMixin:SetTextureData(data, query)
	if (query == nil or query == "") then
		self.ScrollFrame.textureData = data;
	else
		self.ScrollFrame.textureData = {};

		for _, entry in ipairs(data) do
			if string.find(string.lower(entry), string.lower(query), 1, false) then
				table.insert(self.ScrollFrame.textureData, entry);
			end
		end
	end
	self.ScrollFrame.selectedTexture = 0;
end

function TexturerMixin:FilterTextureData(query)
	self:SetTextureData(TEXTURE_DATA, query);
end

function TexturerMixin:ScrollToTexture(index)
	local buttons = self.ScrollFrame.buttons;
	local buttonHeight = buttons[1]:GetHeight();

	local currentValue = self.ScrollFrame.scrollBar:GetValue();

	local range = {
		buttonHeight * (index - #buttons + 2),
		buttonHeight * (index - 1),
	};

	if (currentValue < range[1]) then
		self.ScrollFrame.scrollBar:SetValue(range[1]);
	elseif (currentValue > range[2]) then
		self.ScrollFrame.scrollBar:SetValue(range[2]);
	end
end

function TexturerMixin:UpdateScrollFrame()
	local offset = HybridScrollFrame_GetOffset(self.ScrollFrame);
	local selectedTexture = self.ScrollFrame.selectedTexture;
	local buttons = self.ScrollFrame.buttons;
	local data = self.ScrollFrame.textureData;
	local buttonHeight = buttons[1]:GetHeight();
	local displayedHeight = 0;
	local totalHeight = buttonHeight * #data;

	for index, button in ipairs(buttons) do
		local displayIndex = index + offset;
		button.index = displayIndex;
		displayedHeight = displayedHeight + buttonHeight;

		if (displayIndex <= #data) then
			button:SetData(data[displayIndex]);
		else
			button:ClearData();
		end

		if (displayIndex == selectedTexture) then
			button:SetSelected();
		else
			button:ClearSelected();
		end

		button:Update();
	end

	HybridScrollFrame_Update(self.ScrollFrame, totalHeight, displayedHeight);
end

function TexturerMixin:UpdatePreview()
	local textureData = self.ScrollFrame.textureData;
	local texture = textureData[self.ScrollFrame.selectedTexture];
	self.Preview:ResetTexture(texture);
end

function TexturerMixin:Update()
	self:UpdateScrollFrame();
	self:UpdatePreview();
end

function TexturerMixin:OnLoad()
	AllowMoveAndResize(self);

	self:SetTextureData(TEXTURE_DATA);
	self.ScrollFrame.update = function()
		self:Update();
	end;
	-- self.ScrollFrame.scrollBar.doNotHide = true;
	-- self.ScrollFrame.scrollBar:SetValue(0);

	HybridScrollFrame_CreateButtons(self.ScrollFrame, "TexturerButtonTemplate", 0, 0);
end

function TexturerMixin:OnShow()
	self:Update();
end

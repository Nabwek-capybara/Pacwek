PacwekUI = {}

local frame = CreateFrame("Frame", "PacwekMainFrame", UIParent)
frame:SetWidth(400)
frame:SetHeight(300)
frame:SetPoint("CENTER")
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function()
	frame:StartMoving()
end)

frame:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
end)
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4
    }

})

frame:Hide()

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("Pacwek 335a")

local scroll = CreateFrame("ScrollFrame", "PacwekScrollFrame", frame)
scroll:SetPoint("TOPLEFT", 16, -40)
scroll:SetPoint("BOTTOMRIGHT", -32, 40)

local scrollbar = CreateFrame("Slider", "PacwekScrollBar", scroll, "UIPanelScrollBarTemplate")
scrollbar:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 4, -16)
scrollbar:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 4, 16)

local editBox = CreateFrame("EditBox", "PacwekEditBox", scroll)

editBox:SetMultiLine(true)
editBox:SetFontObject(ChatFontNormal)

editBox:SetWidth(320)
editBox:SetHeight(400)

editBox:SetAutoFocus(false)

editBox:EnableMouse(true)
editBox:SetMovable(false)

editBox:SetTextInsets(8, 8, 8, 8)

editBox:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4
    }
})

editBox:SetBackdropColor(0, 0, 0, 0.8)

editBox:SetScript("OnEscapePressed", function()
    editBox:ClearFocus()
end)

editBox:SetScript("OnMouseDown", function()
    editBox:SetFocus()
end)

scroll:SetScrollChild(editBox)

editBox:Show()

local importButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
importButton:SetWidth(100)
importButton:SetHeight(22)
importButton:SetPoint("BOTTOM", 0, 10)
importButton:SetText("Import SR")

importButton:SetScript("OnClick", function()
    local text = editBox:GetText()
    PacwekSoftRes:Import(text)
	editBox:SetText("")
    frame:Hide()
end)

function PacwekUI:Toggle()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end


table.insert(UISpecialFrames, "PacwekMainFrame")

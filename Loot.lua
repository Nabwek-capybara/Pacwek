PacwekLoot = CreateFrame("Frame")

PacwekLoot:RegisterEvent("CHAT_MSG_LOOT")

PacwekLoot:SetScript("OnEvent", function(self, event, message)
    local itemLink = string.match(message, "|Hitem:.-|h%[(.-)%]|h")

    if itemLink then
        PacwekLoot:HandleLoot(itemLink)
    end
end)

function PacwekLoot:HandleLoot(itemName)
    PacwekCompat:Print("Loot detected: " .. itemName)

    local reservers = PacwekSoftRes:GetItemReservers(itemName)

    if #reservers > 0 then
        SendChatMessage(
            "SoftRes priority for: " .. table.concat(reservers, ", "),
            "RAID"
        )
    end

    PacwekRolls:Start(itemName)
end
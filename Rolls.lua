PacwekRolls = {}

PacwekRolls.active = false

PacwekRolls.current = {
    item = nil,
    reservers = {},
    rolls = {},
    reroll = false,
    rerollPlayers = {},
}

local frame = CreateFrame("Frame")

frame:RegisterEvent("CHAT_MSG_SYSTEM")

frame:SetScript("OnEvent", function(self, event, message)

    if not PacwekRolls.active then
        return
    end

    local player, roll, low, high = string.match(
        message,
        "(.+) rolls (%d+) %((%d+)%-(%d+)%)"
    )

    if not player then
        return
    end

    roll = tonumber(roll)
    low = tonumber(low)
    high = tonumber(high)

    if low ~= 1 then
        return
    end

    local rollType = nil
	
	local hasSR =
		PacwekRolls:HasSR()

    if high == 100 then
	
		if hasSR then
			rollType = "SR"
		else
			rollType = "MS"
		end
    elseif high == 99 then
        rollType = "OS"
    elseif high == 98 then
        rollType = "TMOG"
    else
        return
    end

    local current = PacwekRolls.current

    -- reroll mode
    if current.reroll then

        local allowed = false

        for _, name in ipairs(current.rerollPlayers) do
            if name == player then
                allowed = true
                break
            end
        end

        if not allowed then
            return
        end
    end

    local reserveCount =
        current.reservers[player] or 0

    local hasSR =
        PacwekRolls:HasSR()

    -- item has SR -> only reservers may MS roll
    if hasSR then

    if rollType ~= "SR" then

        PacwekCompat:Print(
            "Ignored non-SR roll from " ..
            player
        )

        return
    end

    if reserveCount <= 0 then

        PacwekCompat:Print(
            "Ignored non-reserver " ..
            player
        )

        return
    end
end

    current.rolls[player] =
        current.rolls[player] or {}

)


    local existing =
        current.rolls[player][rollType]

    local maxAllowed = 1

    if rollType == "SR" and reserveCount > 1 then
        maxAllowed = reserveCount
    end

    local totalRolls = 0

    if existing then
        totalRolls = #existing
    end

    if totalRolls >= maxAllowed then

        PacwekCompat:Print(
            player ..
            " exceeded allowed rolls"
        )

        return
    end

    current.rolls[player][rollType] =
        current.rolls[player][rollType] or {}

    table.insert(
        current.rolls[player][rollType],
        roll
    )

    PacwekCompat:Print(
        player ..
        " rolled " ..
        roll ..
        " (" ..
        rollType ..
        ")"
    )
	
	PacwekRolls:CheckAutoFinish()
	
end)

function PacwekRolls:Start(item)

	local itemLink = item
	
	local itemName =
    GetItemInfo(item)
	
	if itemName then
		item = itemName
	end

    self.active = true

    self.current = {
        item = item,
		itemLink = itemLink,
        reservers = {},
        rolls = {},
        reroll = false,
        rerollPlayers = {},
    }

    local reservers =
        PacwekSoftRes:GetItemReservers(item)

    for _, player in ipairs(reservers) do

        self.current.reservers[player] =
            (self.current.reservers[player] or 0) + 1
    end

    SendChatMessage(
        "Rolling for " .. (itemLink or item),
        "RAID"
    )

    if #reservers > 0 then

        SendChatMessage(
            "Reserved by: " ..
            table.concat(reservers, ", "),
            "RAID"
        )
    end

    SendChatMessage(
        "MS/SR: /roll - OS: /roll 99 - TMOG: /roll 98",
        "RAID"
    )
	
	C_Timer.After(10, function()

    if PacwekRolls.active then

        SendChatMessage(
            "Rolling ends in 5 seconds",
            "RAID"
        )
    end
end)

C_Timer.After(12, function()

    if PacwekRolls.active then

        SendChatMessage(
            "3...",
            "RAID"
        )
    end
end)

C_Timer.After(13, function()

    if PacwekRolls.active then

        SendChatMessage(
            "2...",
            "RAID"
        )
    end
end)

C_Timer.After(14, function()

    if PacwekRolls.active then

        SendChatMessage(
            "1...",
            "RAID"
        )
    end
end)

    C_Timer.After(15, function()
        PacwekRolls:Finish()
    end)
end

function PacwekRolls:HasSR()

    for _, count in pairs(self.current.reservers) do
        if count > 0 then
            return true
        end
    end

    return false
end

function PacwekRolls:GetHighestRoll(tier)

    local highest = 0
    local winners = {}

    for player, data in pairs(self.current.rolls) do

        if data[tier] then

            for _, roll in ipairs(data[tier]) do

                if roll > highest then

                    highest = roll
                    winners = { player }

                elseif roll == highest then

                    table.insert(
                        winners,
                        player
                    )
                end
            end
        end
    end

    return highest, winners
end

function PacwekRolls:Finish()

	if not self.active then
        return
    end

	local hasSR = self:HasSR()
	local priority
	
		if hasSR then

        priority = {
            "SR",
        }

    else

        priority = {
            "MS",
            "OS",
            "TMOG",
        }
    end
    for _, tier in ipairs(priority) do

         local highest, winners =
            self:GetHighestRoll(tier)

        if highest > 0 then

            if #winners > 1 then

                self.current.reroll = true
                self.current.rerollPlayers = winners
                self.current.rolls = {}

                SendChatMessage(
                    "Tie detected between: " ..
                    table.concat(winners, ", "),
                    "RAID"
                )

                SendChatMessage(
                    "Reroll now using appropriate roll",
                    "RAID"
                )

                C_Timer.After(15, function()
                    PacwekRolls:Finish()
                end)

                return
            end

            local winner = winners[1]

            SendChatMessage(
                winner ..
                " wins " ..
                (self.current.itemLink or self.current.item) ..
                " with " ..
                highest ..
                " (" ..
                tier ..
                ")",
                "RAID"
            )

            self.active = false

            return
        end
    end

    SendChatMessage(
        "No valid rolls for " ..
        self.current.item,
        "RAID"
    )

	self.active = false
end

function PacwekRolls:CheckAutoFinish()

    if not self:HasSR() then
        return
    end

    for player, count in pairs(
        self.current.reservers
    ) do
		
        local data =
            self.current.rolls[player]

        local rolls = 0

        if data and data["SR"] then
            rolls = #data["SR"]
        end

        if rolls < count then
            return
        end
    end

    SendChatMessage(
        "All SR rolls received",
        "RAID"
    )

    self:Finish()
end
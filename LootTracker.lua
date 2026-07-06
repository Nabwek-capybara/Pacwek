PacwekLoot = {}

--debug
PacwekLootFrame =
    CreateFrame("Frame")


PacwekLootFrame:SetScript(
    "OnEvent",
    function()

        PacwekCompat:Print(
            "FRAME LOOT_OPENED"
        )

    end
)

PacwekLootFrame:RegisterEvent(
    "LOOT_OPENED"
)
PacwekLootFrame:RegisterEvent(
    "LOOT_SLOT_CLEARED"
)
PacwekLootFrame:RegisterEvent(
    "LOOT_CLOSED"
)
PacwekLootFrame:SetScript(
    "OnEvent",
    function(_, event)

        PacwekCompat:Print(
            event
        )

    end
)

--debug

-- ====================================
-- Inicjalizacja Loot Trackera
-- ====================================

function PacwekLoot:Initialize()
	-- nic
end

-- ====================================
-- Loot został otwarty
-- ====================================


function PacwekLoot:LOOT_OPENED()
--debug
PacwekCompat:Print("1")
--debug
    if not PacwekCompat:IsActiveMasterLooter() then
	
	--debug
	     PacwekCompat:Print("2")
	--debug
		
		return
    end
	--debug
	  PacwekCompat:Print("3")
	--debug

    local lootItems = {}

    local numItems =
        GetNumLootItems()
	--test
	PacwekCompat:Print(
        "Items=" ..
        tostring(numItems)
    )
	--test

    for slot = 1, numItems do
		--test
	    PacwekCompat:Print(
        "Slot=" ..
        tostring(slot)
    )
	--test

        local itemLink =
            GetLootSlotLink(slot)
			
			--test
			    PacwekCompat:Print(
        "Link=" ..
        tostring(itemLink)
    )
	--test

        if itemLink then

            local itemName =
                GetItemInfo(itemLink)
			
            if itemName then

                lootItems[itemName] =
                    lootItems[itemName] or {
                        link = itemLink,
                        count = 0,
                    }

                lootItems[itemName].count =
                    lootItems[itemName].count + 1
            end
        end
    end

    PacwekLoot.items =
        lootItems

	--test
	PacwekCompat:Print(
    "Calling announce"
)
--test

    PacwekLoot:AnnounceLoot()
end



-- ====================================
-- Wyświetla wykryty loot
-- ====================================

function PacwekLoot:AnnounceLoot()

    if not self.items then
        return
    end

    SendChatMessage(
        "Loot detected:",
        "RAID"
    )

    for _, data in pairs(
        self.items
    ) do

        local text =
            data.link

        if data.count > 1 then

            text =
                text ..
                " x" ..
                data.count
        end

        SendChatMessage(
            text,
            "RAID"
        )
    end
end
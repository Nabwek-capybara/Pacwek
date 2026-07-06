PacwekCompat = {}

if not C_Timer then
    C_Timer = {}

    function C_Timer.After(seconds, func)
        local frame = CreateFrame("Frame")
        local elapsed = 0

        frame:SetScript("OnUpdate", function(self, e)
            elapsed = elapsed + e

            if elapsed >= seconds then
                func()

                self:SetScript("OnUpdate", nil)
                frame = nil
            end
        end)
    end
end


-- =============================
-- Debug function do stosowania w addonie
-- =============================

PacwekDebug = false



function PacwekCompat:Debug(msg)

    if not PacwekDebug then
        return
    end

    self:Print(msg)
end

-- ===============================
-- Funkcja do wysyłania wiadomości na czacie
-- ===============================

function PacwekCompat:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff00ff00[Pacwek]|r " .. tostring(msg)
    )
end


-- ====================================
-- Czy aktualny gracz jest ML
-- w raidzie z Epic threshold
-- ====================================

function PacwekCompat:IsActiveMasterLooter()

    if GetNumRaidMembers() == 0 then
        return false
    end

    local method,
          masterLooter,
          threshold =
            GetLootMethod()

    if method ~= "master" then
        return false
    end

    --if threshold ~= 4 then
		--return false
   --end

    local mlName =
        GetRaidRosterInfo(
            masterLooter
        )

    if mlName ~= UnitName("player") then
        return false
    end

    return true
end
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

function PacwekCompat:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff00ff00[Pacwek]|r " .. tostring(msg)
    )
end
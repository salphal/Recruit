-- HanHua_History.lua - 历史记录管理
-- 依赖: HH (Util), HHdb, HH.FrameHistory, HH.FrameEdit, HH.editPrefix/Middle/Suffix
local AddonName, ADDONSELF = ...

function HH.UpdateHistoryList()
    HH.historyButtons = HH.historyButtons or {}
    for i, bt in ipairs(HH.historyButtons) do
        bt:Hide()
    end
    wipe(HH.historyButtons)

    for i = 1, #HHdb.history do
        local bt = CreateFrame("Button", nil, HH.FrameHistory)
        bt:SetSize(30, 15)
        if i == 1 then
            bt:SetPoint("BOTTOMRIGHT", HH.FrameEdit, "TOPLEFT", -2, 2)
        else
            bt:SetPoint("BOTTOMRIGHT", HH.historyButtons[i - 1], "TOPRIGHT", 0, 2)
        end
        bt:SetNormalFontObject(HH.FontGreen1)
        bt:SetDisabledFontObject(HH.FontDisabled)
        bt:SetHighlightFontObject(HH.FontHilight)
        bt:RegisterForClicks("AnyUp")
        bt:SetText("使用")
        tinsert(HH.historyButtons, bt)
        bt:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                local entry = HHdb.history[i]
                if entry then
                    if type(entry) == "table" then
                        HH.editGtuan:SetText(entry.g or "")
                        HH.editPrefix:SetText(entry.p or "")
                        HH.editTuanbu:SetText(entry.t or "")
                        HH.editMiddle:SetText(entry.m or "")
                        HH.editSuffix:SetText(entry.s or "")
                    elseif entry ~= "" then
                        HH.editGtuan:SetText("")
                        HH.editPrefix:SetText("")
                        HH.editTuanbu:SetText("")
                        HH.editMiddle:SetText(entry)
                        HH.editSuffix:SetText("")
                    end
                end
            elseif button == "RightButton" then
                tremove(HHdb.history, i)
                HH.UpdateHistoryList()
            end
            PlaySound(HH.sound1)
        end)

        local text = bt:CreateFontString()
        text:SetPoint("LEFT", bt, "RIGHT", 3, 0)
        text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        local entry = HHdb.history[i]
        local displayText = type(entry) == "table"
            and (entry.g or "") .. (entry.p or "") .. (entry.t or "") .. (entry.m or "") .. (entry.s or "")
            or entry or ""
        text:SetText(displayText)
    end
end

-- Recruit_Channels.lua - 频道管理
-- 依赖: HH (Util), HHdb, HH.Frame2, HH.button.send
local AddonName, ADDONSELF = ...

function HH.GetChannels()
    HH.channels = {}
    for _, v in pairs(HHdb.channels) do
        if v.yell then
            v.join = true
        else
            v.join = nil
        end
    end
    local channels = { GetChannelList() }
    for i = 1, #channels, 3 do
        if channels[i + 1] ~= "MeetingHorn" and channels[i + 1] ~= "BiaoGeYY" then
            local a = {
                channelID = channels[i],
                name = channels[i + 1],
                disabled = channels[i + 2],
            }
            tinsert(HH.channels, a)
            for name in pairs(HHdb.channels) do
                if name == a.name then
                    HHdb.channels[name] = { channelID = a.channelID, join = true }
                end
            end
        end
    end
end

function HH.UpdateChannel()
    HH.button.channel = HH.button.channel or {}
    HH.GetChannels()

    for _, bt in ipairs(HH.button.channel) do
        bt:Hide()
    end
    wipe(HH.button.channel)
    local right

    local function CreateButton(v)
        local bt = CreateFrame("CheckButton", nil, HH.Frame2, "ChatConfigCheckButtonTemplate")
        bt:SetSize(25, 25)
        bt:SetPoint("LEFT", right or HH.button.send, right and "RIGHT" or "BOTTOMLEFT", right and 10 or 3, right and 0 or -18)
        bt.Text:SetPoint("LEFT", bt, "RIGHT", -2, 0)
        bt.Text:SetText(v.channelID)
        bt:SetHitRectInsets(0, -10, 0, 0)
        bt.channelData = v
        tinsert(HH.button.channel, bt)
        right = bt

        if v.disabled then
            bt.Text:SetTextColor(0.5, 0.5, 0.5)
        end
        for name in pairs(HHdb.channels) do
            if name == v.name then
                bt:SetChecked(true)
                break
            end
        end

        bt:SetScript("OnClick", function(self)
            local name = v.name
            if self:GetChecked() then
                HHdb.channels[name] = { channelID = v.channelID, join = true, yell = v.yell }
            else
                HHdb.channels[name] = nil
            end
            PlaySound(HH.sound1)
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            if v.disabled then
                GameTooltip:AddLine(v.name, .5, .5, .5, true)
            else
                GameTooltip:AddLine(v.name, 1, 1, 1, true)
            end
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)
    end

    -- All 全选按钮
    do
        local bt = CreateFrame("CheckButton", nil, HH.Frame2, "ChatConfigCheckButtonTemplate")
        bt:SetSize(25, 25)
        bt:SetPoint("LEFT", right or HH.button.send, right and "RIGHT" or "BOTTOMLEFT", right and 10 or 3, right and 0 or -18)
        bt.Text:SetPoint("LEFT", bt, "RIGHT", -2, 0)
        bt.Text:SetText("A")
        bt.Text:SetTextColor(1, 0.82, 0)
        bt:SetHitRectInsets(0, -10, 0, 0)
        tinsert(HH.button.channel, bt)
        right = bt
        bt:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            for _, channelBt in ipairs(HH.button.channel) do
                if channelBt ~= self and channelBt.channelData then
                    channelBt:SetChecked(checked)
                    local v = channelBt.channelData
                    if checked then
                        HHdb.channels[v.name] = { channelID = v.channelID, join = true, yell = v.yell }
                    else
                        HHdb.channels[v.name] = nil
                    end
                end
            end
            PlaySound(HH.sound1)
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine("选择全部频道", 1, 1, 1)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)
    end

    CreateButton({ channelID = "Y", name = "大喊", yell = true })

    for _, v in ipairs(HH.channels) do
        CreateButton(v)
    end

    -- 设置 All 初始勾选状态
    local allChecked = true
    for _, bt in ipairs(HH.button.channel) do
        if bt.channelData and not bt:GetChecked() then
            allChecked = false
            break
        end
    end
    HH.button.channel[1]:SetChecked(allChecked)
end

-- 进入世界 / 频道更新时刷新频道按钮
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("CHANNEL_UI_UPDATE")
f:SetScript("OnEvent", function(self, even, ...)
    C_Timer.After(0.5, function()
        HH.UpdateChannel()
    end)
end)

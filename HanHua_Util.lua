-- HanHua_Util.lua - 工具函数和常量
-- 此文件必须在 HanHua.lua 之前加载
local AddonName, ADDONSELF = ...

local pt                   = print
local GetAddOnMetadata     = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local IsAddOnLoaded        = IsAddOnLoaded or C_AddOns.IsAddOnLoaded
local LoadAddOn            = LoadAddOn or C_AddOns.LoadAddOn

BINDING_HEADER_HANHUA      = "HanHua喊话助手"
BINDING_NAME_FASONG        = "发送喊话"

HH                         = {}
HH.button                  = {}
HH.sound1                  = SOUNDKIT.GS_TITLE_OPTION_OK

HH.MAX_HISTORY             = 15
HH.SendColdTime            = 20

-- 从 HanHua_Config.lua 读取配置, 无配置使用默认值
HH.PREFIX_MAX              = (type(HH_config) == "table" and HH_config.prefix_max) or 40
HH.MIDDLE_MAX              = (type(HH_config) == "table" and HH_config.middle_max) or 100
HH.SUFFIX_MAX              = (type(HH_config) == "table" and HH_config.suffix_max) or 20
HH.FRAME_WIDTH             = (type(HH_config) == "table" and HH_config.frame_width) or 325
HH.FRAME_HEIGHT            = (type(HH_config) == "table" and HH_config.frame_height) or 330
HH.QI_HEIGHT               = (type(HH_config) == "table" and HH_config.qi_height) or 325
HH.maxBytes                = HH.PREFIX_MAX + HH.MIDDLE_MAX + HH.SUFFIX_MAX

HH.ver                     = "v" .. GetAddOnMetadata(AddonName, "Version")

-- 更新内容
do
    HH.update = {
        [[|cff00ff004月9日更新1.1.2版本]],
        [[喊话最大字符数从128增加至168]],
        [[适配时光服3.80.1]],
    }
end

local function RGB(hex)
    local red = string.sub(hex, 1, 2)
    local green = string.sub(hex, 3, 4)
    local blue = string.sub(hex, 5, 6)
    red = tonumber(red, 16) / 255
    green = tonumber(green, 16) / 255
    blue = tonumber(blue, 16) / 255
    return red, green, blue
end

local size = 12
local Green1 = "Green1" -- HH.FontGreen1
HH["Font" .. Green1] = CreateFont("HH.Font" .. Green1)
HH["Font" .. Green1]:SetTextColor(RGB("00FF00"))
HH["Font" .. Green1]:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")

HH.FontDisabled = CreateFont("HH.FontDisabled")
HH.FontDisabled:SetTextColor(RGB("808080"))
HH.FontDisabled:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")

HH.FontHilight = CreateFont("HH.FontHilight")
HH.FontHilight:SetTextColor(RGB("FFFFFF"))
HH.FontHilight:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")

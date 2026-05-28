-- HanHua_QuickInput.lua
-- 快捷输入配置，JSON 风格的 Lua 表，方便修改
-- 修改后 /reload 生效

if not HH_QuickInput then HH_QuickInput = {} end

-- prefix: 活动（开团副本信息）
HH_QuickInput.prefix = {
    label = "活动",
    options = {
        -- 经典旧世 P1-P5
        "MC+黑龙百元均分黑龙百元均分黑龙百元均分黑龙百元均分黑龙百元均分黑龙百元均分",
        "MC全通",
        "黑龙MM",
        "BWL百元均分",
        "BWL龙息",
        "ZG百元均分",
        "ZG龙虎",
        "废墟百元均分",
        "TAQ百元均分",
        "TAQ全通",
        "NAXX双龙百元均分",
        "NAXX单龙全通",
        "NAXX全通",
        -- TBC P6-P9
        "KLZ百元均分",
        "KLZ午夜队",
        "格鲁尔玛瑟里顿",
        "毒蛇神殿",
        "风暴要塞",
        "海山黑庙",
        "BT百元均分",
        "SW百元均分",
        "SW全通",
        "ZAM百元均分",
        "ZAM冲熊",
        -- WLK P10
        "NAXX双龙百元均分",
        "黑曜石3+1",
        "永恒之眼",
        "ULD百元均分",
        "ULD观星",
        "TOC百元均分",
        "HTOC 50箱",
        "ICC百元均分",
        "ICCH成就龙",
        "RS百元均分",
    },
}

-- content: 职业招募（多选，按分组展示，勾选后用 "/" 拼接，前面加前缀 "来 "）
HH_QuickInput.content = {
    label = "职业",
    prefix = "来 ",
    groups = {
        {
            label = "T",
            options = {
                "FQ",
                "DKT",
                "熊T",
                "防战",
            },
        },
        {
            label = "N",
            options = {
                "JLM",
                "NQ",
                "奶萨",
                "奶D",
                "神牧",
            },
        },
        {
            label = "近战DPS",
            options = {
                "CJQ",
                "BDK",
                "XDK",
                "猫D",
                "WQZ",
                "KBZ",
                "增强萨",
                "战斗贼",
                "刺杀贼",
                "敏锐贼",
                "生存猎",
            },
        },
        {
            label = "远程DPS",
            options = {
                "鸟D",
                "火法",
                "奥法",
                "冰法",
                "痛苦术",
                "恶魔术",
                "毁灭术",
                "元素萨",
                "射击猎",
                "兽王猎",
                "暗牧",
            },
        },
        {
            label = "泛称",
            options = {
                "T",
                "N",
                "DPS",
                "TN",
                "远程",
                "近战",
            },
        },
    },
}

-- suffix: 备注（某些职业位置已满）
HH_QuickInput.suffix = {
    label = "备注",
    options = {
        "T满",
        "N满",
        "TN满",
        "近战满",
        "远程满",
    },
}

-- Recruit_QuickInput.lua
-- 快捷输入配置，JSON 风格的 Lua 表，方便修改
-- 修改后 /reload 生效

if not HH_QuickInput then
    HH_QuickInput = {}
end

-- gtuan: 重要信息（分组展示，单选，和活动一样点击填入）
HH_QuickInput.gtuan = {
    label = "重要",
    groups = {
        {
            label = "通用",
            options = {
                '项链升级可包',
                '橙锤升级可包',
                '风剑升级可包',
                '橙匕升级可包',
                '橙杖升级可包',
            },
        },
        {
            label = "宝库",
            options = {
                'P10宝库',
                'P9宝库',
                'P8宝库',
                'P7宝库',
                'P6宝库',
                'P5宝库',
                'P4宝库',
                'P3宝库',
                'P2宝库',
                'P1宝库',
            },
        },
        {
            label = "P3",
            options = {
                '橙匕可包',
                '橙匕2w已包',
            },
        },
        {
            label = "P2",
            options = {
                '风剑可包',
                '风剑2.5w已包',
                '片可包',
                '片1000已包',
            },
        },
        {
            label = "P1",
            options = {
                '锭可包',
                '锭3k已包',
                '眼可包',
                '眼1.5w已包',
                '眼1.8w已包',
                '眼2w已包',
                '项链可包',
                '项链2w已包',
                '项链2.2w已包',
                '锭眼项链可包',
                '锭3k眼1.5项链2w已包',
                '锭3k眼1.6项链2.2w已包',
            },
        },
    },
}

-- prefix: 活动（开团副本信息，按阶段分组展示）
HH_QuickInput.prefix = {
    label = "活动",
    groups = {
        {
            label = "通用",
            options = {
            },
        },
        {
            label = "宝库",
            options = {
                '单Boss摸奖,团长分配单天赋,特殊职业2-3',
            },
        },
        {
            label = "P4",
            options = {
                'TOC+ZUG百元团',
            },
        },
        {
            label = "P3",
            options = {
                'NAXX双龙百元团',
            },
        },
        {
            label = "P2",
            options = {
                'P2双龙摸奖全拍百元团',
                '毒蛇134摸奖全拍百元团',
                '毒蛇134风暴1摸奖全拍百元团',
            },
        },
        {
            label = "P1",
            options = {
                'MC全通百元团',
                'MC后四摸奖百元团',
                'MC10人项链摸奖',
            },
        },
    },
}

-- tuanbu: 补充信息（分组展示，多选，和职业/备注一样勾选拼接）
HH_QuickInput.tuanbu = {
    label = "补充",
    prefix = "补充:",
    groups = {
        {
            label = "通用",
            options = {
                "RT5N4",
                "RT4N3",
                "RT3N2",
                "RTN4",
                "RTN3",
                "RTN2",
                "RTN1",
                "出橙RTN1",
                "出橙RTN2",
                "出橙R2TN1",
            },
        },
        {
            label = "DPS",
            options = {
                "远近543",
                "远近432",
                "远近321",
            },
        },
        {
            label = "特殊",
            options = {
                "鱼1",
                "特殊1",
                "工具1",
                "装等+,
                "FM宝石全",
            },
        },
    },
}

-- content: 职业喊话（多选，按分组展示，勾选后用 "/" 拼接，前面加前缀 "来 "）
HH_QuickInput.content = {
    label = "职业",
    prefix = "来 ",
    groups = {
        {
            label = "通用",
            options = {
                "ZS",  -- 战士                                                                                                                                                   █
                "DK",  -- 死亡骑士
                "DZ",  -- 盗贼
                "LR",  -- 猎人
                "FS",  -- 法师
                "MS",  -- 牧师
                "SM",  -- 萨满
                "QS",  -- 圣骑士
                "XD",  -- 德鲁伊
                "SS",  -- 术士
            },
        },
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
                "NQ",
                "奶萨",
                "奶D",
                "JLM",
                "神牧",
            },
        },
        {
            label = "近战DPS",
            options = {
                "CJQ",
                "猫D",
                "WQZ",
                "ZQS",
                "KBZ",
                "BDK",
                "XDK",
                "战斗贼",
                "刺杀贼",
                "敏锐贼",
            },
        },
        {
            label = "远程DPS",
            options = {
                "鸟D",
                "AM",
                "恶魔术",
                "元素萨",
                "LR",
                "冰法",
                "火法",
                "奥法",
                "痛苦术",
                "毁灭术",
                "射击猎",
                "兽王猎",
                "生存猎",
            },
        },
        {
            label = "泛称",
            options = {
                "TN",
                "DPS",
                "远程",
                "近战",
                "T",
                "N",
            },
        },
    },
}

-- suffix: 备注（某些职业位置已满，分组展示，多选后用 "/" 拼接）
HH_QuickInput.suffix = {
    label = "备注",
    groups = {
        {
            label = "位置已满",
            options = {
                "T满",
                "N满",
                "TN满",
                "近战满",
                "远程满",
            },
        },
        {
            label = "价格",
            options = {
                "2.5w锅",
                "2.5w减半",
                "3w锅",
                "3w减半",
            },
        },
        {
            label = "通用",
            options = {
                "报职天赋M",
                "满不回",
                "666自动进组",
            },
        },
    },
}


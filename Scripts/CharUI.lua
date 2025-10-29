local Mod = GameMain:GetMod("CanVox.ShowLawStats");

Mod.CharUI = Mod.CharUI or {}
local CharUI = Mod.CharUI

function CharUI:PerkClicked(context)
    local perk = NpcMgr.ExperienceMgr:GetDef(context.data.data)

    local gongName = nil
    if perk then 
        if perk.Gongs and perk.Gongs.Count > 0 then 
            gongName = perk.Gongs[0]
        end
    end

    local gong = nil 
    if gongName then
        gong = PracticeMgr:GetGongDef(gongName)
    end

    if gong then 
        if context.data.selected then 
            self.SelectedGong = gong
        elseif self.SelectedGong == gong then 
            self.SelectedGong = nil 
            self:HideLaw()
        end
    end

    if self.SelectedGong then 
        self:RefreshLaw()
    end
end

function CharUI:RandomizeClicked(context)
    if self.NPCSelector.selectedIndex == 0 then 
        self.SelectedGong = nil 
        self:HideLaw()
    end
end

function CharUI:NPCSwitched(context)
    if self.NPCSelector.selectedIndex ~= 0 then 
        self:HideLaw()
    elseif self.SelectedGong then
        self:RefreshLaw()
    end
end

function CharUI:RefreshLaw()
    local lawMatch = CS.XiaWorld.NpcPractice.GetFiveBaseEfficiency(self.SelectedGong, self.NPCManager.npcs[0])
    local format = XT("匹配程度：{0:P0}"):gsub("{0:P0}","%%.f %%%%")
    self.MatchLabel.text = string.format(format,lawMatch*100)
    self.MatchLabel:SetBoundsChangedFlag()
    self.MatchLabel:EnsureBoundsCorrect()
    self.MatchLabel.x = (149 - self.MatchLabel.width/2)
    self.MatchLabel.visible = true 

    local finalStats = {}
    local neededStats = self.SelectedGong:GetFiveBaseNeed()
    for i=1,neededStats.Length do 
        if neededStats[i-1] ~= -1 then 
            finalStats[i] = neededStats[i-1] / 10
        else
            finalStats[i] = 0.1
        end
    end
    finalStats[6] = 0.1

    self.LawStatHex:UpdateData(finalStats)
    self.LawStats.visible = true
end

function CharUI:HideLaw()
    self.MatchLabel.visible = false
    self.LawStats.visible = false
end

function CharUI:MarkUp(UIInfo) 
    self.NPCManager = CS.Wnd_NpcGentrate.Instance.Mechine

    self.LawStats = UIPackage.CreateObjectFromURL("ui://0xrxw6g7qfkrgb")
    self.LawStats.x = 171
    self.LawStats.y = 156
    self.LawStats.visible = false
    self.LawStats.m_n89.visible = false 
    self.LawStats.m_n91.visible = false
    self.LawStats.m_n92.visible = false
    self.LawStats.m_n93.visible = false
    self.LawStats.m_n94.visible = false
    self.LawStats.m_n95.visible = false
    self.LawStats.m_n96.visible = false
    self.LawStats.m_FiveBase:SetSize(213, 185)
    UIInfo:AddChild(self.LawStats)

    self.LawStatHex = CS.StarofDavid.NewView(CS.UnityEngine.Color(0.439, 0.788, 0.792, 0.667))
    self.LawStatHex.transform.localPosition = CS.UnityEngine.Vector3.zero
    self.LawStatHex.transform.localScale = CS.UnityEngine.Vector3(80, 80, 80)
    
    if self.LawStatWrapper then 
        self.LawStatWrapper.wrapTarget = nil 
        self.LawStatWrapper:Dispose()
    end
    
    self.LawStatWrapper = CS.FairyGUI.GoWrapper(self.LawStatHex.gameObject)
    self.LawStats.m_FiveBase:SetNativeObject(self.LawStatWrapper)

    self.MatchLabel = UIPackage.CreateObjectFromURL("ui://0xrxw6g7gtsug9")
    self.MatchLabel.visible = false
    self.MatchLabel.y = 150
    UIInfo:AddChild(self.MatchLabel)

    UIInfo.m_n143.m_n149.onClickItem:Add(
        function(ctx)
            local success, err = pcall(function()
                self:PerkClicked(ctx)
            end)
            if not success then 
                print(err)
            end
        end
    )
    UIInfo.m_n48.onClick:Add(
        function(ctx)
            local success, err = pcall(function()
                self:RandomizeClicked(ctx)
            end)
            if not success then 
                print(err)
            end
        end
    )

    self.NPCSelector = UIInfo.parent.m_n67
    UIInfo.parent.m_n67.onClickItem:Add(
        function(ctx)
            local success, err = pcall(function()
                self:NPCSwitched(ctx)
            end)
            if not success then 
                print(err)
            end
        end
    )
end

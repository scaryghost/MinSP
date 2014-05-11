class PerksTab extends KFTab_Perks;

var MSPLinkedReplicationInfo mspLRepInfo;
var automated moNumericEdit perkLevels;
var GUIComboBox perksBox;

function ShowPanel(bool bShow) {
    super(UT2K4TabPanel).ShowPanel(bShow);

    if (bShow) {
        if (PlayerOwner() != none) {
            KFStatsAndAchievements= KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements);

            // Initialize the List
            lb_PerkSelect.List.InitList(KFStatsAndAchievements);

            mspLRepInfo= class'MSPLinkedReplicationInfo'.static.findLRI(PlayerOwner().PlayerReplicationInfo);
            perkLevels.Setup(mspLRepInfo.minPerkLevel, mspLRepInfo.maxPerkLevel, 1);
            perkLevels.SetValue(mspLRepInfo.desiredPerkLevel);
        }

        l_ChangePerkOncePerWave.SetVisibility(false);
    }
}

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
    Super.InitComponent(MyController, MyOwner);
    
    i_BGPerkNextLevel.UnManageComponent(lb_PerkProgress);
    i_BGPerkNextLevel.ManageComponent(perkLevels);

}

function OnPerkSelected(GUIComponent Sender) {
    lb_PerkEffects.SetContent(mspLRepInfo.veterancyTypes[lb_PerkSelect.GetIndex()]
            .default.LevelEffects[perkLevels.GetValue()]);
    if (Sender == perkLevels) {
        PerkSelectList(lb_PerkSelect.List).updateLevelStrings(perkLevels.GetValue());
    }
}

function bool OnSaveButtonClicked(GUIComponent Sender) {
    local PlayerController PC;

    PC = PlayerOwner();

    if (KFPlayerController(PC).bChangedVeterancyThisWave && KFPlayerController(PC).SelectedVeterancy != mspLRepInfo.veterancyTypes[lb_PerkSelect.GetIndex()]) {
        l_ChangePerkOncePerWave.SetVisibility(true);
    } else {
        mspLRepInfo.desiredPerkLevel= perkLevels.GetValue();
        mspLRepInfo.changePerk(lb_PerkSelect.GetIndex());
        perksBox.DisableMe();
        perksBox.Edit.SetText(KFPlayerController(PC).SelectedVeterancy.default.VeterancyName);
        PerksBox.Edit.SetFocus(None);
    }

    return true;
}

defaultproperties {
    lb_PerkProgress=None

    Begin Object Class=KFPerkSelectListBox Name=PerkSelectList
        OnCreateComponent=PerkSelectList.InternalOnCreateComponent
        WinTop=0.091627
        WinLeft=0.029240
        WinWidth=0.437166
        WinHeight=0.742836
        DefaultListClass="MinSP.PerkSelectList"
    End Object
    lb_PerkSelect=KFPerkSelectListBox'MinSP.PerksTab.PerkSelectList'

    Begin Object Class=GUISectionBackground Name=BGPerksNextLevel
        bFillClient=True
        Caption="Perk Configuration"
        WinTop=0.413209
        WinLeft=0.486700
        WinWidth=0.490282
        WinHeight=0.415466
        OnPreDraw=BGPerksNextLevel.InternalPreDraw
    End Object
    i_BGPerkNextLevel=GUISectionBackground'MinSP.PerksTab.BGPerksNextLevel'

    Begin Object Class=moNumericEdit Name=PerkLevelsBox
        OnChange=PerksTab.OnPerkSelected
        Caption="Perk Level"
        Hint="Set perk level"
    End Object
    perkLevels=moNumericEdit'MinSP.PerksTab.PerkLevelsBox'
}

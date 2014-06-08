class MidGamePerksTab extends KFTab_MidGamePerks;

var MSPLinkedReplicationInfo mspLRepInfo;
var automated moNumericEdit perkLevelsEdit;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
    super.InitComponent(MyController, MyOwner);

    i_BGPerkNextLevel.UnManageComponent(lb_PerkProgress);
    i_BGPerkNextLevel.ManageComponent(perkLevelsEdit);
}

function ShowPanel(bool bShow) {
    super(MidGamePanel).ShowPanel(bShow);

    if (bShow && PlayerOwner() != none) {
        mspLRepInfo= class'MSPLinkedReplicationInfo'.static.findLRI(PlayerOwner().PlayerReplicationInfo);

        PerkSelectList(lb_PerkSelect.List).InitList_MSPLRepInfo(mspLRepInfo);
        perkLevelsEdit.Setup(mspLRepInfo.minPerkLevel, mspLRepInfo.maxPerkLevel, 1);
        perkLevelsEdit.SetValue(mspLRepInfo.desiredPerkLevel);
        lb_PerkEffects.SetContent(mspLRepInfo.veterancyTypes[lb_PerkSelect.GetIndex()]
                .default.LevelEffects[perkLevelsEdit.GetValue()]);
        InitGRI();
    }
}

function bool OnSaveButtonClicked(GUIComponent Sender) {
    mspLRepInfo.desiredPerkLevel= perkLevelsEdit.GetValue();
    mspLRepInfo.changePerk(lb_PerkSelect.GetIndex());
    return true;
}

function OnPerkSelected(GUIComponent Sender) {
    lb_PerkEffects.SetContent(mspLRepInfo.veterancyTypes[lb_PerkSelect.GetIndex()]
            .default.LevelEffects[perkLevelsEdit.GetValue()]);
    if (Sender == perkLevelsEdit) {
        PerkSelectList(lb_PerkSelect.List).updateLevelStrings(perkLevelsEdit.GetValue());
    }
}

defaultproperties {
    lb_PerkProgress=None
    Begin Object Class=KFPerkSelectListBox Name=PerkSelectBox
        OnCreateComponent=PerkSelectBox.InternalOnCreateComponent
        WinTop=0.057760
        WinLeft=0.029240
        WinWidth=0.437166
        WinHeight=0.742836
        DefaultListClass="MinSP.PerkSelectList"
    End Object
    lb_PerkSelect=PerkSelectBox

    Begin Object Class=GUISectionBackground Name=PerkConfig
        bFillClient=True
        Caption="Perk Configuration"
        WinTop=0.392889
        WinLeft=0.486700
        WinWidth=0.490282
        WinHeight=0.415466
        OnPreDraw=PerkConfig.InternalPreDraw
    End Object
    i_BGPerkNextLevel=PerkConfig

    Begin Object class=moNumericEdit Name=PerkLevels
        Caption="Perk Level"
        Hint="Set perk level"
        OnChange=MidGamePerksTab.OnPerkSelected
    End Object
    perkLevelsEdit=PerkLevels
}

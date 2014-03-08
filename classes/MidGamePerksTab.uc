class MidGamePerksTab extends KFTab_MidGamePerks;

var MSPLinkedReplicationInfo mspLRepInfo;

function ShowPanel(bool bShow) {
    super.ShowPanel(bShow);

    if (bShow && PlayerOwner() != none) {
        lb_PerkSelect.List.InitList(KFStatsAndAchievements);
        lb_PerkProgress.List.InitList();
        InitGRI();
        mspLRepInfo= class'MSPLinkedReplicationInfo'.static.findLRI(PlayerOwner().PlayerReplicationInfo);
    }
}

function bool OnSaveButtonClicked(GUIComponent Sender) {
    local PlayerController PC;

    PC = PlayerOwner();
    KFPlayerController(PC).SelectedVeterancy= mspLRepInfo.veterancyTypes[lb_PerkSelect.GetIndex()];
    PC.ServerMutate("perkchange"@lb_PerkSelect.GetIndex());
    return true;
}

function OnPerkSelected(GUIComponent Sender) {
    lb_PerkEffects.SetContent(mspLRepInfo.veterancyTypes[lb_PerkSelect.GetIndex()].default.LevelEffects[KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo).ClientVeteranSkillLevel]);
    lb_PerkProgress.List.PerkChanged(KFStatsAndAchievements, lb_PerkSelect.GetIndex());
}

defaultproperties {
    Begin Object Class=KFPerkSelectListBox Name=PerkSelectBox
        OnCreateComponent=PerkSelectBox.InternalOnCreateComponent
        WinTop=0.057760
        WinLeft=0.029240
        WinWidth=0.437166
        WinHeight=0.742836
        DefaultListClass="MinSP.PerkSelectList"
    End Object
    lb_PerkSelect=PerkSelectBox

    Begin Object Class=KFPerkProgressListBox Name=PerkProgressBox
        OnCreateComponent=PerkProgressBox.InternalOnCreateComponent
        WinTop=0.476850
        WinLeft=0.499269
        WinWidth=0.463858
        WinHeight=0.341256
        DefaultListClass="MinSP.PerkProgressList"
    End Object
    lb_PerkProgress=PerkProgressBox
}
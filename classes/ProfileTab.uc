class ProfileTab extends KFTab_Profile;

var MSPLinkedReplicationInfo mspLRepInfo;

function ShowPanel(bool bShow) {
    if (bShow) {
        if (bInit) {
            bRenderDude= True;
            bInit= False;
        }

        lb_PerkSelect.List.InitList(KFStatsAndAchievements);
        lb_PerkProgress.List.InitList();
    }

    lb_PerkSelect.SetPosition(i_BGPerks.WinLeft + 6.0 / float(Controller.ResX),
                              i_BGPerks.WinTop + 38.0 / float(Controller.ResY),
                              i_BGPerks.WinWidth - 10.0 / float(Controller.ResX),
                              i_BGPerks.WinHeight - 35.0 / float(Controller.ResY),
                              true);
    SetVisibility(bShow);
    mspLRepInfo= class'MSPLinkedReplicationInfo'.static.findLRI(PlayerOwner().PlayerReplicationInfo);
}

function SaveSettings() {
    local PlayerController PC;

    PC = PlayerOwner();

    if (sChar != sCharD) {
        sCharD = sChar;
        PC.ConsoleCommand("ChangeCharacter"@sChar);

        if (!PC.IsA('xPlayer')) {
            PC.UpdateURL("Character", sChar, True);
        }

        if (PlayerRec.Sex ~= "Female") {
            PC.UpdateURL("Sex", "F", True);
        }
        else {
            PC.UpdateURL("Sex", "M", True);
        }
    }


    KFPlayerController(PC).SelectedVeterancy = mspLRepInfo.veterancyTypes[lb_PerkSelect.GetIndex()];
    PC.ServerMutate("perkchange"@lb_PerkSelect.GetIndex());
}

function OnPerkSelected(GUIComponent Sender) {
    lb_PerkEffects.SetContent(mspLRepInfo.veterancyTypes[lb_PerkSelect.GetIndex()].default.LevelEffects[KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo).ClientVeteranSkillLevel]);
    lb_PerkProgress.List.PerkChanged(KFStatsAndAchievements, lb_PerkSelect.GetIndex());
}

defaultproperties {
    Begin Object Class=KFPerkSelectListBox Name=PerkSelectBox
        OnCreateComponent=PerkSelectBox.InternalOnCreateComponent
        WinTop=0.082969
        WinLeft=0.323418
        WinWidth=0.318980
        WinHeight=0.654653
        DefaultListClass="MinSP.PerkSelectList"
    End Object
    lb_PerkSelect=PerkSelectBox

    Begin Object Class=KFPerkProgressListBox Name=PerkProgressBox
        OnCreateComponent=PerkProgressBox.InternalOnCreateComponent
        WinTop=0.439668
        WinLeft=0.670121
        WinWidth=0.319980
        WinHeight=0.292235
        DefaultListClass="MinSP.PerkProgressList"
    End Object
    lb_PerkProgress=PerkProgressBox
}

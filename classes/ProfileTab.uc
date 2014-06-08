class ProfileTab extends KFTab_Profile;

var MSPLinkedReplicationInfo mspLRepInfo;
var automated moNumericEdit perkLevelsEdit;
var bool saveButtonPressed;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
    super.InitComponent(MyController, MyOwner);
    
    i_BGPerkNextLevel.UnManageComponent(lb_PerkProgress);
    i_BGPerkNextLevel.ManageComponent(perkLevelsEdit);
}

function ShowPanel(bool bShow) {
    if (bShow) {
        if (bInit) {
            bRenderDude= True;
            bInit= False;
        }

        mspLRepInfo= class'MSPLinkedReplicationInfo'.static.findLRI(PlayerOwner().PlayerReplicationInfo);
        PerkSelectList(lb_PerkSelect.List).InitList_MSPLRepInfo(mspLRepInfo);
        perkLevelsEdit.Setup(mspLRepInfo.minPerkLevel, mspLRepInfo.maxPerkLevel, 1);
        perkLevelsEdit.SetValue(mspLRepInfo.desiredPerkLevel);
        lb_PerkEffects.SetContent(mspLRepInfo.veterancyTypes[lb_PerkSelect.GetIndex()]
                .default.LevelEffects[perkLevelsEdit.GetValue()]);
    }

    lb_PerkSelect.SetPosition(i_BGPerks.WinLeft + 6.0 / float(Controller.ResX),
                              i_BGPerks.WinTop + 38.0 / float(Controller.ResY),
                              i_BGPerks.WinWidth - 10.0 / float(Controller.ResX),
                              i_BGPerks.WinHeight - 35.0 / float(Controller.ResY),
                              true);
    SetVisibility(bShow);
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


    if (saveButtonPressed) {
        mspLRepInfo.desiredPerkLevel= perkLevelsEdit.GetValue();
        mspLRepInfo.changePerk(lb_PerkSelect.GetIndex());
        saveButtonPressed= false;
    }
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
        WinTop=0.082969
        WinLeft=0.323418
        WinWidth=0.318980
        WinHeight=0.654653
        DefaultListClass="MinSP.PerkSelectList"
    End Object
    lb_PerkSelect=PerkSelectBox

    Begin Object Class=GUISectionBackground Name=PerkConfig
        bFillClient=True
        Caption="Perk Configuration"
        WinTop=0.379668
        WinLeft=0.660121
        WinWidth=0.339980
        WinHeight=0.352235
        OnPreDraw=PerkConfig.InternalPreDraw
    End Object
    i_BGPerkNextLevel=PerkConfig

    Begin Object class=moNumericEdit Name=PerkLevelsBox
        Caption="Perk Level"
        Hint="Set perk level"
        OnChange=ProfileTab.OnPerkSelected
    End Object
    perkLevelsEdit=PerkLevelsBox
}

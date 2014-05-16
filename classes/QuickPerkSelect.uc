class QuickPerkSelect extends GUIMultiComponent;

var Texture perkBack;
var MSPLinkedReplicationInfo mspLRepInfo;
var automated GUIComboBox perkSelect;

event Opened(GUIComponent Sender) {
    local int i;
    local class<KFVeterancyTypes> playerPerk;

    super.Opened(Sender);

    mspLRepInfo= class'MSPLinkedReplicationInfo'.static.findLRI(PlayerOwner().PlayerReplicationInfo);
    playerPerk= KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo).ClientVeteranSkill;

    if (!KFPlayerController(PlayerOwner()).bChangedVeterancyThisWave) {
        perkSelect.EnableMe();
        for(i= 0; i < mspLRepInfo.veterancyTypes.Length; i++) {
            perkSelect.AddItem(mspLRepInfo.veterancyTypes[i].default.VeterancyName, 
                    mspLRepInfo.veterancyTypes[i].default.OnHUDIcon);
            if (playerPerk == mspLRepInfo.veterancyTypes[i]) {
                perkSelect.SetIndex(i);
            }
        }
        perkSelect.OnChange=InternalOnChange;
    } else {
        perkSelect.Edit.SetText(playerPerk.default.VeterancyName);
    }
}

event Closed(GUIComponent Sender, bool bCancelled) {
    super.Closed(Sender, bCancelled);

    perkSelect.OnChange=None;
    perkSelect.Clear();
    mspLRepInfo= None;
}

function InternalOnChange(GUIComponent sender) {
    if (sender == perkSelect) {
        mspLRepInfo.changePerk(perkSelect.GetIndex());
        perkSelect.DisableMe();
    }
}

function bool MyOnDraw(Canvas C) {
    local class<KFVeterancyTypes> perk;

    super.OnDraw(C);
    perk= KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo).ClientVeteranSkill;
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(WinLeft * C.ClipX , WinTop * C.ClipY);
    C.DrawTileScaled(perkBack, (WinHeight * C.ClipY) / perkBack.USize, (WinHeight * C.ClipY) / perkBack.USize);
    C.DrawTileScaled(perk.default.OnHUDIcon, (WinHeight * C.ClipY) / perk.default.OnHUDIcon.USize, 
            (WinHeight * C.ClipY) / perk.default.OnHUDIcon.USize);
        
    return false;
}

defaultproperties {
    OnDraw=MyOnDraw;
    perkBack=Texture'KF_InterfaceArt_tex.Menu.Perk_box'

    Begin Object Class=GUIListBox Name=ListBox1
        StyleName="ComboListBox"
        RenderWeight=0.700000
        bTabStop=False
        bVisible=False
        bNeverScale=True
        DefaultListClass="MinSP.SelectablePerksList"
    End Object

    Begin Object class=GUIComboBox Name=QS
        WinTop=0.031400
        WinLeft=0.09000
        WinWidth=0.215000
        WinHeight=0.030000
        MyListBox=ListBox1
    End Object
    perkSelect=QS
}

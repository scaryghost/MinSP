class LobbyMenu extends LobbyMenu_Story;

var MSPLinkedReplicationInfo mspLRepInfo;
var localized string modInfoText, maxPerkMsg, minPerkMsg, numPerksMsg, versionMsg;
var bool drawn;
var string profilePage;
var automated GUIScrollTextBox modInfoTextBox;

function InitComponent(GUIController MyC, GUIComponent MyO) {
    local int i;

    super(UT2k4MainPage).InitComponent(MyC, MyO);

    for (i = 0; i < 6; i++) {
        PlayerPerk[i].WinWidth= PlayerPerk[i].ActualHeight();
        PlayerPerk[i].WinLeft+= ((PlayerBox[i].ActualHeight() - PlayerPerk[i].ActualHeight()) / 2) / MyC.ResX;
    }

    i_Portrait.WinTop= PlayerPortraitBG.ActualTop() + 30;
    i_Portrait.WinHeight= PlayerPortraitBG.ActualHeight() - 36;
    t_ChatBox.FocusInstead= PerkClickLabel;
}

event Opened(GUIComponent Sender) {
    SetTimer(1,true);
    VideoTimer = 0.0;
    VideoPlayed = false;
    VideoOpened = false;

    if (PlayerOwner().GameReplicationInfo.IsA('KF_StoryGRI')) {
        WaveBG.Image= None;
        WaveBG.DisableMe();
    } else {
        WaveBG.Image= Texture'KillingFloorHUD.HUD.Hud_Bio_Circle';
        WaveLabel.EnableMe();
    }

    mspLRepInfo= class'MSPLinkedReplicationInfo'.static.findLRI(PlayerOwner().PlayerReplicationInfo);
}

function bool ShowPerkMenu(GUIComponent Sender) {
    if (PlayerOwner() != none) {
        PlayerOwner().ClientOpenMenu(profilePage, false);
    }
    return true;
}

function bool InternalOnPreDraw(Canvas C) {
    local int i, j, z;
    local string StoryString;
    local String SkillString;
    local KFGameReplicationInfo KFGRI;
    local PlayerController PC;
    local PlayerReplicationInfo InList[6];
    local bool bWasThere;

    PC = PlayerOwner();

    if (PC == none || PC.Level == none) { // Error?
        return false;
    }

    i_Portrait.WinTop= PlayerPortraitBG.ActualTop() + 30;
    i_Portrait.WinHeight= PlayerPortraitBG.ActualHeight() - 36;

    if (PC.PlayerReplicationInfo != none && (!PC.PlayerReplicationInfo.bWaitingPlayer || PC.PlayerReplicationInfo.bOnlySpectator)) {
        PC.ClientCloseMenu(True,False);
        return false;
    }

    t_Footer.InternalOnPreDraw(C);
    WaveLabel.WinWidth = WaveLabel.ActualHeight();
    KFGRI = KFGameReplicationInfo(PC.GameReplicationInfo);
    if (KFGRI != None && !KFGRI.IsA('KF_StoryGRI')) {
        WaveLabel.Caption = string(KFGRI.WaveNumber + 1) $ "/" $ string(KFGRI.FinalWave);
    } else {
        WaveLabel.Caption= "";
        WaveLabel.DisableMe();
    }

    // First fill in non-ready players.
    if (KFGRI != none) {
        for (i = 0; i < KFGRI.PRIArray.Length; i++) {
            if (KFGRI.PRIArray[i] == none || KFGRI.PRIArray[i].bOnlySpectator || KFGRI.PRIArray[i].bReadyToPlay) {
                continue;
            }

            PlayerPerk[j].Image = none;
            ReadyBox[j].Checked(False);
            ReadyBox[j].SetCaption(Left(KFGRI.PRIArray[i].PlayerName, 20));

            if (KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkill != none) {
                PlayerVetLabel[j].Caption = LvAbbrString @ KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkillLevel @ KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkill.default.VeterancyName;
                PlayerPerk[j].Image = KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkill.default.OnHUDIcon;
            }

            InList[j] = KFGRI.PRIArray[i];
            j++;
            if (j >= 6) {
                GoTo'DoneIt';
            }
        }

        // Then comes rest.
        for (i = 0; i < KFGRI.PRIArray.Length; i++) {
            if ( KFGRI.PRIArray[i] == none || KFGRI.PRIArray[i].bOnlySpectator ) {
                Continue;
            }

            bWasThere = False;

            for (z = 0; z < j; z++) {
                if (InList[z] == KFGRI.PRIArray[i]) {
                    bWasThere = True;
                    Break;
                }
            }

            if (bWasThere) {
                Continue;
            }

            PlayerPerk[j].Image= none;
            ReadyBox[j].Checked(KFGRI.PRIArray[i].bReadyToPlay);
            ReadyBox[j].SetCaption(Left(KFGRI.PRIArray[i].PlayerName, 20));

            if (KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkill != none) {
                PlayerVetLabel[j].Caption= LvAbbrString @ KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkillLevel @ KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkill.default.VeterancyName;
                PlayerPerk[j].Image= KFPlayerReplicationInfo(KFGRI.PRIArray[i]).ClientVeteranSkill.default.OnHUDIcon;
            }

            if (KFGRI.PRIArray[i].bReadyToPlay) {

                if (!bTimeoutTimeLogged) {
                    ActivateTimeoutTime = PC.Level.TimeSeconds;
                    bTimeoutTimeLogged = true;
                }
            }
            j++;
            if (j >= 6) {
                Break;
            }
        }
    }

    while (j < 6) {
        PlayerPerk[j].Image = none;
        ReadyBox[j].Checked(False);
        ReadyBox[j].SetCaption("");
        PlayerVetLabel[j].Caption = "";
        j++;
    }

DoneIt:
    StoryString = PC.Level.Description;

    if (!bStoryBoxFilled) {
        l_StoryBox.LoadStoryText();
        bStoryBoxFilled = true;
    }

    CheckBotButtonAccess();

    // Hate to do it like this, but there's no real easy way to get the SkillLevel strings from the Scoreboard, since it's only ever
    // called as a class. Spawning a fresh one /w DynamicLoadObject doesn't work too great (online).
    if (KFGRI != none) {
        if (KFGRI.BaseDifficulty == 1) {
            SkillString = BeginnerString;
        } else if (KFGRI.BaseDifficulty == 2) {
            SkillString = NormalString;
        } else if (KFGRI.BaseDifficulty == 4) {
            SkillString = HardString;
        } else if (KFGRI.BaseDifficulty == 5) {
            SkillString = SuicidalString;
        } else if (KFGRI.BaseDifficulty == 7) {
            SkillString = HellOnEarthString;
        }
    }

    CurrentMapLabel.Caption = CurrentMapString @ PC.Level.Title;
    DifficultyLabel.Caption = DifficultyString @ SkillString;

    return false;
}


function DrawPerk(Canvas Canvas) {
    local float X, Y, Width, Height;
    local int LevelIndex;
    local float TempX, TempY;
    local float TempWidth, TempHeight;
    local float IconSize, ProgressBarWidth, PerkProgress;
    local string PerkName, PerkLevelString;

    DrawPortrait();

    if (!drawn) {
        // Taken from ServerPerks.SRLobbyMenu
        X = 9.f/Canvas.ClipX;
        Y = 32.f/Canvas.ClipY;
        modInfoTextBox.WinWidth = ADBackground.WinWidth-X*2.f;
        modInfoTextBox.WinHeight = ADBackground.WinHeight-Y*1.25f;
        modInfoTextBox.WinLeft = ADBackground.WinLeft+X;
        modInfoTextBox.WinTop = ADBackground.WinTop+Y;

        modInfoText$= "||" $ versionMsg $ ": " $ class'MSPMut'.default.version;
        modInfoText$= "|" $ maxPerkMsg $ ":  " $ mspLRepInfo.minPerkLevel;
        modInfoText$= "|" $ minPerkMsg $ ":  " $ mspLRepInfo.maxPerkLevel;
        modInfoText$= "|" $ numPerksMsg $ ": " $ mspLRepInfo.veterancyTypes.Length;
        modInfoTextBox.SetContent(modInfoText);
        drawn= true;
    }

    LevelIndex= KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo).ClientVeteranSkillLevel;
    PerkName=  mspLRepInfo.desiredPerk.default.VeterancyName;
    PerkLevelString= LvAbbrString @ LevelIndex;
    PerkProgress= 0;

    //Get the position size etc in pixels
    X= i_BGPerk.ActualLeft() + 5;
    Y= i_BGPerk.ActualTop() + 30;

    Width= i_BGPerk.ActualWidth() - 10;
    Height= i_BGPerk.ActualHeight() - 37;

    // Offset for the Background
    TempX= X;
    TempY= Y + ItemSpacing / 2.0;

    // Initialize the Canvas
    Canvas.Style= 1;
    Canvas.Font= class'ROHUD'.Static.GetSmallMenuFont(Canvas);
    Canvas.SetDrawColor(255, 255, 255, 255);

    // Draw Item Background
    Canvas.SetPos(TempX, TempY);
    //Canvas.DrawTileStretched(ItemBackground, Width, Height);

    IconSize= Height - ItemSpacing;

    // Draw Item Background
    Canvas.DrawTileStretched(PerkBackground, IconSize, IconSize);
    Canvas.SetPos(TempX + IconSize - 1.0, Y + 7.0);
    Canvas.DrawTileStretched(InfoBackground, Width - IconSize, Height - ItemSpacing - 14);

    IconSize-= IconBorder * 2.0 * Height;

    // Draw Icon
    Canvas.SetPos(TempX + IconBorder * Height, TempY + IconBorder * Height);
    Canvas.DrawTile(mspLRepInfo.desiredPerk.default.OnHUDIcon, IconSize, IconSize, 0, 0, 256, 256);

    TempX+= IconSize + (IconToInfoSpacing * Width);
    TempY+= TextTopOffset * Height + ItemBorder * Height;

    ProgressBarWidth= Width - (TempX - X) - (IconToInfoSpacing * Width);

    // Select Text Color
    Canvas.SetDrawColor(0, 0, 0, 255);

    // Draw the Perk's Level name
    Canvas.StrLen(PerkName, TempWidth, TempHeight);
    Canvas.SetPos(TempX, TempY);
    Canvas.DrawText(PerkName);

    // Draw the Perk's Level
    if (PerkLevelString != "") {
        Canvas.StrLen(PerkLevelString, TempWidth, TempHeight);
        Canvas.SetPos(TempX + ProgressBarWidth - TempWidth, TempY);
        Canvas.DrawText(PerkLevelString);
    }

    TempY+= TempHeight + (0.04 * Height);

    // Draw Progress Bar
    Canvas.SetDrawColor(255, 255, 255, 255);
    Canvas.SetPos(TempX, TempY);
    Canvas.DrawTileStretched(ProgressBarBackground, ProgressBarWidth, ProgressBarHeight * Height);
    Canvas.SetPos(TempX + 3.0, TempY + 3.0);
    Canvas.DrawTileStretched(ProgressBarForeground, (ProgressBarWidth - 6.0) * PerkProgress, (ProgressBarHeight * Height) - 6.0);

    if (CurrentVeterancy != mspLRepInfo.desiredPerk || CurrentVeterancyLevel != LevelIndex) {
        lb_PerkEffects.SetContent(mspLRepInfo.desiredPerk.default.LevelEffects[LevelIndex]);
        CurrentVeterancy = mspLRepInfo.desiredPerk;
        CurrentVeterancyLevel = LevelIndex;
    }
}


defaultproperties {
    maxPerkMsg="Min perk level"
    minPerkMsg="Max perk level"
    numPerksMsg="Number of perks"
    modInfoText="Minimalist Server Perks"
    versionMsg= "Version"
    profilePage="MinSP.ProfilePage"
    OnPreDraw=InternalOnPreDraw

    Begin Object Class=MinSP.LobbyFooter Name=Footer
        RenderWeight=0.300000
        TabOrder=8
        bBoundToParent=False
        bScaleToParent=False
        OnPreDraw=BuyFooter.InternalOnPreDraw
    End Object
    t_Footer=Footer

    Begin Object Class=GUIScrollTextBox Name=ModInfo
        WinWidth=0.312375
        WinHeight=0.335000
        WinLeft=0.072187
        WinTop=0.354102
        CharDelay=0.0025
        EOLDelay=0.1
        TabOrder=9
        StyleName="NoBackground"
    End Object
    modInfoTextBox=ModInfo

    Begin Object Class=GUIImage Name=WaveB
        Image=Texture'KillingFloorHUD.HUD.Hud_Bio_Circle'
        ImageStyle=ISTY_Justified
        ImageRenderStyle=MSTY_Normal
        WinTop=0.043810
        WinLeft=0.923238
        WinWidth=0.051642
        WinHeight=0.061783
        RenderWeight=0.800000
    End Object
    WaveBG=GUIImage'KFGui.LobbyMenu.WaveB'

    Begin Object Class=GUILabel Name=WaveL
        Caption="1/4"
        TextAlign=TXTA_Center
        TextColor=(B=158,G=176,R=175)
        VertAlign=TXTA_Center
        FontScale=FNS_Small
        WinTop=0.043810
        WinLeft=0.923238
        WinWidth=0.051642
        WinHeight=0.061783
        RenderWeight=0.900000
    End Object
    WaveLabel=GUILabel'KFGui.LobbyMenu.WaveL'
}

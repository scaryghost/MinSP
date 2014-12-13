class MSPInteraction extends Interaction;

var GUIBuyMenu menu;
var string lobbyMenuClass;

event NotifyLevelChange() {
    menu.bPersistent= false;
    Master.RemoveInteraction(self);
}

function Tick (float DeltaTime) {
    local MSPLinkedReplicationInfo mspLRepInfo;
    local KFGUIController guiController;

    guiController= KFGUIController(ViewportOwner.GUIController);
    mspLRepInfo= class'MSPLinkedReplicationInfo'.static.findLRI(ViewportOwner.Actor.PlayerReplicationInfo);
    if (mspLRepInfo != none && guiController != none && guiController.ActivePage != none && 
            ClassIsChildOf(guiController.ActivePage.class, class'KFGui.LobbyMenu')) {
        KFPlayerController(ViewportOwner.Actor).LobbyMenuClassString= lobbyMenuClass;
        ViewportOwner.Actor.ClientCloseMenu(true, true);
        KFPlayerController(ViewportOwner.Actor).ShowLobbyMenu();

        mspLRepInfo.ownerController= KFPlayerController(ViewportOwner.Actor);
        mspLRepInfo.changeRandomPerk();
        bRequiresTick= false;
    }
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta ) {
    local KFPlayerController kfPC;
    local string alias;
    local ShopVolume shop;
    local GUITabControl tabControl;
    local QuickPerkSelect qps;
    local int i;
    local bool canOpenTrader, isObjectiveMode;
    local KF_StoryObjective currentObj;

    alias= ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key));
    kfPC= KFPlayerController(ViewportOwner.Actor);
    isObjectiveMode= kfPC.GameReplicationInfo.IsA('KF_StoryGRI');
    if (isObjectiveMode) {
        currentObj= KF_StoryGRI(kfPC.GameReplicationInfo).GetCurrentObjective();
    }
    canOpenTrader= isObjectiveMode && (currentObj == None || currentObj.IsTraderObj() || 
                    KF_StoryGRI(kfPC.GameReplicationInfo).MaxMonsters == 0) || 
                !isObjectiveMode && !KFGameReplicationInfo(kfPC.GameReplicationInfo).bWaveInProgress;

    if (canOpenTrader && Action == IST_Press && alias ~= "use") {
        foreach ViewportOwner.Actor.Pawn.TouchingActors(class'ShopVolume', shop) {
            if (!ClassIsChildOf(KFGUIController(ViewportOwner.GUIController).ActivePage.class, class'KFGui.GUIBuyMenu')) {
                kfPC.SelectedVeterancy= KFPlayerReplicationInfo(kfPC.PlayerReplicationInfo).ClientVeteranSkill;
                kfPC.ShowBuyMenu("MyTrader", KFHumanPawn(ViewportOwner.Actor.Pawn).MaxCarryWeight);
            }
            if (menu == none) {
                menu= GUIBuyMenu(KFGUIController(ViewportOwner.GUIController).ActivePage);
                tabControl= menu.c_Tabs;
                i= tabControl.TabIndex(class'GUIBuyMenu'.default.PanelCaption[1]);
                tabControl.ReplaceTab(tabControl.TabStack[i], class'GUIBuyMenu'.default.PanelCaption[1], 
                        "MinSP.PerksTab", None, class'GUIBuyMenu'.default.PanelHint[1], false);

                menu.RemoveComponent(menu.QuickPerkSelect, true);
                menu.QuickPerkSelect.Free();
                qps= QuickPerkSelect(menu.AddComponent("MinSP.QuickPerkSelect"));
                qps.SetPosition(0.008008, 0.011906, 0.316601, 0.082460);
                PerksTab(tabControl.TabStack[i].MyPanel).perksBox= qps.perkSelect;
            }
            return true;
        }
    }
    return false;
}

defaultproperties {
    bActive= true
    bRequiresTick= true

    lobbyMenuClass="MinSP.LobbyMenu"
}

class MSPInteraction extends Interaction;

var string buyMenuClass, lobbyMenuClass;
var GUI.GUITabItem perksGUITab;

event NotifyLevelChange() {
    Master.RemoveInteraction(self);
}

function Tick (float DeltaTime) {
    local MSPLinkedReplicationInfo mspLRepInfo;
    local KFGUIController guiController;

    guiController= KFGUIController(ViewportOwner.GUIController);
    if (guiController != none && guiController.ActivePage != none && 
            ClassIsChildOf(guiController.ActivePage.class, class'KFGui.LobbyMenu')) {
        KFPlayerController(ViewportOwner.Actor).LobbyMenuClassString= lobbyMenuClass;
        ViewportOwner.Actor.ClientCloseMenu(true, true);
        KFPlayerController(ViewportOwner.Actor).ShowLobbyMenu();

        mspLRepInfo= class'MSPLinkedReplicationInfo'.static.findLRI(ViewportOwner.Actor.PlayerReplicationInfo);
        mspLRepInfo.ownerController= KFPlayerController(ViewportOwner.Actor);
        mspLRepInfo.changeRandomPerk();
        bRequiresTick= false;
    }
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta ) {
    local string alias;
    local ShopVolume shop;
    local bool touchingShopVolume;
    local GUITabControl tabControl;
    local GUITabPanel oldPerks;
    local GUIBuyMenu menu;
    local QuickPerkSelect qps;
    local int i;

    alias= ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key));
    if (Action == IST_Press && alias ~= "use" && !KFGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo).bWaveInProgress) {
        foreach ViewportOwner.Actor.Pawn.TouchingActors(class'ShopVolume', shop) {
            touchingShopVolume= true;
            break;
        }
        if (touchingShopVolume) {
            KFPlayerController(ViewportOwner.Actor).ShowBuyMenu("MyTrader", 
               KFHumanPawn(ViewportOwner.Actor.Pawn).MaxCarryWeight);
            menu= GUIBuyMenu(KFGUIController(ViewportOwner.GUIController).ActivePage);
            tabControl= GUIBuyMenu(KFGUIController(ViewportOwner.GUIController).ActivePage).c_Tabs;
            i= tabControl.TabIndex(class'GUIBuyMenu'.default.PanelCaption[1]);
            log("MSPInteraction: index= " $ i);
            oldPerks= tabControl.BorrowPanel(class'GUIBuyMenu'.default.PanelCaption[1]);
            tabControl.TabStack[i].MyPanel= GUITabPanel(menu.AddComponent(perksGUITab.ClassName, True));
            tabControl.TabStack[i].MyPanel.Hide();
            menu.RemoveComponent(oldPerks, True);
            oldPerks.Free();
            menu.RemoveComponent(menu.QuickPerkSelect, true);
            menu.QuickPerkSelect.Free();
            qps= QuickPerkSelect(menu.AddComponent("MinSP.QuickPerkSelect"));
            qps.SetPosition(0.008008, 0.011906, 0.316601, 0.082460);
            PerksTab(tabControl.TabStack[i].MyPanel).perksBox= qps.perkSelect;
            return true;
        }
    }
    return false;
}

defaultproperties {
    bActive= true
    bRequiresTick= true

    buyMenuClass="MinSP.BuyMenu"
    lobbyMenuClass="MinSP.LobbyMenu"

    perksGUITab=(ClassName="MinSP.PerksTab",Caption="MSP Perks",Hint="What's good nyugah")
}

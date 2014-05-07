class MSPInteraction extends Interaction;

var string buyMenuClass, lobbyMenuClass;
var MSPLinkedReplicationInfo mspLRepInfo;

event NotifyLevelChange() {
    Master.RemoveInteraction(self);
}

function Tick (float DeltaTime) {
    local KFGUIController guiController;

    guiController= KFGUIController(ViewportOwner.GUIController);
    if (guiController != none && guiController.ActivePage != none && guiController.ActivePage.class == class'KFGui.LobbyMenu') {
        KFPlayerController(ViewportOwner.Actor).LobbyMenuClassString= lobbyMenuClass;
        ViewportOwner.Actor.ClientCloseMenu(true, true);
        KFPlayerController(ViewportOwner.Actor).ShowLobbyMenu();

        mspLRepInfo= class'MSPLinkedReplicationInfo'.static.findLRI(ViewportOwner.Actor.PlayerReplicationInfo);
        mspLRepInfo.changeRandomPerk();
        bRequiresTick= false;
    }
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta ) {
    local string alias;
    local ShopVolume shop;
    local bool touchingShopVolume;

    alias= ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key));
    if (Action == IST_Press && alias ~= "use" && !KFGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo).bWaveInProgress) {
        foreach ViewportOwner.Actor.Pawn.TouchingActors(class'ShopVolume', shop) {
            touchingShopVolume= true;
            break;
        }
        if (touchingShopVolume && Len(buyMenuClass) > 0) {
            ViewportOwner.Actor.ClientOpenMenu(buyMenuClass,,"MyTrader", string(KFHumanPawn(ViewportOwner.Actor.Pawn).MaxCarryWeight));
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
}

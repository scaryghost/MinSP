class MSPInteraction extends Interaction;

var string lobbyMenuClass;
var MSPLinkedReplicationInfo mspLRepInfo;

function Tick (float DeltaTime) {
    local KFGUIController guiController;
    local int i;

    guiController= KFGUIController(ViewportOwner.GUIController);
    if (guiController != none && guiController.ActivePage != none && guiController.ActivePage.class == class'KFGui.LobbyMenu') {
        KFPlayerController(ViewportOwner.Actor).LobbyMenuClassString= lobbyMenuClass;
        ViewportOwner.Actor.ClientCloseMenu(true, true);
        KFPlayerController(ViewportOwner.Actor).ShowLobbyMenu();

        mspLRepInfo= class'MSPLinkedReplicationInfo'.static.findLRI(ViewportOwner.Actor.PlayerReplicationInfo);
        i= Rand(mspLRepInfo.veterancyTypes.Length);
        KFPlayerController(ViewportOwner.Actor).SelectedVeterancy= mspLRepInfo.veterancyTypes[i];
        ViewportOwner.Actor.ServerMutate("perkchange"@i);
        bRequiresTick= false;
    }
}

defaultproperties {
    bActive= true
    bRequiresTick= true

    lobbyMenuClass="MinSP.LobbyMenu"
}

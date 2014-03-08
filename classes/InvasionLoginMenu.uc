class InvasionLoginMenu extends KFInvasionLoginMenu;

function InitComponent(GUIController MyController, GUIComponent MyComponent) {
    super(UT2k4PlayerLoginMenu).InitComponent(MyController, MyComponent);

    c_Main.RemoveTab(Panels[0].Caption);
    c_Main.ActivateTabByName(Panels[1].Caption, true);
}

defaultproperties {
    Panels(1)=(ClassName="MinSP.MidGamePerksTab",Caption="Perks",Hint="Select your current Perk")
}

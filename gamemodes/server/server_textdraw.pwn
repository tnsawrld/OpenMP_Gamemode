new Text: Server_Name[2];

stock CreateGlobalTextdraw()
{
    Server_Name[0] = TextDrawCreate(302.000, 10.000, "Basic");
    TextDrawLetterSize(Server_Name[0], 0.310, 1.799);
    TextDrawAlignment(Server_Name[0], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Server_Name[0], -1);
    TextDrawSetShadow(Server_Name[0], 1);
    TextDrawSetOutline(Server_Name[0], 1);
    TextDrawBackgroundColour(Server_Name[0], 150);
    TextDrawFont(Server_Name[0], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Server_Name[0], true);

    Server_Name[1] = TextDrawCreate(330.000, 22.000, "Roleplay");
    TextDrawLetterSize(Server_Name[1], 0.310, 1.799);
    TextDrawAlignment(Server_Name[1], TEXT_DRAW_ALIGN_CENTER);
    TextDrawColour(Server_Name[1], 12582911);
    TextDrawSetShadow(Server_Name[1], 100);
    TextDrawSetOutline(Server_Name[1], 1);
    TextDrawBackgroundColour(Server_Name[1], 255);
    TextDrawFont(Server_Name[1], TEXT_DRAW_FONT_1);
    TextDrawSetProportional(Server_Name[1], true);
}
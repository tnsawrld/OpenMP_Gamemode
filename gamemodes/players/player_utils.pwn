stock ShowStats(playerid)
{
    new str[155];
    format(str, sizeof(str), "ID_player\t:\t%d\nUsername\t:\t%s\nID_Database\t:\t%d\nInterior\t:\t%d\nVirtual World\t:\t%d\nSkin\t:\t%d\nMoney\t:\t%d\nLevel\t:\t%d", 
    playerid, g_PlayerData[playerid][pName], g_PlayerData[playerid][pID], 
    g_PlayerData[playerid][pInterior], g_PlayerData[playerid][pVirtual_World], 
    g_PlayerData[playerid][pSkin], g_PlayerData[playerid][pMoney],
    g_PlayerData[playerid][pLevel]);

    return ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Stats Player", str, "Oke", "");
}
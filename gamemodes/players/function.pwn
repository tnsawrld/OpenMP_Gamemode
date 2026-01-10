stock ShowStats(playerid)
{
    new str[155];
    format(str, sizeof(str), "ID_player\t:\t%d\nUsername\t:\t%s\nID_Database\t:\t%d\nInterior\t:\t%d\nVirtual World\t:\t%d\nSkin\t:\t%d\nMoney\t:\t%d\nLevel\t:\t%d", playerid, g_PlayerData[playerid][E_PLAYER_NAME], g_PlayerData[playerid][E_PLAYER_ID], g_PlayerData[playerid][E_PLAYER_INTERIOR], g_PlayerData[playerid][E_PLAYER_VW], g_PlayerData[playerid][E_PLAYER_SKIN], g_PlayerData[playerid][E_PLAYER_MONEY], g_PlayerData[playerid][E_PLAYER_LEVEL]);
    return ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Stats Player", str, "Oke", "");
}
stock ShowStats(playerid)
{
    new str[155], 
        strhead[64],
        client[8];
    if(!g_PlayerData[playerid][isOfficialClient])
        format(client, sizeof(client), "Android");
    else
        format(client, sizeof(client), "PC");
    
    format(strhead, sizeof(strhead), "%s|[%d]", g_PlayerData[playerid][pName], playerid);
    format(str, sizeof(str), "{ffffff}Client\t:\t%s\nID_Database\t:\t%d\nInterior\t:\t%d\nVirtual World\t:\t%d\nSkin\t:\t%d\nMoney\t:\t%d\nLevel\t:\t%d", 
    client, g_PlayerData[playerid][pID], 
    g_PlayerData[playerid][pInterior], g_PlayerData[playerid][pVirtual_World], 
    g_PlayerData[playerid][pSkin], g_PlayerData[playerid][pMoney],
    g_PlayerData[playerid][pLevel]);

    return Dialog_Show(playerid, DialogUnused, DIALOG_STYLE_MSGBOX, strhead, str, "Oke", "");
}

stock ParseBirthDate(playerid, const date[])
{
    new day,
        month,
        year;

    if(sscanf(date, "p</>ddd", day, month, year))
    {
        Dialog_Show(playerid, DialogAge, DIALOG_STYLE_INPUT, "Age", "{ffffff}Kamu memasukan format yang {B82B2B}salah!\n{ffffff}Masukan kembali tanggal lahir dengan format DD/MM/YYYY (16/01/2005)", "Input", "Tutup");
        return 0;
    }

    if(!IsValidDate(day, month, year))
    {
        Dialog_Show(playerid, DialogAge, DIALOG_STYLE_INPUT, "Age", "{ffffff}Kamu memasukan tanggal yang {B82B2B}tidak valid!\n{ffffff}Masukan kembali tanggal lahir dengan format DD/MM/YYYY dan valid!", "Input", "Tutup");
        return 0;
    }

    g_PlayerData[playerid][pBirthDay] = day;
    g_PlayerData[playerid][pBirthMonth] = month;
    g_PlayerData[playerid][pBirthYear] = year;
    printf("Player %s tanggal lahir: %d/%d/%d", g_PlayerData[playerid][pName], g_PlayerData[playerid][pBirthDay], g_PlayerData[playerid][pBirthMonth], g_PlayerData[playerid][pBirthYear]);
    Dialog_Show(playerid, DialogGender, DIALOG_STYLE_LIST, "Gender", "Male\nFemale", "Continue", "");
    return 1;
}

stock IsValidDate(day, month, year)
{
    if(year < 1900 || year > 2100) return 0;
    if(month < 1 || month > 12) return 0;
    if(day < 1) return 0;

    new daysInMonth[] = {
    31,28,31,30,31,30,31,31,30,31,30,31};

    return day <= daysInMonth[month - 1];
}

stock IsValidRPName(const name[])
{
    new len = strlen(name);

    if(len < 3 || len > MAX_PLAYER_NAME)
        return 0;

    new underscorePos = strfind(name, "_");
    if(underscorePos == -1)
        return 0;

    if(underscorePos == 0 || underscorePos == len - 1)
        return 0;

    if(name[0] < 'A' || name[0] > 'Z')
        return 0;

    if(name[underscorePos + 1] < 'A' || name[underscorePos + 1] > 'Z')
        return 0;

    for(new i = 0; i < len; i++)
    {
        if(name[i] == '_') continue;

        if(name[i] < 'a' || name[i] > 'z')
        {
            if(name[i] < 'A' || name[i] > 'Z')
                return 0;
        }
    }
    return 1;
}

CreateSetupCharacter(playerid)
{
    if(!g_PlayerData[playerid][isLogin]) return SendError(playerid, "Kamu tidak memiliki akes untuk melakukan ini!");

    SetSpawnInfo(playerid, NO_TEAM, g_PlayerData[playerid][pSkin], DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, DEFAULT_POS_A, WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
    GivePlayerMoneyEx(playerid, 5000);
    SpawnPlayer(playerid);
    return 1;
}

stock UpdateDataPlayer(playerid)
{
	if(!g_PlayerData[playerid][isLogin]) return 1;

	GetPlayerPos(playerid, g_PlayerData[playerid][pPos][0], g_PlayerData[playerid][pPos][1], g_PlayerData[playerid][pPos][2]);
	GetPlayerFacingAngle(playerid, g_PlayerData[playerid][pPos][3]);
	g_PlayerData[playerid][pInterior] = GetPlayerInterior(playerid);
	g_PlayerData[playerid][pVirtual_World] = GetPlayerVirtualWorld(playerid);
	g_PlayerData[playerid][pSkin] = GetPlayerSkin(playerid);
	g_PlayerData[playerid][pMoney] = GetPlayerMoney(playerid);
	g_PlayerData[playerid][pLevel] = GetPlayerScore(playerid);

	new query[500];
	mysql_format(g_SQL, query, sizeof(query), "UPDATE player SET pos_x = %f, pos_y = %f, pos_z = %f, pos_a = %f, interior = %d, virtual_world = %d, skin = %d, money = %d, level = %d WHERE id = %d LIMIT 1",
	g_PlayerData[playerid][pPos][0], g_PlayerData[playerid][pPos][1], g_PlayerData[playerid][pPos][2], 
	g_PlayerData[playerid][pPos][3], g_PlayerData[playerid][pInterior], g_PlayerData[playerid][pVirtual_World], 
	g_PlayerData[playerid][pSkin], g_PlayerData[playerid][pMoney], g_PlayerData[playerid][pLevel],
	g_PlayerData[playerid][pID]);

	mysql_tquery(g_SQL, query);
	printf("[MYSQL] Data player id %d berhasil disimpan", g_PlayerData[playerid][pID]);
	return 1;
}
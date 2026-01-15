GetPlayerNameEx(playerid)
{	
	GetPlayerName(playerid, g_PlayerData[playerid][pName], MAX_PLAYER_NAME);
	return g_PlayerData[playerid][pName];
}

ResetValueVariable(playerid)
{
	g_PlayerData[playerid][pID] = -1;
	g_PlayerData[playerid][pName] = EOS;
	g_PlayerData[playerid][pSkin] = 0;
	g_PlayerData[playerid][pMoney] = 0;
	g_PlayerData[playerid][pLevel] = 0;
	g_PlayerData[playerid][pPos][0] = 0.0;
	g_PlayerData[playerid][pPos][1] = 0.0;
	g_PlayerData[playerid][pPos][2] = 0.0;
	g_PlayerData[playerid][pPos][3] = 0.0;
	g_PlayerData[playerid][pBirthDay] = 0;
	g_PlayerData[playerid][pBirthMonth] = 0;
	g_PlayerData[playerid][pBirthYear] = 0;
	g_PlayerData[playerid][pGender] = -1;

	// bagian login register
	g_PlayerData[playerid][isLogin] = false;
	g_PlayerData[playerid][pCacheID] = MYSQL_INVALID_CACHE;
	g_PlayerData[playerid][pLoginAttempt] = 0;
	g_PlayerData[playerid][isOfficialClient] = false;

	print("[PLAYER] Variable berhasil direset");
	return 1;
}

GivePlayerMoneyEx(playerid, ammount)
{
	printf("Uang sebelum ditambah %d", g_PlayerData[playerid][pMoney]);
	GivePlayerMoney(playerid, ammount);
	g_PlayerData[playerid][pMoney] += ammount;
	printf("Uang berhasil ditambah %d", g_PlayerData[playerid][pMoney]);
	return 1;
}

KickEx(playerid)
{
	SetTimerEx("_KickDelay", 2000, false, "i", playerid);
	print("Function KickEx sedang berjalan selama 5 detik");
	return 1;
}

forward _KickDelay(playerid);
public _KickDelay(playerid) 
{
	print("Function _KickDelay siap eksekusi kick");
	Kick(playerid);
	return 1;
}

stock ConnectToDatabase(const host[], const user[], const pass[], const db[])
{
	g_SQL = mysql_connect(host, user, pass, db);

	if(g_SQL == MYSQL_INVALID_HANDLE || mysql_errno(g_SQL) != 0)
	{
		print("[MYSQL] Koneksi gagal!");
		SendRconCommand("exit");
	}

	print("[MYSQL] Berhasil terhubung");
}


// unused Dialog
Dialog:DialogUnused(playerid, response, listitem, inputtext[])
{
	if(response) return 1;
	return 1;
}
GetPlayerNameEx(playerid)
{	
	GetPlayerName(playerid, g_PlayerData[playerid][E_PLAYER_NAME], MAX_PLAYER_NAME);
	return g_PlayerData[playerid][E_PLAYER_NAME];
}

ResetValueVariable(playerid)
{
	g_PlayerData[playerid][E_PLAYER_ID] = -1;
	g_PlayerData[playerid][E_PLAYER_NAME] = EOS;
	g_PlayerData[playerid][E_PLAYER_SKIN] = 0;
	g_PlayerData[playerid][E_PLAYER_MONEY] = 0;
	g_PlayerData[playerid][E_PLAYER_LEVEL] = 0;
	g_PlayerData[playerid][E_PLAYER_POS][0] = 0.0;
	g_PlayerData[playerid][E_PLAYER_POS][1] = 0.0;
	g_PlayerData[playerid][E_PLAYER_POS][2] = 0.0;
	g_PlayerData[playerid][E_PLAYER_POS][3] = 0.0;

	// bagian login register
	g_PlayerData[playerid][E_IS_LOGIN] = false;
	g_PlayerData[playerid][E_CACHE_ID] = MYSQL_INVALID_CACHE;
	g_PlayerData[playerid][E_LOGIN_ATTEMPTS] = 0;

	print("[PLAYER] Variable berhasil direset");
	return 1;
}

GivePlayerMoneyEx(playerid, ammount)
{
	printf("Uang sebelum ditambah %d", g_PlayerData[playerid][E_PLAYER_MONEY]);
	GivePlayerMoney(playerid, ammount);
	g_PlayerData[playerid][E_PLAYER_MONEY] += ammount;
	printf("Uang berhasil ditambah %d", g_PlayerData[playerid][E_PLAYER_MONEY]);
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
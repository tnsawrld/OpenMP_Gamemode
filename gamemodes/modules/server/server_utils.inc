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

stock StartTickCount(playerid)
{
	g_TickCount[playerid] = GetTickCount();
	return 1;
}

stock CalculateTickCount(playerid, const reason[] = "")
{
	new loadtime = GetTickCount() - g_TickCount[playerid];

	new message[128];
	format(message, sizeof(message), "[LOAD TIME] %s: %d ms", reason, loadtime);

	SendClientMessage(playerid, COLOR_SERVER, message);
    printf("Player %d load time: %d ms (%s)", playerid, loadtime, reason);
	return loadtime;
}

stock RandomEx(minValue, maxValue)
{
	if(minValue == maxValue)
		return minValue;

	if(minValue > maxValue)
	{
		new temp = minValue;
		minValue = maxValue;
		maxValue = temp;
	}

	return random(maxValue - minValue + 1) + minValue;
}
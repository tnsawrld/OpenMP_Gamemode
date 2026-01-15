stock AccountCheck(playerid)
{
    g_MysqlRaceCheck[playerid]++;
    printf("RACE CHECK %d", g_MysqlRaceCheck[playerid]);

	new query[128];
	mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM accounts WHERE username = '%e' LIMIT 1", g_PlayerData[playerid][pName]);
	mysql_tquery(g_SQL, query, "OnAccountLoaded", "dd", playerid, g_MysqlRaceCheck[playerid]);
    return 1;
}

stock UpdateDataPlayer(playerid, reason)
{
	if(!g_PlayerData[playerid][isLogin]) return 0;

	if(reason == 0 || reason == 1|| reason == 2)
	{
		GetPlayerPos(playerid, g_PlayerData[playerid][pPos][0], g_PlayerData[playerid][pPos][1], g_PlayerData[playerid][pPos][2]);
		GetPlayerFacingAngle(playerid, g_PlayerData[playerid][pPos][3]);
		g_PlayerData[playerid][pInterior] = GetPlayerInterior(playerid);
		g_PlayerData[playerid][pVirtual_World] = GetPlayerVirtualWorld(playerid);
		g_PlayerData[playerid][pSkin] = GetPlayerSkin(playerid);
		g_PlayerData[playerid][pMoney] = GetPlayerMoney(playerid);
		g_PlayerData[playerid][pLevel] = GetPlayerScore(playerid);
	}

	new query[500];
	mysql_format(g_SQL, query, sizeof(query), "UPDATE accounts SET birth_day = '%d', birth_month = '%d', birth_year = '%d', gender = '%d', pos_x = %f, pos_y = %f, pos_z = %f, pos_a = %f, interior = %d, virtual_world = %d, skin = %d, money = %d, level = %d WHERE id = %d LIMIT 1", 
	g_PlayerData[playerid][pBirthDay], g_PlayerData[playerid][pBirthMonth], g_PlayerData[playerid][pBirthYear], g_PlayerData[playerid][pGender],
	g_PlayerData[playerid][pPos][0], g_PlayerData[playerid][pPos][1], g_PlayerData[playerid][pPos][2], 
	g_PlayerData[playerid][pPos][3], g_PlayerData[playerid][pInterior], g_PlayerData[playerid][pVirtual_World], 
	g_PlayerData[playerid][pSkin], g_PlayerData[playerid][pMoney], g_PlayerData[playerid][pLevel],
	g_PlayerData[playerid][pID]);
	mysql_tquery(g_SQL, query);
	printf("[MYSQL] Data player id %d berhasil disimpan", g_PlayerData[playerid][pID]);
	return 1;
}

stock LoadDataPlayer(playerid)
{
	cache_get_value_name_int(0, "id", g_PlayerData[playerid][pID]);
	cache_get_value_name_int(0, "birth_day", g_PlayerData[playerid][pBirthDay]);
	cache_get_value_name_int(0, "birth_month", g_PlayerData[playerid][pBirthMonth]);
	cache_get_value_name_int(0, "birth_year", g_PlayerData[playerid][pBirthYear]);
	cache_get_value_name_int(0, "gender", g_PlayerData[playerid][pGender]);

	cache_get_value_name_float(0, "pos_x", g_PlayerData[playerid][pPos][0]);
	cache_get_value_name_float(0, "pos_y", g_PlayerData[playerid][pPos][1]);
	cache_get_value_name_float(0, "pos_z", g_PlayerData[playerid][pPos][2]);
	cache_get_value_name_float(0, "pos_a", g_PlayerData[playerid][pPos][3]);

	cache_get_value_name_int(0, "interior", g_PlayerData[playerid][pInterior]);
	cache_get_value_name_int(0, "virtual_world", g_PlayerData[playerid][pVirtual_World]);
	cache_get_value_name_int(0, "skin", g_PlayerData[playerid][pSkin]);
	cache_get_value_name_int(0, "money", g_PlayerData[playerid][pMoney]);
	cache_get_value_name_int(0, "level", g_PlayerData[playerid][pLevel]);
	return 1;
}

forward OnAccountLoaded(playerid, race_check);
public OnAccountLoaded(playerid, race_check)
{
	if(race_check != g_MysqlRaceCheck[playerid]) return KickEx(playerid);

	new string[128];
	if(cache_num_rows() > 0)
	{
		cache_get_value(0, "password", g_PlayerData[playerid][pPassword]);

        g_PlayerData[playerid][pCacheID] = cache_save();

        format(string, sizeof(string), "{ffffff}Akun {04d400}%s {ffffff}terdaftar dalam server.\nLogin ke akun kamu dengan memasukan password dibawah:", g_PlayerData[playerid][pName]);
        Dialog_Show(playerid, DialogLogin, DIALOG_STYLE_PASSWORD, "Login", string, "Login", "Tutup");
	}
	else
	{
		format(string, sizeof(string), "{ffffff}Halo {04d400}%s!, {ffffff}akun kamu belum terdaftar diserver kami.\nSilahkan buat password untuk melanjutkan registrasi.", g_PlayerData[playerid][pName]);
		Dialog_Show(playerid, DialogRegister, DIALOG_STYLE_PASSWORD, "Register", string, "Register", "Tutup");
	}
	return 1;
}

forward OnPasswordHashed(playerid, hash_id);
public OnPasswordHashed(playerid, hash_id)
{
	// new hashed_password[BCRYPT_HASH_LENGTH];
	bcrypt_get_hash(g_PlayerData[playerid][pPassword]);

	// new query[144];
	// mysql_format(g_SQL, query, sizeof(query), "INSERT INTO accounts (username, password) VALUES ('%e', '%s')", g_PlayerData[playerid][pName], hashed_password);
	// mysql_tquery(g_SQL, query, "OnAccountRegistered", "d", playerid);
	printf("Print pass : %s", g_PlayerData[playerid][pPassword]);
	Dialog_Show(playerid, DialogAge, DIALOG_STYLE_INPUT, "Age", "{ffffff}Masukan tanggal lahir, {04d400}format: DD/MM/YYYY", "Input", "Tutup");
	return 1;
}

forward OnPasswordVerify(playerid, bool:success);
public OnPasswordVerify(playerid, bool:success)
{
	if(success)
	{
		Dialog_Show(playerid, DialogUnused, DIALOG_STYLE_MSGBOX, "Login", "{04d400}Kamu berhasil login kedalam akun, Data akan segera diload!", "Oke", "");

		cache_set_active(g_PlayerData[playerid][pCacheID]);

		LoadDataPlayer(playerid);

		cache_delete(g_PlayerData[playerid][pCacheID]);
		g_PlayerData[playerid][pCacheID] = MYSQL_INVALID_CACHE;

		g_PlayerData[playerid][isLogin] = true;
		SetSpawnInfo(playerid, NO_TEAM, g_PlayerData[playerid][pSkin], g_PlayerData[playerid][pPos][0],g_PlayerData[playerid][pPos][1], g_PlayerData[playerid][pPos][2], g_PlayerData[playerid][pPos][3], WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
		SpawnPlayer(playerid); 
		SetPlayerInterior(playerid, g_PlayerData[playerid][pInterior]);
		SetPlayerVirtualWorld(playerid, g_PlayerData[playerid][pVirtual_World]);
		GivePlayerMoney(playerid, g_PlayerData[playerid][pMoney]);
		SetPlayerScore(playerid, g_PlayerData[playerid][pLevel]);
	}
	else
	{
		g_PlayerData[playerid][pLoginAttempt]++;
		if(g_PlayerData[playerid][pLoginAttempt] >= 3)
		{
			Dialog_Show(playerid, DialogUnused, DIALOG_STYLE_MSGBOX, "Login",  "{B82B2B}Kamu dikick karena salah memasukan password (3x)!", "Oke", "");
			KickEx(playerid);
		}
		else
			Dialog_Show(playerid, DialogLogin, DIALOG_STYLE_PASSWORD, "Login", "{B82B2B}Kamu salah memasukan password!\n{ffffff}Ketik kembali password kamu dengan benar: ", "Oke", "");
	}
	return 1;
}

forward OnAccountRegistered(playerid);
public OnAccountRegistered(playerid)
{
	g_PlayerData[playerid][pID] = cache_insert_id();

	Dialog_Show(playerid, DialogUnused, DIALOG_STYLE_MSGBOX, "Register", "{04d400}Akun berhasil didaftarkan, Kamu otomatis login kedalam akun", "Oke", "");

	g_PlayerData[playerid][isLogin] = true;

	g_PlayerData[playerid][pPos][0] = DEFAULT_POS_X;
	g_PlayerData[playerid][pPos][1] = DEFAULT_POS_Y;
	g_PlayerData[playerid][pPos][2] = DEFAULT_POS_Z;
	g_PlayerData[playerid][pPos][3] = DEFAULT_POS_A;

	SetSpawnInfo(playerid, NO_TEAM, g_PlayerData[playerid][pSkin], g_PlayerData[playerid][pPos][0], g_PlayerData[playerid][pPos][1], g_PlayerData[playerid][pPos][2], g_PlayerData[playerid][pPos][3], WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
	SpawnPlayer(playerid);
	SendClientMessage(playerid, COLOR_SERVER, "SERVER: {ffffff}Selamat datang {04d400}%s!", g_PlayerData[playerid][pName]);
	return 1;
}

Dialog:DialogRegister(playerid, response, listitem, inputtext[])
{
	if(!response) return KickEx(playerid);

	if(strlen(inputtext) <= 5) return Dialog_Show(playerid, DialogRegister, DIALOG_STYLE_PASSWORD, "Registrasi", "{B82B2B}Password harus lebih panjang dari 5 karakter\n{ffffff}Tolong buat password kembali sesuai ketentuan", "Register", "Tutup");

	bcrypt_hash(playerid, "OnPasswordHashed", inputtext, BCRYPT_COST);
	return 1;
}

Dialog:DialogLogin(playerid, response, listitem, inputtext[])
{
	if(!response) return KickEx(playerid);

	bcrypt_verify(playerid, "OnPasswordVerify", inputtext, g_PlayerData[playerid][pPassword]);
	return 1;
}

Dialog:DialogAge(playerid, response, listitem, inputtext[])
{
	if(!response) return KickEx(playerid);

	ParseBirthDate(playerid, inputtext);
	return 1;
}

Dialog:DialogGender(playerid, response, listitem, inputtext[])
{
	if(!response) return KickEx(playerid);

	switch(listitem)
	{
		case 0:
		{
			ShowModelSelectionMenu(playerid, m_SkinSpawn, "Select Skin");
			g_PlayerData[playerid][pGender] = 0;
		}
		case 1:
		{
			ShowModelSelectionMenu(playerid, f_SkinSpawn, "Select Skin");
			g_PlayerData[playerid][pGender] = 1;
		}
	}
	return 1;
}
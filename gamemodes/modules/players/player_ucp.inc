
stock AccountCheck(playerid)
{
    g_MysqlRaceCheck[playerid]++;
    printf("RACE CHECK %d", g_MysqlRaceCheck[playerid]);

    GetPlayerName(playerid, g_PlayerData[playerid][pUCP], MAX_PLAYER_NAME);

	new query[128];
	mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM ucp WHERE ucp_name = '%e' LIMIT 1", g_PlayerData[playerid][pUCP]);
	mysql_tquery(g_SQL, query, "OnUCPChecked", "dd", playerid, g_MysqlRaceCheck[playerid]);
    return 1;
}

Function::OnUCPChecked(playerid, race_check)
{
	if(race_check != g_MysqlRaceCheck[playerid]) return KickEx(playerid);

	new string[180];
	if(cache_num_rows() > 0)
	{
		cache_get_value(0, "password", g_PlayerData[playerid][pPassword]);

        format(string, sizeof(string), "{ffffff}Username: {04d400}%s\n{ffffff}Status: {04d400}Terdaftar\n{ffffff}Akun UCP kamu sudah terdaftar kedalam server.\nLogin ke akun kamu dengan memasukan password dibawah:", g_PlayerData[playerid][pUCP]);
        Dialog_Show(playerid, DialogLogin, DIALOG_STYLE_PASSWORD, "Login", string, "Login", "Close");
	}
	else
	{
		format(string, sizeof(string), "{ffffff}Username: {04d400}%s\n{ffffff} Status: {bd0000}Tidak terdaftar\n{ffffff}Akun UCP kamu belum terdaftar didalam server.\nSilahkan buat password untuk melanjutkan registrasi.", g_PlayerData[playerid][pUCP]);
		Dialog_Show(playerid, DialogRegister, DIALOG_STYLE_PASSWORD, "Register", string, "Register", "Close");
	}
	return 1;
}

Function::OnPasswordHashed(playerid, hash_id)
{
	bcrypt_get_hash(g_PlayerData[playerid][pPassword], BCRYPT_HASH_LENGTH);

    new query[150];
    mysql_format(g_SQL, query, sizeof(query), "INSERT INTO ucp (ucp_name, password) VALUES ('%e', '%s')", g_PlayerData[playerid][pUCP], g_PlayerData[playerid][pPassword]);
    mysql_tquery(g_SQL, query);
	return 1;
}


Function::OnPasswordVerify(playerid, bool:success)
{
    new str[185];
	if(success)
	{
        CheckUserCharacter(playerid);
	}
	else
	{
		g_PlayerData[playerid][pLoginAttempt]++;

		if(g_PlayerData[playerid][pLoginAttempt] >= 3)
		{
            format(str, sizeof(str), "{ffffff}Username: {04d400}%s\n{ffffff}Status: {04d400}Terdaftar\n{ffffff}Kamu dikick karena salah memasukan password sebanyak 3X!\n{FBFF00}Lupa password? Ajukan reset password pada moderator di discord kammi", g_PlayerData[playerid][pUCP]);
			Dialog_Show(playerid, DialogUnused, DIALOG_STYLE_MSGBOX, "Failed Login", str, "Oke", "");
			KickEx(playerid);
		}
		else
        {
            format(str, sizeof(str), "{ffffff}Username: {04d400}%s\n{ffffff}Status: {04d400}Terdaftar\n{FBFF00}Kamu salah memasukan password! kesempatan kamu %d/3.\n{ffffff}Isi kembali kolom password dengan benar:", g_PlayerData[playerid][pUCP], g_PlayerData[playerid][pLoginAttempt]);
            Dialog_Show(playerid, DialogLogin, DIALOG_STYLE_PASSWORD, "Login", str, "Input", "Close");
        }
	}
	return 1;
}

stock CheckUserCharacter(playerid)
{
    g_MysqlRaceCheck[playerid]++;

    new query[128];
    mysql_format(g_SQL, query, sizeof(query), "SELECT username FROM player WHERE ucp = '%s' LIMIT %d", g_PlayerData[playerid][pUCP], MAX_CHARS);
    mysql_tquery(g_SQL, query, "OnCharacterLoaded", "dd", playerid, g_MysqlRaceCheck[playerid]);
    return 1;
}

Function::OnCharacterLoaded(playerid, race_check)
{
    if(race_check != g_MysqlRaceCheck[playerid]) return KickEx(playerid);

    new rows = cache_num_rows();

    Forex(i, MAX_CHARS)
    {
        PlayerCharacter[playerid][i][0] = EOS;
        print("eos");
    }

    Forex(k, rows)
    {
        cache_get_value_name(k, "username", PlayerCharacter[playerid][k]);
        print("name");
    }
    ShowCharacterList(playerid);
    return 1;
}

stock ShowCharacterList(playerid)
{
    new name[268],
        str[128],
        count;

    for(new i; i < MAX_CHARS; i++)
    {
        if(PlayerCharacter[playerid][i][0] != EOS)
        {
            format(str, sizeof(str), "%s\n", PlayerCharacter[playerid][i]);
            strcat(name, str);
            count++;
        }
    }

    if(count < MAX_CHARS) strcat(name, "+ New Character");
    
    Dialog_Show(playerid, DialogListChar, DIALOG_STYLE_LIST, "List Character", name, "Choose", "Close");
    return 1;
}

Function::OnInsertCharacter(playerid)
{
    new rows = cache_num_rows(),
        query[128];
    new Cache: sikat;

    if(rows > 0)
        return Dialog_Show(playerid, DialogCreateChar, DIALOG_STYLE_INPUT, "Create New Character", "{bd0000}Nama sudah pernah dipakai! {ffffff}Gunakan nama lain\nMasukan nama :", "Input", "");
    
    mysql_format(g_SQL, query, sizeof(query), "INSERT INTO player (username, ucp) VALUES ('%e', '%e')", g_PlayerData[playerid][pName], g_PlayerData[playerid][pUCP]);

    sikat = mysql_query(g_SQL, query);
    g_PlayerData[playerid][pID] = cache_insert_id();
    cache_delete(sikat);

    SetPlayerName(playerid, g_PlayerData[playerid][pName]);

    g_PlayerData[playerid][isLogin] = true;
    CreateSetupCharacter(playerid);
    return 1;
}

Function::OnCharacterDataLoaded(playerid)
{
    CalculateTickCount(playerid, "Load Character");

	cache_get_value_name_int(0, "id", g_PlayerData[playerid][pID]);
    printf("ID %d", g_PlayerData[playerid][pID]);
    if(g_PlayerData[playerid][pID] < 1)
    {
        SendError(playerid, "Akun ini tidak terdaftar dalam database");
        KickEx(playerid);
        return 1;
    }

	cache_get_value_name_float(0, "pos_x", g_PlayerData[playerid][pPos][0]);
	cache_get_value_name_float(0, "pos_y", g_PlayerData[playerid][pPos][1]);
	cache_get_value_name_float(0, "pos_z", g_PlayerData[playerid][pPos][2]);
	cache_get_value_name_float(0, "pos_a", g_PlayerData[playerid][pPos][3]);

	cache_get_value_name_int(0, "interior", g_PlayerData[playerid][pInterior]);
	cache_get_value_name_int(0, "virtual_world", g_PlayerData[playerid][pVirtual_World]);
	cache_get_value_name_int(0, "skin", g_PlayerData[playerid][pSkin]);
	cache_get_value_name_int(0, "money", g_PlayerData[playerid][pMoney]);
	cache_get_value_name_int(0, "level", g_PlayerData[playerid][pLevel]);

    g_PlayerData[playerid][isLogin] = true;
    SetSpawnInfo(playerid, NO_TEAM, g_PlayerData[playerid][pSkin], g_PlayerData[playerid][pPos][0], g_PlayerData[playerid][pPos][1], g_PlayerData[playerid][pPos][2], g_PlayerData[playerid][pPos][3], WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
    SpawnPlayer(playerid);
    GetPlayerNameEx(playerid);
    
    SetPlayerInterior(playerid, g_PlayerData[playerid][pInterior]);
    SetPlayerVirtualWorld(playerid, g_PlayerData[playerid][pVirtual_World]);
    GivePlayerMoney(playerid, g_PlayerData[playerid][pMoney]);
    SetPlayerScore(playerid, g_PlayerData[playerid][pLevel]);
	return 1;
}
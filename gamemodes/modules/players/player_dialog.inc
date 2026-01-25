Dialog:DialogRegister(playerid, response, listitem, inputtext[])
{
	if(!response) return KickEx(playerid);
    new string[180];

	if(strlen(inputtext) <= 5)
    {
        format(string, sizeof(string), "{ffffff}Username: {04d400}%s\n{ffffff}Status: {bd0000}Tidak terdaftar\n{ffffff}Password harus memiliki panjang minimal 5 karakter.\nnSilahkan buat password kembali untuk melanjutkan registrasi:", g_PlayerData[playerid][pUCP]);
        return Dialog_Show(playerid, DialogRegister, DIALOG_STYLE_PASSWORD, "Registrasi", string, "Register", "Close");
    }
	bcrypt_hash(playerid, "OnPasswordHashed", inputtext, BCRYPT_COST);

    format(string, sizeof(string), "{ffffff}Username: {04d400}%s\n{ffffff}Status: {04d400}Terdaftar\n{ffffff}Akun UCP kamu sudah terdaftar kedalam server.\nLogin ke akun kamu dengan memasukan password dibawah:", g_PlayerData[playerid][pUCP]);
    Dialog_Show(playerid, DialogLogin, DIALOG_STYLE_PASSWORD, "Login", string, "Login", "Close");
	return 1;
}

Dialog:DialogLogin(playerid, response, listitem, inputtext[])
{
	if(!response) return KickEx(playerid);
	bcrypt_verify(playerid, "OnPasswordVerify", inputtext, g_PlayerData[playerid][pPassword]);
	return 1;
}

Dialog:DialogVerifyCode(playerid, response, listitem, inputtext[])
{
    if(!response) return KickEx(playerid);
    new string[180];

    if(strval(inputtext) == g_PlayerData[playerid][pVerifyCode])
    {
        format(string, sizeof(string), "{ffffff}Username: {04d400}%s\n{ffffff} Status: {bd0000}Tidak terdaftar\n{ffffff}Silahkan buat password untuk melanjutkan proses registrasi.", g_PlayerData[playerid][pUCP]);
        Dialog_Show(playerid, DialogRegister, DIALOG_STYLE_PASSWORD, "Register", string, "Register", "Close");
    }
    else
    {
        format(string, sizeof(string), "{ffffff}Username: {04d400}%s\n{ffffff} Status: {bd0000}Tidak terdaftar\n{ffffff}Kode verifikasi tidak sesuai! silahkan coba lagi!.", g_PlayerData[playerid][pUCP]);
        Dialog_Show(playerid, DialogUnused, DIALOG_STYLE_MSGBOX, "UCP", string, "Close", "");
    }
    return 1;
}

Dialog:DialogListChar(playerid, response, listitem, inputtext[])
{
	if(!response) return KickEx(playerid);
	new count;
    Forex(i, listitem)
    {
        count++;
    }
    printf("Ditemukan %d listitem", count);
    if(PlayerCharacter[playerid][listitem][0] == EOS)
        return Dialog_Show(playerid, DialogCreateChar, DIALOG_STYLE_INPUT, "Create New Character", "{ffffff}Buat nama karakter (Contoh : John_Doe)\nMasukan nama dibawah:", "Input", "");

    g_PlayerData[playerid][pCharacter] = listitem;
    SetPlayerName(playerid, PlayerCharacter[playerid][listitem]);

    StartTickCount(playerid);
    new query[128];
    mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM player WHERE username = '%e' LIMIT 1", PlayerCharacter[playerid][g_PlayerData[playerid][pCharacter]]);
    mysql_tquery(g_SQL, query, "OnCharacterDataLoaded", "d", playerid);
	return 1;
}

Dialog:DialogCreateChar(playerid, response, listitem, inputtext[])
{
    if(!response) return KickEx(playerid);

    if(!IsValidRPName(inputtext))
        return Dialog_Show(playerid, DialogCreateChar, DIALOG_STYLE_INPUT, "Create New Character", "{bd0000}Format salah (Firstname_Lastname)\n{ffffff}Masukan nama dibawah :", "Input", "");
    
    format(g_PlayerData[playerid][pName], MAX_PLAYER_NAME, inputtext);
    g_MysqlRaceCheck[playerid]++;
    new query[128];
    mysql_format(g_SQL, query, sizeof(query), "SELECT username FROM player WHERE username = '%e' LIMIT 1", g_PlayerData[playerid][pName]);
    mysql_tquery(g_SQL, query, "OnUsernameChecked", "dsd", playerid, g_PlayerData[playerid][pName], g_MysqlRaceCheck[playerid]);
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
    if(!response) return 1;
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

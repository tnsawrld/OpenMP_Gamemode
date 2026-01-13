CMD:cekuang(playerid)
{
    SendClientMessage(playerid, COLOR_WHITE, "Uang player sekarang adalah %d", g_PlayerData[playerid][pMoney]);
    return 1;
}
CMD:addmoney(playerid, params[])
{
    new targetId, 
        amountMoney;

    if(sscanf(params, "ui", targetId, amountMoney)) 
        return SendClientMessage(playerid, COLOR_USAGE, "USAGE: {ffffff}/addmoney <id> <jumlah>");

    if(!IsPlayerConnected(targetId))
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Player tidak terkoneksi kedalam server!");

    if(amountMoney < 0 || amountMoney > 10000000) 
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Jumlah uang tidak boleh kurang 0 atau lebih dari 10000000");

    GivePlayerMoneyEx(targetId, amountMoney);
    // info untuk player
    SendClientMessage(playerid, COLOR_SUCCESS, "SUCCESS: {ffffff}Kamu berhasil menambah uang dari %s sebanyak %d", g_PlayerData[targetId][pName], amountMoney);
    // info untuk target 
    SendClientMessage(targetId, COLOR_INFO, "INFO: {ffffff}Kamu mendapatkan uang dari %s sebanyak %d", g_PlayerData[playerid][pName], amountMoney);
    return 1;
}

CMD:kick(playerid, params[])
{
    new targetId,
        reasonKick[64];

    if(sscanf(params, "us[64]", targetId, reasonKick)) 
        return SendClientMessage(playerid, COLOR_USAGE, "USAGE: {ffffff}/kick <id> <alasan>");

    if(!IsPlayerConnected(targetId))
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Player tidak terkoneksi kedalam server");

    KickEx(targetId);
    // info untuk player
    SendClientMessage(playerid, COLOR_SUCCESS, "SUCCESS: {ffffff}Kamu telah menendang %s keluar server dengan alasan %s", g_PlayerData[targetId][pName], reasonKick);

    // info untuk target
    SendClientMessage(targetId, COLOR_INFO, "INFO: {ffffff}Kamu telah ditendang keluar server oleh %s dengan alasan %s", g_PlayerData[playerid][pName], reasonKick);
    // printf("Player id %d telah dikick dari server dengan alasan %s", targetId, reasonKick);
    return 1;
}

CMD:sethp(playerid, params[])
{
    new targetId, 
        Float:healthPlayer;

    if(sscanf(params, "uf", targetId, healthPlayer)) 
        return SendClientMessage(playerid, COLOR_USAGE, "USAGE: {ffffff}/sethp <id> <jumlah>");

    if(!IsPlayerConnected(targetId)) 
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Player tidak terkoneksi kedalam server");

    if(healthPlayer > 100.00 || healthPlayer < 0) 
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Health tidak bisa kurang dari 0 atau lebih dari 100!");

    SetPlayerHealth(targetId, healthPlayer);
    // info untuk player
    SendClientMessage(playerid, COLOR_SUCCESS, "SUCCESS: {ffffff}Kamu telah mengubah health dari %s sebanyak %.2f", g_PlayerData[targetId][pName], healthPlayer);

    // info untuk target
    SendClientMessage(targetId, COLOR_INFO, "INFO: {ffffff}Health kamu telah diubah oleh %s sebanyak %.2f", g_PlayerData[playerid][pName], healthPlayer);
    return 1;
}

CMD:setarmor(playerid, params[])
{
    new targetId,
        Float:amountArmour;

    if(sscanf(params, "uf", targetId, amountArmour))
        return SendClientMessage(playerid, COLOR_USAGE, "USAGE: {ffffff}/setarmor <id> <jumlah>");

    if(!IsPlayerConnected(targetId))
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Player tidak terkoneksi kedalam server");

    if(amountArmour < 0 || amountArmour > 100.00) 
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Armor tidak bisa kurang dari 0 atau lebih dari 100!");
    
    SetPlayerArmour(targetId, amountArmour);
    // info untuk player
    SendClientMessage(playerid, COLOR_SUCCESS, "SUCCESS: {ffffff}Kamu telah mengubah armor dari %s sebanyak %.2f", g_PlayerData[targetId][pName], amountArmour);

    // info untuk target
    SendClientMessage(targetId, COLOR_INFO, "INFO: {ffffff}Armor kamu telah diubah oleh %s sebanyak %.2f", g_PlayerData[playerid][pName], amountArmour);
    return 1;
}

CMD:gotopos(playerid, params[])
{
    new Float:posX,
        Float:posY,
        Float:posZ;

    if(sscanf(params, "fff", posX, posY, posZ))
        return SendClientMessage(playerid, COLOR_USAGE, "USAGE: {ffffff}/gotopos <X> <Y> <Z>");

    SetPlayerPos(playerid, posX, posY, posZ);
    SendClientMessage(playerid, COLOR_SERVER, "SERVER: {ffffff}Anda telah teleport ke koordinat X:%.4f Y:%.4f Z:%.4f", posX, posY, posZ);
    return 1;
}

CMD:find(playerid, params[])
{
    new targetId,
        Float:posX,
        Float:posY,
        Float:posZ;

    if(sscanf(params, "u", targetId))
        return SendClientMessage(playerid, COLOR_USAGE, "USAGE: {ffffff}/find <id/player>");

    if(!IsPlayerConnected(targetId))
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Player tidak terkoneksi kedalam server");

    GetPlayerPos(targetId, posX, posY, posZ);
    g_CP[playerid] = 1;
    SetPlayerCheckpoint(playerid, posX, posY, posZ, 2);
    SendClientMessage(playerid, COLOR_SERVER, "SERVER: {ffffff}Pemain sudah tertandai dimap!");
    return 1;
}

CMD:disablecp(playerid)
{
    g_CP[playerid] = 0;
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, COLOR_INFO, "INFO: {ffffff}Anda berhasil mematikan checkpoint");
    return 1;
}

CMD:tes(playerid)
{
    GameTextForPlayer(playerid, "Halo, kamu ~r~gay ya", 2000, 0);
    return 1;
}

// /stats 
CMD:stats(playerid)
{
    ShowStats(playerid);
    return 1; 
}

CMD:setlevel(playerid, params[])
{
    new targetId, 
        amountLevel;
    if(sscanf(params, "ud", targetId, amountLevel)) 
        return SendClientMessage(playerid, COLOR_USAGE, "USAGE: {ffffff}/setlevel <id> <level>");

    if(!IsPlayerConnected(targetId))
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Player tidak terkoneksi kedalam server!");
    
    SetPlayerScore(targetId, amountLevel);
    g_PlayerData[targetId][pLevel] = amountLevel;
    // info untuk player
    SendClientMessage(playerid, COLOR_SUCCESS, "SUCCESS: {ffffff}Kamu berhasil mengubah level dari player %s ke level %d", g_PlayerData[targetId][pName], amountLevel);
    // info untuk target
    SendClientMessage(targetId, COLOR_INFO, "INFO: {ffffff}Level kamu diubah oleh %s ke level %d", g_PlayerData[playerid][pName], amountLevel);
    return 1;
}

CMD:setinterior(playerid, params[])
{
    new targetId, 
        interior;

    if(sscanf(params, "ud", targetId, interior)) 
        return SendClientMessage(playerid, COLOR_USAGE, "USAGE: {ffffff}/setinterior <id> <interior>");
    
    if(!IsPlayerConnected(targetId))
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Player tidak terkoneksi kedalam server!");
    
    SetPlayerInterior(playerid, interior);
    g_PlayerData[targetId][pInterior] = interior;

    // info player
    SendClientMessage(playerid, COLOR_SUCCESS, "SUCCESS: {ffffff}Kamu telah mengubah interior dari %s ke %d", g_PlayerData[targetId][pName], interior);
    // info untuk target
    SendClientMessage(playerid, COLOR_INFO, "INFO: {ffffff}Interior kamu telah diubah oleh %s ke %d", g_PlayerData[playerid][pName], interior);
    return 1;
}

CMD:setskin(playerid, params[])
{
    new targetId,
        skinId;
    
    if(sscanf(params, "ud", targetId, skinId))
        return SendClientMessage(playerid, COLOR_USAGE, "USAGE: {ffffff}/setskin <id> <skinid>");

    if(!IsPlayerConnected(targetId))
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Player tidak terkoneksi kedalam server!");
    
    if(skinId < 0 || skinId > 311)
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Id skin tidak boleh kurang dari 0 atau lebih dari 311!");
    
    SetPlayerSkin(targetId, skinId);
    g_PlayerData[targetId][pSkin] = skinId;

    // info untuk player
    SendClientMessage(playerid, COLOR_SUCCESS, "SUCCESS: {ffffff}Kamu telah mengubah skin dari %s ke id %d", g_PlayerData[targetId][pName], skinId);
    // info ubtuj target
    SendClientMessage(playerid, COLOR_INFO, "INFO: {ffffff}Skin kamu telah diubah oleh %s ke id %d", g_PlayerData[playerid][pName], skinId);
    return 1;
}

CMD:setvw(playerid, params[])
{
    new targetId,
        vwId;

    if(sscanf(params, "ud", targetId, vwId))
        return SendClientMessage(playerid, COLOR_USAGE, "USAGE: {ffffff}/setvw <id> <vw>");
    
    if(!IsPlayerConnected(targetId))
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Player tidak terkoneksi kedalam server!");
    
    SetPlayerVirtualWorld(targetId, vwId);
    g_PlayerData[targetId][pVirtual_World] = vwId;

    // info untuk player
    SendClientMessage(playerid, COLOR_SUCCESS, "SUCCESS: {ffffff}Kamu telah mengubah virtual world dari %s ke id %d", g_PlayerData[targetId][pName], vwId);
    // info ubtuj target
    SendClientMessage(playerid, COLOR_INFO, "INFO: {ffffff}Virtual world kamu telah diubah oleh %s ke id %d", g_PlayerData[playerid][pName], vwId);
    return 1;
}

CMD:updatedata(playerid)
{
    UpdateDataPlayer(playerid, 1);

    SendClientMessage(playerid, COLOR_WHITE, "Berhasil menyimpan data pemain!");
    return 1;
}

// CMD:tesmarker(playerid, params[])
// {
//     new targetId;
//     if(sscanf(params, "u", targetId))
//         return USAGE(playerid, "/tesmarker <id target>");
    
//     SetPlayerMarkerForPlayer(playerid, targetId, 0xFF0000FF);
//     SUCCESS(playerid, "Player ditandai dimap");
//     return 1;
// }
CMD:createvehicle(playerid, params[])
{
    new modelid, color1, color2;
    if(sscanf(params, "iii", modelid, color1, color2))
        return SendClientMessage(playerid, COLOR_USAGE, "USAGE: {ffffff}/createvehicle <modelid> <color1> <color2>");
    
    if(modelid < 400 || modelid >611)
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Model id tidak boleh kurang dari 411 atau lebih dari 611!");
    
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    if(AddVeh(playerid, modelid, x, y, z, a, color1, color2))
    {
        SendClientMessage(playerid, COLOR_SUCCESS, "SUCCESS: {ffffff}Kamu berhasil membuat kendaraan!");
    }
    else
        SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Gagal membuat kendaraan!");
    return 1;
}

CMD:loadvehicle(playerid)
{
    mysql_tquery(g_SQL, "SELECT * FROM vehicles", "OnVehicleLoaded", "");
    return 1;
}

CMD:countvehicle(playerid)
{
    new count;
    foreach(new i : PlayerVehicle)
    {
        count++;
    }
    SendClientMessage(playerid, COLOR_WHITE, "Ada %d kendaraan terhitung didalam server", count);
    return 1;
}

CMD:parkveh(playerid)
{
    if(!IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Kamu tidak sedang didalam mobil!");
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Kamu tidak sedang didalam kursi kemudi!");

    new vehicleid = GetPlayerVehicleID(playerid);

    if(g_VehicleData[vehicleid][E_VEHICLE_OWNER] != g_PlayerData[playerid][E_PLAYER_ID])
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Kendaraan ini bukan milikmu!");

    if(g_VehicleData[vehicleid][E_VEHICLE_ID] <= 0)
        return SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Kendaraan ini tidak tersedia didalam database");

    new Float: newPos[4];
    GetVehiclePos(vehicleid, newPos[0], newPos[1], newPos[2]);
    GetVehicleZAngle(vehicleid, newPos[3]);

    g_VehicleData[vehicleid][E_VEHICLE_POS][0] = newPos[0];
    g_VehicleData[vehicleid][E_VEHICLE_POS][1] = newPos[1];
    g_VehicleData[vehicleid][E_VEHICLE_POS][2] = newPos[2];
    g_VehicleData[vehicleid][E_VEHICLE_POS][3] = newPos[3];

    if(UpdateParkVehice(vehicleid))
    {
        SendClientMessage(playerid, COLOR_SERVER, "SERVER: {ffffff}Kendaraan kamu berhasil diparkirkan!");
    }
    else
    {
        SendClientMessage(playerid, COLOR_ERROR, "ERROR: {ffffff}Kendaraan kamu Gagal diparkirkan!");
    }
    return 1;
}
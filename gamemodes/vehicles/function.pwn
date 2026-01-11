stock AddVeh(playerid, model, Float:x, Float:y, Float:z, Float:a, color1, color2)
{
    new vehicleid = CreateVehicle(model, x, y, z, a, color1, color2, -1, false);
    if(vehicleid == INVALID_VEHICLE_ID) return 0;
    
    g_VehicleData[vehicleid][E_VEHICLE_OWNER] = g_PlayerData[playerid][E_PLAYER_ID];
    g_VehicleData[vehicleid][E_VEHICLE_MODEL] = model;
    g_VehicleData[vehicleid][E_VEHICLE_POS][0] = x;
    g_VehicleData[vehicleid][E_VEHICLE_POS][1] = y;
    g_VehicleData[vehicleid][E_VEHICLE_POS][2] = z;
    g_VehicleData[vehicleid][E_VEHICLE_POS][3] = a;
    g_VehicleData[vehicleid][E_VEHICLE_COLOR1] = color1;
    g_VehicleData[vehicleid][E_VEHICLE_COLOR2] = color2;
    g_VehicleData[vehicleid][E_IS_EXISTS] = true;

    Iter_Add(PlayerVehicle, vehicleid);

    new query[450];
    mysql_format(g_SQL, query, sizeof(query), "INSERT INTO vehicles (owner_id, model, pos_x, pos_y, pos_z, pos_a, color1, color2) VALUES ('%d', '%d', '%f', '%f', '%f', '%f', '%d', '%d')", 
    g_PlayerData[playerid][E_PLAYER_ID], model, x, y, z, a, color1, color2);
    mysql_tquery(g_SQL, query, "OnVehicleCreated", "d", vehicleid);
    return 1;
}

stock UpdateDataVehicle(vehicleid)
{
    if(vehicleid == INVALID_VEHICLE_ID) return 0;
    if(!g_VehicleData[vehicleid][E_IS_EXISTS]) return 0;
    if(g_VehicleData[vehicleid][E_VEHICLE_ID] <= 0) return 0;

    new query[300];
    mysql_format(g_SQL, query, sizeof(query), "UPDATE vehicles SET pos_x = '%f', pos_y = '%f', pos_z = '%f', pos_a = '%f' WHERE id = '%d' LIMIT 1", 
    g_VehicleData[vehicleid][E_VEHICLE_POS][0], g_VehicleData[vehicleid][E_VEHICLE_POS][1], g_VehicleData[vehicleid][E_VEHICLE_POS][2], 
    g_VehicleData[vehicleid][E_VEHICLE_POS][3], g_VehicleData[vehicleid][E_VEHICLE_ID]);
    
    mysql_tquery(g_SQL, query);
    printf("[VEHICLE] Kendaraan id %d diupdate!", g_VehicleData[vehicleid][E_VEHICLE_ID]);
    return 1;
}
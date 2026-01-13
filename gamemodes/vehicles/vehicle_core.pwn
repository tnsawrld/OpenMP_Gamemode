stock AddVeh(playerid, model, Float:x, Float:y, Float:z, Float:a, color1, color2)
{
    new vehicleid = CreateVehicle(model, x, y, z, a, color1, color2, -1, false);
    if(vehicleid == INVALID_VEHICLE_ID) return 0;
    
    g_VehicleData[vehicleid][vOwner] = g_PlayerData[playerid][pID];
    g_VehicleData[vehicleid][vModel] = model;
    g_VehicleData[vehicleid][vPos][0] = x;
    g_VehicleData[vehicleid][vPos][1] = y;
    g_VehicleData[vehicleid][vPos][2] = z;
    g_VehicleData[vehicleid][vPos][3] = a;
    g_VehicleData[vehicleid][vColor1] = color1;
    g_VehicleData[vehicleid][vColor2] = color2;
    g_VehicleData[vehicleid][isExists] = true;

    Iter_Add(PlayerVehicle, vehicleid);

    new query[450];
    mysql_format(g_SQL, query, sizeof(query), "INSERT INTO vehicles (owner_id, model, pos_x, pos_y, pos_z, pos_a, color1, color2) VALUES ('%d', '%d', '%f', '%f', '%f', '%f', '%d', '%d')", 
    g_PlayerData[playerid][pID], model, x, y, z, a, color1, color2);
    mysql_tquery(g_SQL, query, "OnVehicleCreated", "d", vehicleid);
    return 1;
}

stock UpdateDataVehicle(vehicleid)
{
    if(vehicleid == INVALID_VEHICLE_ID) return 0;
    if(!g_VehicleData[vehicleid][isExists]) return 0;
    if(g_VehicleData[vehicleid][vID] <= 0) return 0;

    new query[300];
    mysql_format(g_SQL, query, sizeof(query), "UPDATE vehicles SET pos_x = '%f', pos_y = '%f', pos_z = '%f', pos_a = '%f' WHERE id = '%d' LIMIT 1", 
    g_VehicleData[vehicleid][vPos][0], g_VehicleData[vehicleid][vPos][1], g_VehicleData[vehicleid][vPos][2], 
    g_VehicleData[vehicleid][vPos][3], g_VehicleData[vehicleid][vID]);
    
    mysql_tquery(g_SQL, query);
    printf("[VEHICLE] Kendaraan id %d diupdate!", g_VehicleData[vehicleid][vID]);
    return 1;
}

forward OnVehicleLoaded();
public OnVehicleLoaded()
{
    new rows = cache_num_rows();
    if(!rows)
    {
        print("[VEHICLE] Tidak ada kendaraan yang diload!");
        return 1;
    }
    
    new loaded;
    for(new i = 0; i < rows; i++)
    { 
        new model, owner_id, vehicle_id,
            Float:x, Float:y, Float:z, Float:a,
            color1, color2;
        
        cache_get_value_name_int(i, "id", vehicle_id);
        cache_get_value_name_int(i, "owner_id", owner_id);
        cache_get_value_name_int(i, "model", model);

        cache_get_value_name_float(i, "pos_x", x);
        cache_get_value_name_float(i, "pos_y", y);
        cache_get_value_name_float(i, "pos_z", z);
        cache_get_value_name_float(i, "pos_a", a);

        cache_get_value_name_int(i, "color1", color1);
        cache_get_value_name_int(i, "color2", color2);

        new vehicleid = CreateVehicle(model, x, y, z, a, color1, color2, -1, false);
        if(vehicleid == INVALID_VEHICLE_ID) continue;

        g_VehicleData[vehicleid][vID] = vehicle_id;
        g_VehicleData[vehicleid][vOwner] = owner_id;
        g_VehicleData[vehicleid][vModel] = model;
        g_VehicleData[vehicleid][vPos][0] = x;
        g_VehicleData[vehicleid][vPos][1] = y;
        g_VehicleData[vehicleid][vPos][2] = z;
        g_VehicleData[vehicleid][vPos][3] = a;
        g_VehicleData[vehicleid][vColor1] = color1;
        g_VehicleData[vehicleid][vColor2] = color2;
        g_VehicleData[vehicleid][isExists] = true;

        Iter_Add(PlayerVehicle, vehicleid);
        loaded++;
    }
    printf("[VEHICLE] Kendaraan sebanyak %d berhasil dimuat", loaded);
    return 1;
}

forward OnVehicleCreated(vehicleid);
public OnVehicleCreated(vehicleid)
{
    new insert_id = cache_insert_id();
    if(vehicleid != INVALID_VEHICLE_ID && insert_id > 0)
    {
        g_VehicleData[vehicleid][vID] = insert_id;
    }
    printf("[VEHICLE] Sebuah kendaraan berhasil dibuat dengan id = %d",  g_VehicleData[vehicleid][vID]);
    return 1;
}


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

        g_VehicleData[vehicleid][E_VEHICLE_ID] = vehicle_id;
        g_VehicleData[vehicleid][E_VEHICLE_OWNER] = owner_id;
        g_VehicleData[vehicleid][E_VEHICLE_MODEL] = model;
        g_VehicleData[vehicleid][E_VEHICLE_POS][0] = x;
        g_VehicleData[vehicleid][E_VEHICLE_POS][1] = y;
        g_VehicleData[vehicleid][E_VEHICLE_POS][2] = z;
        g_VehicleData[vehicleid][E_VEHICLE_POS][3] = a;
        g_VehicleData[vehicleid][E_VEHICLE_COLOR1] = color1;
        g_VehicleData[vehicleid][E_VEHICLE_COLOR2] = color2;
        g_VehicleData[vehicleid][E_IS_EXISTS] = true;

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
        g_VehicleData[vehicleid][E_VEHICLE_ID] = insert_id;
    }
    printf("[VEHICLE] Sebuah kendaraan berhasil dibuat dengan id = %d",  g_VehicleData[vehicleid][E_VEHICLE_ID]);
    return 1;
}


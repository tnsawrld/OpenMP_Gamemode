enum E_VEHICLE_DATA{
	vID,
	vOwner,
	vModel,
	Float: vPos[4],
	vColor1,
	vColor2,
	// temp
	bool:isExists,
	vCooldownSave
		
};
new g_VehicleData[MAX_VEHICLES][E_VEHICLE_DATA];
new Iterator: PlayerVehicle<MAX_VEHICLES>; 
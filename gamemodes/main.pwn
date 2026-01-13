#define YSI_NO_VERSION_CHECK
#include <open.mp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 50

#undef MAX_VEHICLES
#define MAX_VEHICLES 100

#include <streamer>
#include <Pawn.CMD>
#include <a_mysql>
#include <samp_bcrypt>
#include <sscanf2>
#include <YSI_Data\y_iterate>

#include "server\server_define.pwn"
#include "server\server_textdraw.pwn"
#include "server\server_variable.pwn"

// enum player
enum E_PLAYER_DATA{
	pID,
	pName[MAX_PLAYER_NAME],
	pPassword[128],
	Float:pPos[4],
	pInterior,
	pVirtual_World,
	pSkin,
	pMoney,
	pLevel,
	
	// temp variable
	bool:isLogin,
	Cache: pCacheID,
	pLoginAttempt
};

new g_PlayerData[MAX_PLAYERS][E_PLAYER_DATA];

#include "server\server_function.pwn"

#include "players\player_account.pwn"
#include "players\player_utils.pwn"
#include "players\player_command.pwn"

#include "vehicles\vehicle_data.pwn"
#include "vehicles\vehicle_core.pwn"
#include "vehicles\vehicle_command.pwn"


main()
{
}


// Disaat gamemode start
public OnGameModeInit()
{
	// mysql
	ConnectToDatabase(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DBNAME);
	
	CreateGlobalTextdraw();

	SetGameModeText("gamemooodeeeee");
	DisableInteriorEnterExits();
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);

	Iter_Init(PlayerVehicle);
	mysql_tquery(g_SQL, "SELECT * FROM vehicles", "OnVehicleLoaded", "");
	// AddPlayerClass(12, 1958.3783, 1343.1572, 15.3746, 269.1425, WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
	return 1;
}

// Disaat gamemode mati
public OnGameModeExit()
{
	mysql_close(g_SQL);
	return 1;
}

public OnPlayerConnect(playerid)
{
	// textdraw server
	TextDrawShowForPlayer(playerid, Server_Name[0]);
	TextDrawShowForPlayer(playerid, Server_Name[1]);

	// reset g_PlayerData
	ResetValueVariable(playerid);
	GetPlayerNameEx(playerid);

	AccountCheck(playerid);
	new ip[16];
	GetPlayerIp(playerid, ip, sizeof(ip));
	SendClientMessage(playerid, COLOR_WHITE, "IP : %s", ip);
	printf("player id %d dengan ip %s telah bergabung ke server", playerid, ip);
	SendClientMessageToAll(COLOR_SERVER,"SERVER: {ffffff}%s telah bergabung kedalam server!", g_PlayerData[playerid][pName]);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	g_MysqlRaceCheck[playerid]++;
	
	UpdateDataPlayer(playerid, reason);

	// player crash sebelunm berhasil login
	if (cache_is_valid(g_PlayerData[playerid][pCacheID]))
	{
		cache_delete(g_PlayerData[playerid][pCacheID]);
		g_PlayerData[playerid][pCacheID] = MYSQL_INVALID_CACHE;
		print("CACHE DIHAPUS, crash");
	}
	g_PlayerData[playerid][isLogin] = false;
	// ResetValueVariable(playerid);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerCameraPos(playerid, 367.9782, -2029.3656, 45.6719);
    SetPlayerCameraLookAt(playerid, 367.9782, -2029.3656, 45.6719);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		if((gettime() - g_VehicleData[vehicleid][vCooldownSave] < 20)) return SendClientMessage(playerid, COLOR_WHITE, "Delay 20 detik untuk save");
		g_VehicleData[vehicleid][vCooldownSave] = gettime();
		GetVehiclePos(vehicleid, g_VehicleData[vehicleid][vPos][0], g_VehicleData[vehicleid][vPos][1], g_VehicleData[vehicleid][vPos][2]);
		GetVehicleZAngle(vehicleid, g_VehicleData[vehicleid][vPos+][3]);

		UpdateDataVehicle(vehicleid);
		SendClientMessage(playerid, COLOR_WHITE, "Kamu keluar dari kursi pengemudi kendaraan, vehid %d [disimpan]", vehicleid);
	}
	else 
	{
		SendClientMessage(playerid, COLOR_WHITE, "Kamu keluar dari kursi penumpang kendaraan, vehid %d [tidak disimpan]", vehicleid);
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

/*
     ___              _      _ _    _
    / __|_ __  ___ __(_)__ _| (_)__| |_
    \__ \ '_ \/ -_) _| / _` | | (_-<  _|
    |___/ .__/\___\__|_\__,_|_|_/__/\__|
        |_|
*/

public OnPlayerRequestSpawn(playerid)
{
	if(!g_PlayerData[playerid][isLogin])
	{
		SendClientMessage(playerid, COLOR_ERROR, "ERROR: Kamu tidak diizinkan menekan tombol spawn!");
		return 0;
	}
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerText(playerid, text[])
{
	new msg[144];
	format(msg, sizeof(msg), "%s [%d] : %s", g_PlayerData[playerid][pName], playerid, text);

	new Float:posX,
		Float:posY,
		Float:posZ;

	GetPlayerPos(playerid, posX, posY, posZ);

	foreach(new i : Player)
	{
		if(IsPlayerInRangeOfPoint(i, 20.0, posX, posY, posZ))
		{
			SendClientMessage(i, COLOR_WHITE, msg);
		}
	}

	return 0;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
	return 1;
}

public OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	if(g_CP[playerid] == 1)
	{
		DisablePlayerCheckpoint(playerid);
		g_CP[playerid] = 0;
		SendClientMessage(playerid, COLOR_SERVER, "SERVER: {ffffff}Kamu sudah sampai dicheckpoint!");
		return 1;
	}
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerGiveDamageActor(playerid, damaged_actorid, Float:amount, WEAPON:weaponid, bodypart)
{
	return 1;
}

public OnActorStreamIn(actorid, forplayerid)
{
	return 1;
}

public OnActorStreamOut(actorid, forplayerid)
{
	return 1;
}

public OnPlayerEnterGangZone(playerid, zoneid)
{
	return 1;
}

public OnPlayerLeaveGangZone(playerid, zoneid)
{
	return 1;
}

public OnPlayerEnterPlayerGangZone(playerid, zoneid)
{
	return 1;
}

public OnPlayerLeavePlayerGangZone(playerid, zoneid)
{
	return 1;
}

public OnPlayerClickGangZone(playerid, zoneid)
{
	return 1;
}

public OnPlayerClickPlayerGangZone(playerid, zoneid)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnClientCheckResponse(playerid, actionid, memaddr, retndata)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerFinishedDownloading(playerid, virtualworld)
{
	return 1;
}

public OnPlayerRequestDownload(playerid, DOWNLOAD_REQUEST:type, crc)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 0;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
  if (result == -1)
  {
    SendClientMessage(playerid, COLOR_SERVER, "SERVER: {ffffff}Command tidak tersedia, /help untuk melihat command yang tersedia");
    return 0;
  }

  return 1;
}

public OnPlayerSelectObject(playerid, SELECT_OBJECT:type, objectid, modelid, Float:fX, Float:fY, Float:fZ)
{
	return 1;
}

public OnPlayerEditObject(playerid, playerobject, objectid, EDIT_RESPONSE:response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	return 1;
}

public OnPlayerEditAttachedObject(playerid, EDIT_RESPONSE:response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnPlayerPickUpPlayerPickup(playerid, pickupid)
{
	return 1;
}

public OnPickupStreamIn(pickupid, playerid)
{
	return 1;
}

public OnPickupStreamOut(pickupid, playerid)
{
	return 1;
}

public OnPlayerPickupStreamIn(pickupid, playerid)
{
	return 1;
}

public OnPlayerPickupStreamOut(pickupid, playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, WEAPON:weaponid, bodypart)
{
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart)
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, CLICK_SOURCE:source)
{
	return 1;
}

public OnPlayerWeaponShot(playerid, WEAPON:weaponid, BULLET_HIT_TYPE:hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	SetPlayerPosFindZ(playerid, Float:fX, Float:fY, Float:fZ);
	SendClientMessage(playerid, COLOR_SERVER, "SERVER: Kamu melakukan teleport melalui map!");
	return 1;
}

public OnIncomingConnection(playerid, ip_address[], port)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	return 1;
}

public OnTrailerUpdate(playerid, vehicleid)
{
	return 1;
}

public OnVehicleSirenStateChange(playerid, vehicleid, newstate)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnEnterExitModShop(playerid, enterexit, interiorid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	return 1;
}

public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch (dialogid)
	{
		case DIALOG_UNUSED: return 1;

		case DIALOG_LOGIN:
		{
			if(!response) return KickEx(playerid);

			bcrypt_verify(playerid, "OnPasswordVerify", inputtext, g_PlayerData[playerid][pPassword]);
		}

		case DIALOG_REGISTER:
		{
			if(!response) return KickEx(playerid);

			if(strlen(inputtext) <= 5) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registrasi Akun", "Password harus lebih panjang dari 5 karakter!\nSilahkan buat password untuk melanjutkan registrasi.", "Proses", "Tutup");

			bcrypt_hash(playerid, "OnPasswordHashed", inputtext, BCRYPT_COST);
		} 
		default: return 0; 
	}
	return 1;
}

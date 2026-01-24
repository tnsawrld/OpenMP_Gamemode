/*                                                
,--------.                       ,--.   ,--.,------. ,--.   ,------.   
'--.  .--',--,--,  ,---.  ,--,--.|  |   |  ||  .--. '|  |   |  .-.  \  
   |  |   |      \(  .-' ' ,-.  ||  |.'.|  ||  '--'.'|  |   |  |  \  : 
   |  |   |  ||  |.-'  `)\ '-'  ||   ,'.   ||  |\  \ |  '--.|  '--'  / 
   `--'   `--''--'`----'  `--`--''--'   '--'`--' '--'`-----'`-------'  
*/

#define YSI_NO_VERSION_CHECK
#include <open.mp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 50

#undef MAX_VEHICLES
#define MAX_VEHICLES 100

#include <YSI_Data\y_iterate>
#include <streamer>
#include <Pawn.CMD>
#include <a_mysql>
#include <samp_bcrypt>
#include <sscanf2>
#include <easyDialog>
#include <mSelection>
#include <discord-connector>
#include <discord-cmd>

// file server module 
#include "modules\server\server_define.inc"
#include "modules\server\server_macro.inc"
#include "modules\server\server_textdraw.pwn"
#include "modules\server\server_variable.inc"

// file player module
#include "modules\players\player_data.inc"
#include "modules\players\player_utils.inc"
#include "modules\players\player_ucp.inc"
#include "modules\players\player_dialog.inc"

// file vehicle module
#include "modules\vehicles\vehicle_data.inc"
#include "modules\vehicles\vehicle_core.inc"

// file server utils 
#include "modules\server\server_utils.inc"

#include "modules\cmd\vehicle_command.inc"
#include "modules\cmd\player_command.inc"

// file discord module
#include "modules\discord\tesaja.inc"

main()
{
}

// Disaat gamemode start
public OnGameModeInit()
{
	SendRconCommand("game.mode %s", GAMEMODE);
	// load skin model untuk skin awal spawn
	m_SkinSpawn = LoadModelSelectionMenu("male_spawnskin.txt");
	f_SkinSpawn = LoadModelSelectionMenu("female_spawnskin.txt");

	// database 
	ConnectToDatabase(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DBNAME);
	
	CreateGlobalTextdraw();

	DisableInteriorEnterExits();
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);

	Iter_Init(PlayerVehicle);

	mysql_tquery(g_SQL, "SELECT * FROM vehicles", "OnVehicleLoaded", "");
	return 1;
}

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

	ResetValueVariable(playerid);
	
	AccountCheck(playerid);

	if (IsPlayerUsingOfficialClient(playerid))
        g_PlayerData[playerid][isOfficialClient] = true;

	new ip[16];
	GetPlayerIp(playerid, ip, sizeof(ip));
	SendClientMessage(playerid, COLOR_WHITE, "IP : %s", ip);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	g_MysqlRaceCheck[playerid]++;
	
	UpdateDataPlayer(playerid);
	SetPlayerName(playerid, g_PlayerData[playerid][pUCP]);

	g_PlayerData[playerid][isLogin] = false;
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    // SetPlayerCameraPos(playerid, 367.9782, -2029.3656, 45.6719);
    // SetPlayerCameraLookAt(playerid, 367.9782, -2029.3656, 45.6719);
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

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		if((gettime() - g_VehicleData[vehicleid][vCooldownSave] < 20)) return SendClientMessage(playerid, COLOR_WHITE, "Delay 20 detik untuk save");
		g_VehicleData[vehicleid][vCooldownSave] = gettime();
		GetVehiclePos(vehicleid, g_VehicleData[vehicleid][vPos][0], g_VehicleData[vehicleid][vPos][1], g_VehicleData[vehicleid][vPos][2]);
		GetVehicleZAngle(vehicleid, g_VehicleData[vehicleid][vPos][3]);

		UpdateDataVehicle(vehicleid);
		SendClientMessage(playerid, COLOR_WHITE, "Kamu keluar dari kursi pengemudi kendaraan, vehid %d [disimpan]", vehicleid);
	}
	else 
	{
		SendClientMessage(playerid, COLOR_WHITE, "Kamu keluar dari kursi penumpang kendaraan, vehid %d [tidak disimpan]", vehicleid);
	}
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	if(!g_PlayerData[playerid][isLogin])
	{
		SendClientMessage(playerid, COLOR_ERROR, "ERROR: Kamu tidak diizinkan menekan tombol spawn!");
		return 0;
	}
	return 1;
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

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
  if (result == -1)
  {
    SendClientMessage(playerid, COLOR_SERVER, "SERVER: {ffffff}Command tidak tersedia, /help untuk melihat command yang tersedia");
    return 0;
  }

  return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	SetPlayerPosFindZ(playerid, Float:fX, Float:fY, Float:fZ);
	SendClientMessage(playerid, COLOR_SERVER, "SERVER: Kamu melakukan teleport melalui map!");
	return 1;
}

public OnPlayerModelSelection(playerid, response, listid, modelid)
{
	if(listid == m_SkinSpawn) 
	{
		if(response)
		{
			g_PlayerData[playerid][pSkin] = modelid;
			
			new query[128];
			mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM player WHERE username = '%e'", g_PlayerData[playerid][pName]);
			mysql_tquery(g_SQL, query, "OnInsertCharacter", "d", playerid);
		}
	}

	if(listid == f_SkinSpawn)
	{
		if(response)
		{
			g_PlayerData[playerid][pSkin] = modelid;
			
			new query[128];
			mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM player WHERE username = '%e'", g_PlayerData[playerid][pName]);
			mysql_tquery(g_SQL, query, "OnInsertCharacter", "d", playerid);
		}
	}
	return 1;
}


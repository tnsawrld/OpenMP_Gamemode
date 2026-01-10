new g_CP[MAX_PLAYERS];
new MySQL:g_SQL;
new g_MysqlRaceCheck[MAX_PLAYERS];

enum {
	DIALOG_UNUSED,
	DIALOG_LOGIN,
	DIALOG_REGISTER
}

// new const
// 	Float:g_RandomSpawn[3][4] = 
// 	{	// X		// Y		// Z 	// A
// 		{1958.2170, 1343.0073, 15.3746, 268.6832}, // Koordinat spawn 1
// 		{1685.3691, -2239.3911, 13.5469, 183.2054}, // Koordinat spawn 3
// 		{-1981.1333, 137.6527, 27.6875, 89.2254} // Koordinat spawn 3
// 	};
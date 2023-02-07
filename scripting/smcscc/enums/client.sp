enum eWaitingType
{
	NONE           = 0,
	WAITING_TAG    = 1,
	WAITING_W_SEED = 2,
	WAITING_G_SEED = 3,
}

// struct client
enum struct eClient
{
	eWaitingType waitingType;
	int          TN[2];    // TD[0] = team, TD[1] = weaponnum

	ArrayList arWeaponsT;
	ArrayList arWeaponsCT;
	eGlove    gloveT;
	eGlove    gloveCT;
	int       knifeTDefIndex;
	int       knifeCTDefIndex;
}

public int GetClientKnife(int client, int team)
{
	if (team == 2)
	{
		eClient clientStruct;
		g_arClients.GetArray(client, clientStruct);
		return clientStruct.knifeCTDefIndex;
	}
	else if (team == 3) {
		eClient clientStruct;
		g_arClients.GetArray(client, clientStruct);
		return clientStruct.knifeTDefIndex;
	}
	return -1;
}

public int SetClientKnife(int client, int team, int knifeDefIndex)
{
	if (team == 0)
	{
		eClient clientStruct;
		g_arClients.GetArray(client, clientStruct);
		clientStruct.knifeTDefIndex  = knifeDefIndex;
		clientStruct.knifeCTDefIndex = knifeDefIndex;
		return g_arClients.SetArray(client, clientStruct);
	}
	else if (team == 2)
	{
		eClient clientStruct;
		g_arClients.GetArray(client, clientStruct);
		clientStruct.knifeCTDefIndex = knifeDefIndex;
		return g_arClients.SetArray(client, clientStruct);
	}
	else if (team == 3) {
		eClient clientStruct;
		g_arClients.GetArray(client, clientStruct);
		clientStruct.knifeTDefIndex = knifeDefIndex;
		return g_arClients.SetArray(client, clientStruct);
	}
	return -1;
}

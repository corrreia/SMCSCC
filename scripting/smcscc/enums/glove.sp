
// struct glove
enum struct eGlove
{
	int   gloveDefIndex;
	int   skinDefIndex;
	float floatValue;
	int   seed;
}

public void InitGlove(eGlove glove)
{
	glove.gloveDefIndex = -1;
	glove.skinDefIndex  = -1;
	glove.floatValue    = 0.0;
	glove.seed          = -1;
}

public void ClearGlove(eGlove glove)
{
	InitGlove(glove);
}

// GETTERS AND SETTERS FOR glove STRUCT
public int GetGloveSkinDefIndex(int client, int team)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));

	if (team == 0)
	{
		return (GetGloveSkinDefIndex(client, 2) == -1 || GetGloveSkinDefIndex(client, 3) == -1) ? -1 : 0;
	}
	else if (team == 2)
	{
		return clientStruct.gloveT.skinDefIndex;
	}
	else if (team == 3) {
		return clientStruct.gloveCT.skinDefIndex;
	}
	return -1
}

public int GetGloveDefIndex(int client, int team)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));

	if (team == 0)
	{
		// if both are equeal return the value
		// if one of them is -1 return -1
		// else return 0
		return (GetGloveDefIndex(client, 2) == GetGloveDefIndex(client, 3)) ? GetGloveDefIndex(client, 2) : (GetGloveDefIndex(client, 2) == -1 || GetGloveDefIndex(client, 3) == -1) ? -1
		                                                                                                                                                                             : 0;
	}
	else if (team == 2)
	{
		return clientStruct.gloveT.gloveDefIndex;
	}
	else if (team == 3) {
		return clientStruct.gloveCT.gloveDefIndex;
	}
	return -1
}

public int SetGloveSkinDefIndex(int client, int team, int gloveDefIndex, int skinDefIndex)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));

	if (team == 0)
	{
		return SetGloveSkinDefIndex(client, 2, gloveDefIndex, skinDefIndex) + SetGloveSkinDefIndex(client, 3, gloveDefIndex, skinDefIndex);
	}
	else if (team == 2)
	{
		clientStruct.gloveT.skinDefIndex  = skinDefIndex;
		clientStruct.gloveT.gloveDefIndex = gloveDefIndex;
	}
	else if (team == 3) {
		clientStruct.gloveCT.skinDefIndex  = skinDefIndex;
		clientStruct.gloveCT.gloveDefIndex = gloveDefIndex;
	}
	return g_arClients.SetArray(client, clientStruct, sizeof(clientStruct));
}

public float GetGloveFloatValue(int client, int team)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));

	if (team == 0)
	{
		// if both are equeal return the value
		// else return 0
		return (GetGloveFloatValue(client, 2) == GetGloveFloatValue(client, 3)) ? GetGloveFloatValue(client, 2) : 0.0;
	}
	if (team == 2)
	{
		return clientStruct.gloveT.floatValue;
	}
	else if (team == 3) {
		return clientStruct.gloveCT.floatValue;
	}
	return -1.0;
}

public int SetGloveFloatValue(int client, int team, float floatValue)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));

	if (team == 0)
	{
		return SetGloveFloatValue(client, 2, floatValue) + SetGloveFloatValue(client, 3, floatValue);
	}
	else if (team == 2)
	{
		clientStruct.gloveT.floatValue = floatValue;
		clientStruct.gloveT.seed       = 2434;
	}
	else if (team == 3)
	{
		clientStruct.gloveCT.floatValue = floatValue;
		clientStruct.gloveCT.seed       = 2342;
	}
	return g_arClients.SetArray(client, clientStruct, sizeof(clientStruct));
}

public int GetGloveSeed(int client, int team)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));

	if (team == 2)
	{
		return clientStruct.gloveT.seed;
	}
	else if (team == 3) {
		return clientStruct.gloveCT.seed;
	}
	return -1;
}

public int SetGloveSeed(int client, int team, int seed)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));

	if (team == 0)
	{
		return SetGloveSeed(client, 2, seed) + SetGloveSeed(client, 3, seed);
	}
	else if (team == 2)
	{
		clientStruct.gloveT.seed = seed;
	}
	else if (team == 3) {
		clientStruct.gloveCT.seed = seed;
	}
	return g_arClients.SetArray(client, clientStruct, sizeof(clientStruct));
}

public void PrintGloves(int client)
{
	PrintToChatAll("team 2: gloveDefIndex: %d, skinDefIndex: %d, floatValue: %f, seed: %d", GetGloveDefIndex(client, 2), GetGloveSkinDefIndex(client, 2), GetGloveFloatValue(client, 2), GetGloveSeed(client, 2));
	PrintToChatAll("team 3: gloveDefIndex: %d, skinDefIndex: %d, floatValue: %f, seed: %d", GetGloveDefIndex(client, 3), GetGloveSkinDefIndex(client, 3), GetGloveFloatValue(client, 3), GetGloveSeed(client, 3));
}
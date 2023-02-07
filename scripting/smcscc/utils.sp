bool IsValidClient(int client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client))
	{
		return false;
	}
	return true;
}

void CleanNameTag(char[] nameTag, int size)
{
	ReplaceString(nameTag, size, "%", "％");
	while (StrContains(nameTag, "  ") > -1)
	{
		ReplaceString(nameTag, size, "  ", " ");
	}
	StripQuotes(nameTag);
}

stock void FixCustomArms(int client)
{
	char temp[2];
	GetEntPropString(client, Prop_Send, "m_szArmsModel", temp, sizeof(temp));
	if (temp[0])
	{
		SetEntPropString(client, Prop_Send, "m_szArmsModel", "");
	}
}

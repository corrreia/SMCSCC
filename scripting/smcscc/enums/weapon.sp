
// struct weapon
enum struct eWeapon
{
	int	  skinDefIndex;
	char  nameTag[20];
	float floatValue;
	int	  seed;
	bool  statTrak;
	int	  statTrakCount;
}

public void InitWeapon(eWeapon weapon)
{
	weapon.skinDefIndex	 = -1;
	weapon.nameTag		 = "";
	weapon.floatValue	 = 0.0;
	weapon.seed			 = -1;
	weapon.statTrak		 = false;
	weapon.statTrakCount = 0;
}

public void ClearWeapon(eWeapon weapon) { InitWeapon(weapon); }

// GETTERS AND SETTERS FOR WEAPON STRUCT
public int GetWeaponSkinDefIndex(int client, int team, int weaponNum)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;

	if (team == 0)
	{
		return (GetWeaponSkinDefIndex(client, 2, weaponNum) == -1 || GetWeaponSkinDefIndex(client, 3, weaponNum) == -1) ? -1 : 0;
	}
	else if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
	}
	int skinDefIndex = weapon.skinDefIndex;
	return skinDefIndex;
}

public int SetWeaponSkinDefIndex(int client, int team, int weaponNum, int skinDefIndex)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;
	if (team == 0)
	{
		return SetWeaponSkinDefIndex(client, 2, weaponNum, skinDefIndex) + SetWeaponSkinDefIndex(client, 3, weaponNum, skinDefIndex);
	}
	else if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.skinDefIndex = skinDefIndex;
		return clientStruct.arWeaponsT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.skinDefIndex = skinDefIndex;
		return clientStruct.arWeaponsCT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	return -1;
}

public int GetWeaponNameTag(int client, int team, int weaponNum, char[] nameTag, int length)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;
	if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
		strcopy(nameTag, length, weapon.nameTag);
		return clientStruct.arWeaponsT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
		strcopy(nameTag, length, weapon.nameTag);
		return clientStruct.arWeaponsCT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	return -1;
}

public int SetWeaponNameTag(int client, int team, int weaponNum, char[] nameTag)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;

	if (team == 0)
	{
		return SetWeaponNameTag(client, 2, weaponNum, nameTag) + SetWeaponNameTag(client, 3, weaponNum, nameTag);
	}
	else if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
		strcopy(weapon.nameTag, sizeof(weapon.nameTag), nameTag);
		return clientStruct.arWeaponsT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
		strcopy(weapon.nameTag, sizeof(weapon.nameTag), nameTag);
		return clientStruct.arWeaponsCT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	return -1;
}

public float GetWeaponFloatValue(int client, int team, int weaponNum)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;
	if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
		return weapon.floatValue;
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
		return weapon.floatValue;
	}
	return -1.0;
}

public int SetWeaponFloatValue(int client, int team, int weaponNum, float floatValue)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;

	if (team == 0)
	{
		return SetWeaponFloatValue(client, 2, weaponNum, floatValue) + SetWeaponFloatValue(client, 3, weaponNum, floatValue);
	}
	else if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.floatValue = floatValue;
		return clientStruct.arWeaponsT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.floatValue = floatValue;
		return clientStruct.arWeaponsCT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	return -1;
}

public int GetWeaponSeed(int client, int team, int weaponNum)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;
	if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
		return weapon.seed;
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
		return weapon.seed;
	}
	return -1;
}

public int SetWeaponSeed(int client, int team, int weaponNum, int seed)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;

	if (team == 0)
	{
		return SetWeaponSeed(client, 2, weaponNum, seed) + SetWeaponSeed(client, 3, weaponNum, seed);
	}
	else if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.seed = seed;
		return clientStruct.arWeaponsT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.seed = seed;
		return clientStruct.arWeaponsCT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	return -1;
}

public bool GetWeaponStatTrak(int client, int team, int weaponNum)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;
	if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
		return weapon.statTrak;
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
		return weapon.statTrak;
	}
	return false;
}

public int SetWeaponStatTrak(int client, int team, int weaponNum, bool statTrak)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;
	if (team == 0)
	{
		return SetWeaponStatTrak(client, 2, weaponNum, statTrak) + SetWeaponStatTrak(client, 3, weaponNum, statTrak);
	}
	else if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.statTrak = statTrak;
		return clientStruct.arWeaponsT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.statTrak = statTrak;
		return clientStruct.arWeaponsCT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	return -1;
}

public int SwitchWeaponStatTrak(int client, int team, int weaponNum)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;
	if (team == 0)
	{
		return SwitchWeaponStatTrak(client, 2, weaponNum) + SwitchWeaponStatTrak(client, 3, weaponNum);
	}
	else if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.statTrak = !weapon.statTrak;
		return clientStruct.arWeaponsT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.statTrak = !weapon.statTrak;
		return clientStruct.arWeaponsCT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	return -1;
}

public int GetWeaponStatTrakCount(int client, int team, int weaponNum)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;
	if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
		return weapon.statTrakCount;
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
		return weapon.statTrakCount;
	}
	return -1;
}

public int SetWeaponStatTrakCount(int client, int team, int weaponNum, int statTrakCount)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;

	if (team == 0)
	{
		return SetWeaponStatTrakCount(client, 2, weaponNum, statTrakCount) + SetWeaponStatTrakCount(client, 3, weaponNum, statTrakCount);
	}
	else if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.statTrakCount = statTrakCount;
		return clientStruct.arWeaponsT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.statTrakCount = statTrakCount;
		return clientStruct.arWeaponsCT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	return -1;
}

public int PlusOneKill(int client, int team, int weaponNum)
{
	eClient clientStruct;
	g_arClients.GetArray(client, clientStruct, sizeof(clientStruct));
	eWeapon weapon;
	if (team == 2)
	{
		clientStruct.arWeaponsT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.statTrakCount++;
		return clientStruct.arWeaponsT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	else if (team == 3) {
		clientStruct.arWeaponsCT.GetArray(weaponNum, weapon, sizeof(weapon));
		weapon.statTrakCount++;
		return clientStruct.arWeaponsCT.SetArray(weaponNum, weapon, sizeof(weapon));
	}
	return -1;
}
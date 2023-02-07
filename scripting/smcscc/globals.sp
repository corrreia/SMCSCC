
ArrayList g_arClients          = null;
ArrayList g_arKnifesDefIndexes = null;

#include "smcscc/enums/glove.sp"
#include "smcscc/enums/weapon.sp"
#include "smcscc/enums/client.sp"

public void InitGValriables()
{
	g_arClients          = new ArrayList(sizeof(eClient), MAXPLAYERS + 1);
	g_arKnifesDefIndexes = new ArrayList();

	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		eClient client;
		client.waitingType = NONE;
		client.arWeaponsT  = new ArrayList(sizeof(eWeapon), eItems_GetWeaponCount());
		client.arWeaponsCT = new ArrayList(sizeof(eWeapon), eItems_GetWeaponCount());

		eGlove gloveT;
		InitGlove(gloveT);
		client.gloveT = gloveT;

		eGlove gloveCT;
		InitGlove(gloveCT);
		client.gloveCT = gloveCT;

		for (int j = 0; j < eItems_GetWeaponCount(); j++)
		{
			eWeapon weapon;
			InitWeapon(weapon);
			client.arWeaponsT.SetArray(j, weapon);
			client.arWeaponsCT.SetArray(j, weapon);
			client.knifeTDefIndex  = 0;
			client.knifeCTDefIndex = 0;
		}

		g_arClients.SetArray(i, client);
	}
	PrintToServer("[SMCSCC] Clients array initialized.");

	PrintToServer("[SMCSCC] Global variables initialized.");
}

public void LoadItems()
{
	for (int j = 0; j < eItems_GetWeaponCount(); j++)
	{
		int defIndex = eItems_GetWeaponDefIndexByWeaponNum(j);
		if (eItems_IsDefIndexKnife(defIndex) && eItems_IsSkinnableDefIndex(defIndex))
		{
			g_arKnifesDefIndexes.Push(defIndex);
		}
	}
	PrintToServer("[SMCSCC] Knifes synced.");
}
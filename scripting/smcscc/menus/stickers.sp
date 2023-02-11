Menu CreateStickerMainMenu(int client)
{
	char buffer[32];
	char displayBuffer[32];

	if (!IsPlayerAlive(client))
	{
		PrintToChat(client, "You must be alive to use this command");
		return null;
	}

	int weapon = eItems_GetActiveWeapon(client);
	int weaponDefIndex = eItems_GetWeaponDefIndexByWeapon(weapon);

	if (!eItems_IsValidWeapon(weapon))
	{
		PrintToChat(client, "You must be holding a weapon to use this command");
		return null;
	}

	int slots = eItems_GetWeaponStickersSlotsByDefIndex(weaponDefIndex);
	if (slots <= 0)
	{
		PrintToChat(client, "Is not possible to apply stickers in this weapon");
		return null;
	}

	int team = GetClientTeam(client);
	eItems_GetWeaponDisplayNameByDefIndex(weaponDefIndex, buffer, sizeof(buffer));

	Menu menu = new Menu(StickerMainMenuHandler);
	menu.SetTitle("Stickers for %s",  buffer);
	
	for (int i = 1; i < slots + 1; i++)
	{
		Format(buffer, sizeof(buffer), "slot_%d_%d_%d", team, weaponDefIndex, i);
		int stickerDefIndex = g_clients[client].getStickerDefIndex(i,eItems_GetWeaponNumByDefIndex(weaponDefIndex), team)
		
		if(stickerDefIndex == -1)
		{
			Format(displayBuffer, sizeof(displayBuffer), "Slot %d - <empty>", i);
			menu.AddItem(buffer, displayBuffer);
		}
		else
		{
			char nameBuffer[32];
			eItems_GetStickerDisplayNameByDefIndex(stickerDefIndex, nameBuffer, sizeof(nameBuffer));
			Format(displayBuffer, sizeof(displayBuffer), "Slot %d - %s", i, nameBuffer);
			menu.AddItem(buffer, displayBuffer);
		}
	}

	//menu.AddItem("x", "", ITEMDRAW_SPACER);
	Format(buffer, sizeof(buffer), "slot_%d_%d_0", team, weaponDefIndex); 
	menu.AddItem(buffer, "All Stickers");

	Format(buffer, sizeof(buffer), "wear_%d_%d_0", team, weaponDefIndex);
	menu.AddItem(buffer, "Set Wear");

	Format(buffer, sizeof(buffer), "rotation_%d_%d_0", team, weaponDefIndex);
	menu.AddItem(buffer, "Set Rotation");
	
	menu.ExitButton = true;

	return menu;
}

public int StickerMainMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char buffer[32];
				char buffer2[4][32];
				menu.GetItem(selection, buffer, sizeof(buffer));
				ExplodeString(buffer, "_", buffer2, 4, 32);  // [0] = type, [1] = team, [2] = weapon, [3] = pos

				
				int team = StringToInt(buffer2[1]);
				int weaponDefIndex = StringToInt(buffer2[2]);
				int pos = StringToInt(buffer2[3]);

				if (StrEqual(buffer2[0], "slot"))
				{
					CreateStickersMenu(client, team, weaponDefIndex, pos).Display(client, 60);
				}
				else if (StrEqual(buffer2[0], "wear"))
				{
					//CreateStickerWearMenu(client, weaponDefIndex, team, pos).Display(client, 60);
				}
				else if (StrEqual(buffer2[0], "rotation"))
				{
					//CreateStickerRotationMenu(client, weaponDefIndex, team, pos).Display(client, 60);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateMainMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}

Menu CreateStickersMenu(int client, int team, int weaponDefIndex, int pos)
{
	Menu menu = new Menu(StickersMenuHandler);

	char buffer[32];

	if (IsPlayerAlive(client))
	{
		menu.SetTitle("Sticker Menu", client);

		Format(buffer, sizeof(buffer), "all_%d_%d_%d", team, weaponDefIndex, pos);
		menu.AddItem("all", "All Stickers");

		Format(buffer, sizeof(buffer), "search_%d_%d_%d", team, weaponDefIndex, pos);
		menu.AddItem("search", "Search Stickers");

		return menu;
	}else{
		PrintToChat(client, "You must be alive to use this command");
		return null;
	}
}

public int StickersMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char buffer[32];
				menu.GetItem(selection, buffer, sizeof(buffer));

				char buffer2[4][32];
				ExplodeString(buffer, "_", buffer2, 4, 32);  // [0] = type, [1] = team, [2] = weapon, [3] = pos

				int team = StringToInt(buffer2[1]);
				int weaponDefIndex = StringToInt(buffer2[2]);
				int pos = StringToInt(buffer2[3]);

				if (StrEqual(buffer2[0], "all"))
				{
					CreateStickersSetsMenu(client, team, weaponDefIndex, pos).Display(client, 60);
				}
				else //search
				{
					PrintToChat(client, "Please enter the sticker name you are searching for in chat. Type '!cancel' to cancel the search.");
					g_clients[client].setWaitingType(WAITING_STICKER_SEARCH);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
				CreateMainMenu(client).Display(client, 60);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 1;
}

Menu CreateStickersSetsMenu(int client, int team, int weaponDefIndex, int pos)
{
	Menu menu = new Menu(StickersSetsMenuHandler);

	if (IsPlayerAlive(client))
	{
		menu.SetTitle("Chose the collection", client);

		// char buffer[32];
		// char displayBuffer[32];

		// for (int set = 1; set < eItems_GetStickersSetsCount(); set++)  //FIXME: WTF
		// {
		// 	Format(buffer, sizeof(buffer), "set_%d_%d_%d_%d", team, weaponDefIndex, pos, set);
		// 	eItems_GetSpraySetDisplayNameBySpraySetNum(set, displayBuffer, sizeof(displayBuffer));
		// 	menu.AddItem(buffer, displayBuffer);
		// }

		menu.ExitButton = true;

		return menu;
		
	}else{
		PrintToChat(client, "You must be alive to apply stickers.");
		return null;
	}
}

public int StickersSetsMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
}
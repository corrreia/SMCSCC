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
				char info[32];
				menu.GetItem(selection, info, sizeof(info));
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

Menu CreateStickersMenu(int client)
{
	Menu menu = new Menu(StickersMenuHandler);

	if (IsPlayerAlive(client))
	{
		menu.SetTitle("Sticker Menu", client);

		menu.AddItem("all", "All Stickers");

		menu.AddItem("search", "Search Stickers");
		
		return menu;
	}else{
		PrintToChat(client, "You must be alive to use this command");
		return;
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
				char info[32];
				menu.GetItem(selection, info, sizeof(info));

				if (StrEqual(info, "all"))
				{
					CreateStickersSubMenu(client).Display(client, 60);
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

Menu CreateStickersSubMenu(int client, char[] search = "")
{
	Menu menu = new Menu(StickersSubMenuHandler);

	if (IsPlayerAlive(client))
	{
		//if search is empty, display all stickers
		if (StrEqual(search, ""))
		{
			menu.SetTitle("All Stickers", client);

			
		}
		else //display stickers that match the search
		{
			menu.SetTitle("Search Results", client);

			
		}
		
	}else{
		PrintToChat(client, "You must be alive to apply stickers.");
		return null;
	}

	return menu;
}

public int StickersSubMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
}
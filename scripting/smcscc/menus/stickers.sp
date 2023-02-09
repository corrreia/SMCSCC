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
		
		
	}else{
		PrintToChat(client, "You must be alive to apply stickers.");
		return null;
	}

	return menu;
}

public int StickersSubMenuHandler(Menu menu, MenuAction action, int client, int selection)
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
					
				}
				else //search
				{
					
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
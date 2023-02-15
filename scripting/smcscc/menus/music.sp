Menu CreateMusicMenu(int client)
{
	char buffer[64];
	char buffer2[32];

	Menu menu = new Menu(MusicMenuHandler);

	menu.SetTitle("Music Kit Menu", client);

	menu.AddItem("-1", "Remove");	   

	for(int i = 0; i < eItems_GetMusicKitsCount(); i++)
	{
		int defIndex = eItems_GetMusicKitDefIndexByMusicKitNum(i);
		eItems_GetMusicKitDisplayNameByDefIndex(defIndex, buffer, sizeof(buffer));
		Format(buffer2, sizeof(buffer2), "%d", defIndex);
		menu.AddItem(buffer2, buffer);
	}

	menu.ExitBackButton = true;

	return menu;
}

public int MusicMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsClientInGame(client))
			{
				char info[32];
				menu.GetItem(selection, info, sizeof(info));
				int defIndex = StringToInt(info);

				g_clients[client].setMusicKit(defIndex);

				SetMusicKit(client);
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
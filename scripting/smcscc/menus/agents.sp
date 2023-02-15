Menu CreateAgentMenu(int client)
{
    Menu menu = new Menu(AgentMenuHandler);

    menu.SetTitle("Agent Menu", client);

    menu.AddItem("2", "T");

    menu.AddItem("3", "CT");

    menu.ExitBackButton = true;

    return menu;
}

public int AgentMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            if (IsClientInGame(client))
            {
                char info[32];
                menu.GetItem(selection, info, sizeof(info));

                CreateAgentCustomMenu(client, StringToInt(info)).Display(client, 60);
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

Menu CreateAgentCustomMenu(int client, int team)
{
    char agent[64];
    char buffer[32];

    Menu menu = new Menu(AgentCustomMenuHandler);

    menu.SetTitle("Chose the agent", client);

    for(int i = 0; i < eItems_GetAgentsCount(); i++)
    {
        if(eItems_GetAgentTeamByAgentNum(i) == team){
            eItems_GetAgentDisplayNameByAgentNum(i, agent, sizeof(agent));
            Format(buffer, sizeof(buffer), "%d", eItems_GetAgentDefIndexByAgentNum(i));
            menu.AddItem(buffer, agent);
        }

    }


    menu.ExitBackButton = true;

    return menu;
}

public int AgentCustomMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            if (IsClientInGame(client))
            {
                char buffer[64]
                char info[32];
                menu.GetItem(selection, info, sizeof(info));

                int agent = StringToInt(info);
                
                eItems_GetAgentPlayerModelByDefIndex(agent, buffer, sizeof(buffer));

                g_clients[client].setAgent(team, )

                PrintToChat(client, "Agent: %s", buffer);
            }
        }
        case MenuAction_Cancel:
        {
            if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
                CreateAgentMenu(client).Display(client, 60);
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
    return 1;
}
#pragma newdecls required
#include <sourcemod>
#include <sdktools>

int IMPULS_FLASHLIGHT				= 100;
float PressTime[MAXPLAYERS+1];

public Plugin myinfo = 
{
	name = "L4D2 Night Vision",
	author = "Lyseria",
	description = "New syntax and intructor hint",
	version = "1.2",
	url = ""
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if( test != Engine_Left4Dead && test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Ko nhìn tên à chỉ hỗ trợ l4d2 thôi.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}


public void OnPluginStart()
{
	RegConsoleCmd("sm_nightvision", denpinsang);
}

public Action denpinsang (int client, int args)
{
	if(IsSurvivor(client)) SwitchNightVision(client);
	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impuls, float vel[3], float angles[3], int &weapon)
{
		if(impuls == IMPULS_FLASHLIGHT)
		{
			if(IsSurvivor(client))
				{		 	
					float time = GetEngineTime();
					if(time - PressTime[client] < 0.3)
						{
							SwitchNightVision(client); 				 
						}
					PressTime[client] = time;
				}
		}
		return Plugin_Continue;
}

void SwitchNightVision(int client)
{
	static float Time = 2.0;
	char Word[128]
	int d = GetEntProp(client, Prop_Send, "m_bNightVisionOn");
	if(d == 0)
	{
			SetEntProp(client, Prop_Send, "m_bNightVisionOn",1); 
			int entity = CreateEntityByName("env_instructor_hint");
			if(entity == -1) return;
			FormatEx(Word, sizeof(Word), "Kính nhìn đêm Bật", client);
			DispatchKeyValue(client, "targetname", Word);
			DispatchKeyValue(entity, "hint_target", Word);
			DispatchKeyValue(entity, "hint_range", "0");
			DispatchKeyValue(entity, "hint_forcecaption", "1");
			DispatchKeyValue(entity, "hint_icon_onscreen", "icon_equip_flashlight_active");
			DispatchKeyValue(entity, "hint_caption", Word);
			
			FormatEx(Word, sizeof(Word), "%i %i %i", GetRandomInt(0, 255), GetRandomInt(0, 255), GetRandomInt(0, 255));
			DispatchKeyValue(entity, "hint_color", Word);
			DispatchSpawn(entity);

			AcceptEntityInput(entity, "ShowHint", client);
			FormatEx(Word, sizeof(Word), "OnUser1 !self:Kill::%f:1", Time);
			SetVariantString(Word);
			AcceptEntityInput(entity, "AddOutput", -1, -1, 0);
			AcceptEntityInput(entity, "FireUser1", -1, -1, 0);			
	}
	else
	{
			SetEntProp(client, Prop_Send, "m_bNightVisionOn",0);
			int entity = CreateEntityByName("env_instructor_hint");
			if(entity == -1) return;
			FormatEx(Word, sizeof(Word), "Kính nhìn đêm Tắt", client);
			DispatchKeyValue(client, "targetname", Word);
			DispatchKeyValue(entity, "hint_target", Word);
			DispatchKeyValue(entity, "hint_range", "0");
			DispatchKeyValue(entity, "hint_forcecaption", "1");
			DispatchKeyValue(entity, "hint_icon_onscreen", "icon_equip_flashlight");
			DispatchKeyValue(entity, "hint_caption", Word);
			
			FormatEx(Word, sizeof(Word), "%i %i %i", GetRandomInt(0, 255), GetRandomInt(0, 255), GetRandomInt(0, 255));
			DispatchKeyValue(entity, "hint_color", Word);
			DispatchSpawn(entity);

			// AcceptEntityInput(entity, "ShowHint", -1, -1, 0); // Target hint
			AcceptEntityInput(entity, "ShowHint", client);
			FormatEx(Word, sizeof(Word), "OnUser1 !self:Kill::%f:1", Time);
			SetVariantString(Word);
			AcceptEntityInput(entity, "AddOutput", -1, -1, 0);
			AcceptEntityInput(entity, "FireUser1", -1, -1, 0);
	}
}

stock bool IsSurvivor(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2) && IsPlayerAlive(client) && !IsFakeClient(client);
}

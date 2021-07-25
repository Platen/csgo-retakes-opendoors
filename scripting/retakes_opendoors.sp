#include <sourcemod>
#include <cstrike>
#include <clientprefs>
#include "include/retakes.inc"
#include "retakes/generic.sp"

#pragma semicolon 1
#pragma newdecls required

ConVar g_hbreakProbability;
ConVar g_hopenProbability;
char currentMap[PLATFORM_MAX_PATH];

public Plugin myinfo = {
    name = "[Retakes] Open doors",
    author = "Microman",
    description = "Open doors and break breakables",
    version = "1.0.0",
    url = ""
};

public void OnPluginStart() {
    /** ConVars **/
    g_hbreakProbability = CreateConVar("sm_retakes_break_breakables", "1.0", "Probablity for a breakable to broken at round start.", _, true, 0.0, true, 1.0);
    g_hopenProbability = CreateConVar("sm_retakes_open_doors", "0.5", "Probablity for a door to be open at round start.", _, true, 0.0, true, 1.0);

    /** Event hooks **/
    HookEvent("round_poststart", Event_RoundPostStart);

    /** Create/Execute retakes cvars **/
    AutoExecConfig(true, "retakes_opendoors", "sourcemod/retakes");
}

public void OnMapStart()
{
    GetCurrentMap(currentMap, sizeof(currentMap));
}

public Action Event_RoundPostStart(Event event, const char[] name, bool dontBroadcast) {
    if (!Retakes_Enabled() || !Retakes_Live() || Retakes_InEditMode()) {
        return;
    }

    BreakBreakables();
    OpenDoors();
}

void BreakBreakables() {
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "func_breakable")) != -1) {
        int rand = GetRandomInt(0,100);
        if (rand <= 100*GetConVarFloat(g_hbreakProbability)) {
            AcceptEntityInput(ent, "Break");
        }
    }
    while ((ent = FindEntityByClassname(ent, "func_breakable_surf")) != -1) {
        int rand = GetRandomInt(0,100);
        if (rand <= 100*GetConVarFloat(g_hbreakProbability)) {
            AcceptEntityInput(ent, "Break");
        }
    }

    if (StrEqual(currentMap, "de_nuke")) {
        while ((ent = FindEntityByClassname(ent, "func_button")) != -1) {
            AcceptEntityInput(ent, "Kill");
        }
    }
    if (StrEqual(currentMap, "de_mirage")) {
        while ((ent = FindEntityByClassname(ent, "prop.breakable.01")) != -1) {
            AcceptEntityInput(ent, "break");
        }
        while ((ent = FindEntityByClassname(ent, "prop.breakable.02")) != -1) {
            AcceptEntityInput(ent, "break");
        }
    } else if (StrEqual(currentMap, "de_vertigo") || StrEqual(currentMap, "de_cache") || StrEqual(currentMap, "de_nuke")) {
        while ((ent = FindEntityByClassname(ent, "prop_dynamic")) != -1) {
            AcceptEntityInput(ent, "Break");
        }
    }
}

void OpenDoors() {
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "prop_door_rotating")) != -1) {
        int rand = GetRandomInt(0,100);
        if (rand <= 100*GetConVarFloat(g_hopenProbability)) {
            AcceptEntityInput(ent, "open");
        }
    }
}

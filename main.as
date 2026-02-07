// Settings tab
[Setting category="HUD" name="Enable Standalone HUD"]
bool S_Enabled = true;

[Setting category="HUD" name="Show Delta Time"]
bool S_ShowDelta = true;

[Setting category="HUD" name="Hide when Interface is Off"]
bool S_HideWithInterface = true;

[Setting category="HUD" name="Lock Position"]
bool S_Locked = false;

[Setting category="HUD" name="Show Toast Notifications"]
bool S_ShowToasts = true;

[Setting category="Debug" name="Reset Milked Maps"]
bool S_ResetMilkedMaps = false;


// Tracks session achievements, in order to not spam Toast Notification
dictionary sessionMilkedMaps;

// Ratio to apply on the formula, the lower the closer to author medal, may change on feedback
const float MilkRatio = 0.40; 

// Placeholder for PB time
uint g_PbTime = 0;

// Placeholder string for UME
string currentUID = ""; 


// Logic to get medal time, also changes for low seconds map (50%) making it more feasible
uint CalculateMilkTime() {

    auto app = cast<CTrackMania>(GetApp());
    if (app is null || app.RootMap is null) return 0;

    uint at = app.RootMap.TMObjective_AuthorTime;
    uint gold = app.RootMap.TMObjective_GoldTime;
    if (at == 0) return 0;

    uint gap = gold - at;
    return (gap < 800) ? at + (gap / 2) : at + uint(gap * MilkRatio);
}

//UME Integration

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
class MilkMedal : UltimateMedalsExtended::IMedal {
    UltimateMedalsExtended::Config GetConfig() override {
        UltimateMedalsExtended::Config c;
        c.defaultName = "Milk";
        c.icon = "\\$fec" + Icons::Circle; 
        return c;
    }

    void UpdateMedal(const string &in uid) override {}

    bool HasMedalTime(const string &in uid) override {
        return currentUID == uid && CalculateMilkTime() != 0;
    }

    uint GetMedalTime() override {
        return CalculateMilkTime();
    }
}

void OnDestroyed() {
    UltimateMedalsExtended::RemoveMedal("Milk");
}
#endif

// Reset Setting Logic

void CheckResetSetting() {
    while (true) {
        if (S_ResetMilkedMaps) {
            ResetMilkedMaps();
            S_ResetMilkedMaps = false;
        }
        sleep(100);
    }
}

void ResetMilkedMaps() {
    sessionMilkedMaps.DeleteAll();
    string filePath = IO::FromStorageFolder("milked_maps.json");
    Json::ToFile(filePath, Json::Object());
    print("Milked maps reset!");
}

//Write maps "milked" to a json file that persist after restarting the game
void SaveMilkedMaps() {
    auto json = Json::Object();
    auto keys = sessionMilkedMaps.GetKeys();
    for (uint i = 0; i < keys.Length; i++) {
        json[keys[i]] = true;
    }
    
    string filePath = IO::FromStorageFolder("milked_maps.json");
    Json::ToFile(filePath, json);
}

void LoadMilkedMaps() {
    string filePath = IO::FromStorageFolder("milked_maps.json");
    if (!IO::FileExists(filePath)) return;
    
    try {
        auto json = Json::FromFile(filePath);
        auto keys = json.GetKeys();
        for (uint i = 0; i < keys.Length; i++) {
            sessionMilkedMaps.Set(keys[i], true);
        }
        print("Loaded " + keys.Length + " milked maps from file");
    } catch {
        print("Error loading milked_maps.json");
    }
}

void Main() {
#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
    UltimateMedalsExtended::AddMedal(MilkMedal());
#endif

    LoadMilkedMaps();
    startnew(PbLoop);
    startnew(CheckResetSetting);
}

//Fort's pb loop shared on discord, not entirely sure how it works but it saves general pb on each map
void PbLoop() {
    auto app = cast<CTrackMania>(GetApp());
    while (true) {
        if (app.RootMap !is null && app.Network !is null && app.Network.ClientManiaAppPlayground !is null) {
            currentUID = app.RootMap.IdName;

            auto userId = app.UserManagerScript.Users[0].Id;
            auto scoreMgr = app.Network.ClientManiaAppPlayground.ScoreMgr;
            g_PbTime = scoreMgr.Map_GetRecord_v2(userId, currentUID, "PersonalBest", "", "TimeAttack", "");

            // Toast Notification Trigger + checking if already notified
            if (S_ShowToasts && g_PbTime > 0) {
                uint milkTime = CalculateMilkTime();
                
                bool alreadyNotified = sessionMilkedMaps.Exists(currentUID);
                if (g_PbTime <= milkTime && (!alreadyNotified)) {
                    
                    if (!alreadyNotified) {
                        sessionMilkedMaps.Set(currentUID, true);
                        SaveMilkedMaps();
                    }
                    
                 

                    // Toast Notification UI
                    UI::ShowNotification(
                        "\\$fec" + Icons::Circle + " \\$z\\$wMilk Medal Earned!",
                        "Time: " + Time::Format(g_PbTime),
                        vec4(0.2f, 0.8f, 0.2f, 0.5f), 
                        5000
                    );
                }
            }
        }
        sleep(1000);
    }
}


// Hud UI for Medal Name/Time/Delta
void Render() {
    if (!S_Enabled) return;
    auto app = cast<CTrackMania>(GetApp());
    if (app is null || app.RootMap is null) return;
    if (S_HideWithInterface && !UI::IsGameUIVisible()) return;

    uint milkTime = CalculateMilkTime();
    if (milkTime == 0) return;
    
    int flags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::AlwaysAutoResize;
    if (S_Locked) flags |= UI::WindowFlags::NoMove | UI::WindowFlags::NoInputs;

    UI::Begin("MilkMedalHUD", flags); 
        UI::PushStyleColor(UI::Col::Text, vec4(1.0f, 0.98f, 0.92f, 1.0f));
        UI::Text(Icons::Circle); 
        UI::PopStyleColor();
        UI::SameLine();

        UI::Text("\\$s\\$wMilk"); 
        UI::SameLine();
        UI::Text("\\$s" + Time::Format(milkTime));

        if (S_ShowDelta && g_PbTime > 0) {
            UI::SameLine();
            if (g_PbTime <= milkTime) {
                uint diff = milkTime - g_PbTime;
                UI::PushStyleColor(UI::Col::Text, vec4(0.45f, 0.55f, 1.0f, 1.0f)); 
                UI::Text("-" + Time::Format(diff));
                UI::PopStyleColor();
            } else {
                uint diff = g_PbTime - milkTime;
                UI::PushStyleColor(UI::Col::Text, vec4(1.0f, 0.35f, 0.45f, 1.0f)); 
                UI::Text("+" + Time::Format(diff));
                UI::PopStyleColor();
            }
        }
    UI::End();
}
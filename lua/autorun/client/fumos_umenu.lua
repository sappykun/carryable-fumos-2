local function Fumos_SettingsPanel(Panel)
	Panel:AddControl("Slider", {Label = "minimum squeezes", Command = "fumo_carryable_min_squeezes", Type = "Integer", Min = 0, Max = 50})
	Panel:AddControl("Slider", {Label = "explosion chance (tf r u doin to fumos)", Command = "fumo_carryable_min_squeezes", Type = "Float", Min = 0, Max = 1})
	Panel:AddControl("Slider", {Label = "placement cooldown", Command = "fumo_carryable_placement_cooldown", Type = "Integer", Min = 0, Max = 50})
	Panel:AddControl("Slider", {Label = "detonate time..????", Command = "fumo_carryable_detonate_time", Type = "Integer", Min = 0, Max = 50})
	Panel:AddControl("CheckBox", {Label = "bypass godmode/armor for explosions?", Command = "fumo_carryable_force_kill"})
end

local function Fumos_PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "Fumos", "Fumos settings", "fumos settings", "", "", Fumos_SettingsPanel)
end

hook.Add("PopulateToolMenu", "Fumos_PopulateToolMenu", Fumos_PopulateToolMenu)

list.Set("ContentCategoryIcons", "Fumos", "vgui/fumo_16.png")
out("wh2_tommy_randomized_start.lua ****************");

package.path = package.path ..';../lib/?.lua';

local randomized_start = require('common_tommy_randomized_start')

local _debug = require('common_tommy_debug_try_catch')

local function _get_primary_military_force_position(faction)
  local targ_x = nil;
  local targ_y = nil;
  local targ_region = nil;
  if (faction:has_faction_leader() and faction:faction_leader():has_military_force()) then
    out("tommy_get_primary_military_force_position | has_faction_leader and faction_leader:has_military_force");
    targ_x = faction:faction_leader():display_position_x();
    targ_y = faction:faction_leader():display_position_y();
    targ_region = faction:faction_leader():region();
  else
    local mf_list_item_0 = faction:military_force_list():item_at(0);
    if mf_list_item_0:has_general() then
      out("tommy_get_primary_military_force_position | mf_list_item_0:has_general");
      local general = mf_list_item_0:general_character();
      targ_x = general:display_position_x();
      targ_y = general:display_position_y();
      targ_region = general:region();
    elseif (faction:has_capital_region()) then
      out("tommy_get_primary_military_force_position | has_capital_region");
      local capital_sttlement = faction:capital_region():settlement();
      targ_x = capital_sttlement:display_position_x();
      targ_y = capital_sttlement:display_position_y();
      targ_region = faction:capital_region();
    end
  end
  out("tommy_get_primary_military_force_position | return " .. targ_x .. "," .. targ_y .. "," ..
      randomized_start.get_bool_str(not is_nil(targ_region)));
  return targ_x, targ_y, targ_region;
end

local function cm_query_model()
  return cm:model()
end

local function cm_local_faction_name()
  return cm:get_local_faction(true)
end

function _apply_religion_to_faction(faction)
	--out("ROY | faction: "..tostring(faction:name()));						
	local religion = faction:state_religion();
	--out("ROY | State Religion: "..tostring(religion));
	
	local regionList = faction:region_list();
	
	for r = 0, regionList:num_items() - 1 do			
		local region = regionList:item_at(r);
		--out("ROY | Region: "..tostring(region));
		
		local effect_bundle = {};
			
		if religion == "wh2_main_religion_skaven" then
			--out("ROY | skaven yesyes: "..tostring(region:religion_proportion("wh2_main_religion_skaven")));
			effect_bundle = "roy_effect_bundle_religion_skaven";
		elseif religion == "wh_main_religion_undeath" then
			--out("ROY | twilight: "..tostring(region:religion_proportion("wh_main_religion_undeath")));
			effect_bundle = "roy_effect_bundle_religion_undeath";
		elseif religion == "wh_main_religion_chaos" then					
			--out("ROY | breakbeat chaos: "..tostring(region:religion_proportion("wh_main_religion_chaos")));
			effect_bundle = "roy_effect_bundle_religion_chaos";					
		elseif religion == "wh_main_religion_untainted" then
			--out("ROY | untainted: "..tostring(region:religion_proportion("wh_main_religion_untainted")));
			effect_bundle = "roy_effect_bundle_religion_untainted";
		end;
		
		--out("ROY | apply religion: "..tostring(effect_bundle));
		cm:apply_effect_bundle_to_region(effect_bundle, region:name(), 5);
	end;
end;

function _repair_settlements_for_faction(faction)
  --out("ROY | Roy_Repair_Settlements_For_Faction | START of function "..tostring(faction:name()));
  local regionList = faction:region_list();
  
  for i = 0, regionList:num_items() -1 do
    local region = regionList:item_at(i);
    local region_Name = region:name();
    local settlement = region:settlement();
  
    local chain = region:slot_list():item_at(0):building():chain();
    out("ROY | CHAIN: "..tostring(chain));
    
    local targetBuilding = building_Upgrades[chain];
    out("ROY | TARGET BUILDING: "..tostring(targetBuilding));
    
    --cm:instantly_upgrade_building_in_region(region_Name, 0, targetBuilding);
    cm:region_slot_instantly_upgrade_building(settlement:primary_slot(), targetBuilding);		
    local newBuildingName = region:slot_list():item_at(0):building():name();
    --out("ROY | NEW BUILDING NAME: "..tostring(newBuildingName));
    
    local possiblePortSlot = region:slot_list():item_at(1);
    --out("ROY | possiblePortSlot: "..tostring(possiblePortSlot));
    
    ----------------- Check if port is in the settlement (excluding fortress_gates) ---------------------
    if (not string.match(newBuildingName, "fortress_gate")) and (not string.match(newBuildingName, "empire_fort")) then
      if possiblePortSlot:has_building() then
        local building = possiblePortSlot:building();
        --out("ROY | POSSIBLE PORT BUILDING NAME: "..tostring(building:name()));
        if string.match(building:name(), "port") and string.match(building:name(), "ruin") then
          chain = building:chain();
          out("ROY | PORT CHAIN: "..tostring(chain));
          
          targetBuilding = port_Upgrades[chain];
          out("ROY | TARGET PORT: "..tostring(targetBuilding));
          
          --cm:instantly_upgrade_building_in_region(region_Name, 1, targetBuilding);
          cm:region_slot_instantly_upgrade_building(settlement:port_slot(), targetBuilding);
        end;
      end;
    end;
    
    cm:heal_garrison(cm:get_region(region_Name):cqi());
  end;
  --out("ROY | Roy_Repair_Settlements_For_Faction | END of function ");
end;

local function randomizer(context, faction, params)
    out("wh2_tommy_randomized | randomizer | START of script | (" .. faction:name() .. ")");
    -- local character_list = faction:character_list();
    local region_list = faction:region_list();
    local region_list_world = cm_query_model():world():region_manager():region_list();
    local is_faction_local_me = randomized_start.is_faction_local_human(context, faction, params);
    local mforce_list = faction:military_force_list();
  
    local region_list_normal = randomized_start.list_ca_to_mormal_table(region_list);
    local region_list_world_normal = randomized_start.list_ca_to_mormal_table(region_list_world);
    local _, __, region_primary = _get_primary_military_force_position(faction);
    -- local region_list_adjacent_normal = randomized_start.list_ca_to_mormal_table(region_primary:adjacent_region_list())
  
    -- local region_name_list = {};
  
    local is_faction_has_no_region = region_list:num_items() == 0;
    local is_faction_has_1_region = region_list:num_items() == 1;
  
    if (faction:has_faction_leader()) then faction_leader = faction:faction_leader(); end
  
    for i = 0, mforce_list:num_items() - 1 do
      local force = mforce_list:item_at(i);
      if force:is_armed_citizenry() == false and force:has_general() == true then
        local general = force:general_character();
        out("wh2_tommy_randomized | randomizer | " .. randomized_start.get_character_infomation_readable(general));
        -- 挑选不在建筑物的角色(例如在城市或者农庄铁矿), 在建筑物的角色状态和野战可能有差别，需要特殊处理
        -- 此处本作者认为不需要处理这些角色, 让他们呆在原地就行
        if not general:in_settlement() and not general:in_port() then
          -- local region_name_list_patched = {unpack(region_name_list)}; -- 复制一份list数据
          -- local region_name_list_patched_length = #region_name_list_patched;
          -- local general_region = general:region()
          -- region_name_list_patched[region_name_list_patched_length + 1] = general:region():name();
          local final_x = general:logical_position_x();
          local final_y = general:logical_position_y();
          final_x = final_x + randomized_start.random_split_2(0.66, 3.3);
          final_y = final_y + randomized_start.random_split_2(0.66, 3.3);
          out("wh2_tommy_randomized | randomizer | before teleport" ..
                " found_position:" .. final_x .. "," .. final_y);
          -- cm:teleport_character(general, final_x, final_y);
          cm:teleport_to(cm:char_lookup_str(general), final_x, final_y);
        end
      end
    end
  
    if is_faction_local_me then
      -- local faction_handle = cm:modify_faction(faction:name());
      local faction_name = faction:name()
      local key_event_handle = "3k_tommy_randomized_start_reposition_camera";
      if (cm:is_multiplayer()) then
        -- TODO: scroll_camera_from_current for multiplayer mode
      else
        out("wh2_tommy_randomized | randomizer | add_listener ScriptEventCampaignCutsceneCompleted");
        core:add_listener(key_event_handle, "ScriptEventCampaignCutsceneCompleted", true, function(e)
          out("wh2_tommy_randomized | randomizer | on ScriptEventCampaignCutsceneCompleted");
          _debug:try{
            function()
              if (cm_query_model():turn_number() > 1) then
                core:remove_listener(key_event_handle);
                return false;
              end
              core:remove_listener(key_event_handle);
              local x_primary, y_primary, region_primary = _get_primary_military_force_position(faction);
              out(
                "wh2_tommy_randomized | randomizer | reposition camera | tommy_get_primary_military_force_position() " ..
                  _get_bool_str(not is_nil(region_primary)));
              if (is_nil(region_primary)) then return false; end
              -- 让主要目标所在的区域可以显示
              cm:make_region_seen_in_shroud(faction_name, region_primary:name());
              cm:make_region_visible_in_shroud(faction_name, region_primary:name());
              -- for i = 0, region_list_world:num_items() - 1 do end
              local x, y, d, b, h = cm:get_camera_position();
              cm:callback(function()
                out("wh2_tommy_randomized | randomizer | reposition camera | x_faction_leader:" .. x_primary ..
                      ", y_faction_leader:" .. y_primary .. ", at:" .. region_primary:name());
                cm:scroll_camera_from_current(1.5, nil, {x_primary, y_primary, d, b, h});
                -- cm:set_camera_position(x_primary, y_primary, d, b, h);
              end, 1);
  
              -- if (region_primary:is_abandoned()) and is_faction_has_no_region then
                -- 如果初始区域是一个废弃区域就把这个区域设置给玩家
                -- cm:modify_model():get_modify_region(region_primary):settlement_gifted_as_if_by_payload(faction_handle);
              -- end
              return true;
            end,
            _debug:catch{function(error) script_error('3k_tommy_randomized_start.lua | CAUGHT ERROR: ' .. error); end}
          }
        end, true);
      end
    end
  
    cm:callback(function()
      _debug:try{
        function()
          if (is_faction_has_no_region) then
            -- local faction_handle = cm:modify_faction(faction:name());
            local faction_name = faction:name()
            local _, __, region_primary = tommy_get_primary_military_force_position(faction);
            out("wh2_tommy_randomized | randomizer | timeout:1 | faction:" .. faction:name() ..
                  " final_region_primary:" .. region_primary:name() .. " subclture:" .. faction:subculture())
            if (region_primary:is_abandoned()) and is_faction_local_me then
              -- 如果初始区域是一个废弃区域就把这个区域设置给玩家/AI
              -- cm:modify_model():get_modify_region(region_primary):settlement_gifted_as_if_by_payload(faction_handle);
              cm:transfer_region_to_faction(region_primary:name(), faction_name);
              _repair_settlements_for_faction(faction_name)
              _apply_religion_to_faction(faction_name)
            end
            -- enable_region_tech_for_subculture_bandits(faction, faction_handle, region_primary);
          end
        end, _debug:catch{function(error) script_error('3k_tommy_randomized_start.lua | CAUGHT ERROR: ' .. error); end}
      }
    end, 0.2);
  
    out("wh2_tommy_randomized | randomizer | END of script ");
end

local params = {}

params.randomizer = randomizer
params.cm_query_model = cm_query_model
params.cm_local_faction_name = cm_local_faction_name

cm:add_first_tick_callback(function(context) randomized_start.run(context, params) end);

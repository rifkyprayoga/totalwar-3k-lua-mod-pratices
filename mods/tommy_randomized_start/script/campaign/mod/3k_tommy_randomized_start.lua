out("3k_tommy_randomized_start.lua ****************");

-- local events = get_events();

local REGION_DONT_SPAWN_TOO_MUCH = {
  ["3k_main_bohai_capital"] = true,
  ["3k_main_dongjun_resource_1"] = true,
  ["3k_main_penchang_resource_1"] = true,
  ["3k_main_penchang_resource_2"] = true,
  -- 宝岛台湾
  ["3k_main_yizhou_resource_2"] = true,
  ["3k_main_yizhou_resource_1"] = true,
  ["3k_main_yizhou_island_capital"] = true,
  -- 宝岛海南
  ["3k_main_hepu_capital"] = true,
  ["3k_main_hepu_resource_1"] = true
}

local MAPPINT_REGION_NAME_TO_BANDIT_NETWORK_TECH_PREFIX = {
  ["north"] = "bing_outer",
  ["shangdang"] = "bing",
  ["shoufang"] = "bing",
  ["taiyuan"] = "bing",
  ["xihe"] = "bing",
  ["yanmen"] = "bing",
  ["anping"] = "ji",
  ["weijun"] = "ji",
  ["zhongshan"] = "ji",
  ["cangwu"] = "jiaozhi",
  ["gaoliang"] = "jiaozhi",
  ["hepu"] = "jiaozhi",
  ["jiaozhi"] = "jiaozhi",
  ["nanhai"] = "jiaozhi",
  ["yulin"] = "jiaozhi",
  ["changsha"] = "jing",
  ["jiangxia"] = "jing",
  ["jingzhou"] = "jing",
  ["lingling"] = "jing",
  ["nanyang"] = "jing",
  ["runan"] = "jing",
  ["wuling"] = "jing",
  ["xiangyang"] = "jing",
  ["anding"] = "liang",
  ["jincheng"] = "liang",
  ["west"] = "liang_outer",
  ["wudu"] = "liang",
  ["wuwei"] = "liang",
  ["beihai"] = "qing",
  ["donglai"] = "qing",
  ["pingyuan"] = "qing",
  ["taishan"] = "qing",
  ["changan"] = "sili",
  ["hedong"] = "sili",
  ["luoyang"] = "sili",
  ["donghai"] = "xu",
  ["guangling"] = "xu",
  ["langye"] = "xu",
  ["penchang"] = "xu",
  ["dongjun"] = "yan",
  ["henei"] = "yan",
  ["yingchuan"] = "yan",
  ["dongou"] = "yang",
  ["jianan"] = "yang",
  ["jianye"] = "yang",
  ["kuaiji"] = "yang",
  ["lujiang"] = "yang",
  ["luling"] = "yang",
  ["poyang"] = "yang",
  ["tongan"] = "yang",
  ["xindu"] = "yang",
  ["yangzhou"] = "yang",
  ["ye"] = "yang",
  ["yuzhang"] = "yang",
  ["badong"] = "yi",
  ["bajun"] = "yi",
  ["baxi"] = "yi",
  ["chengdu"] = "yi",
  ["fuling"] = "yi",
  ["hanzhong"] = "yi",
  ["jiangyang"] = "yi",
  ["jianning"] = "yi",
  ["shangyong"] = "yi",
  ["yizhou"] = "yi",
  ["zangke"] = "yi",
  ["bohai"] = "you",
  ["daijun"] = "you",
  ["east"] = "you_outer",
  ["north"] = "you_outer",
  ["youbeiping"] = "you",
  ["youzhou"] = "you",
  ["yu"] = "you",
  ["chenjun"] = "yu"
}

local _debug = {is_debug = true}

function _debug:catch(what) return what[1] end

function _debug:try(what)
  if (not _debug.is_debug) then return what[2](result); end
  status, result = pcall(what[1])
  if not status then what[2](result) end
  return result
end

local random_call_offset = 0;
local function better_math_randomseed() 
  random_call_offset = random_call_offset + 1;
  math.randomseed(tonumber(tostring(6 * random_call_offset + os.time() * 2 * random_call_offset):reverse():sub(1, 8)));
  if (random_call_offset > 100) then
    random_call_offset = 0;
  end
end

local function random_split_2(min, range)
  local rangeToRand = (range - min - 2);
  better_math_randomseed();
  local randIntl = (math.random() * rangeToRand) - (rangeToRand * 2)
  local randIntlHalf = (randIntl / 2);
  return ((randIntlHalf / math.abs(randIntlHalf)) * min) + randIntlHalf
end

local function tommy_is_faction_local_human(context, faction)
  local model = context:query_model();
  return faction:is_human() and faction:name() == model:local_faction():name();
end

local function tommy_get_character_name_readable(character)
  local str_name_localised_string = effect.get_localised_string(character:get_surname());
  local str_forename_localised_string = effect.get_localised_string(character:get_forename());
  return ("" .. str_name_localised_string .. "" .. str_forename_localised_string .. "");
end

local function _get_bool_str(boo) return (boo and "true" or "false"); end

-- get character info mation readable
local function tommy_get_character_infomation_readable(character)
  return ("character:" .. tommy_get_character_name_readable(character) .. ", faction[" .. character:faction():name() ..
           "], logical pos[" .. character:logical_position_x() .. ", " .. character:logical_position_y() ..
           "], display pos[" .. character:display_position_x() .. ", " .. character:display_position_x() ..
           "], has_region:" .. _get_bool_str(character:has_region()) .. ", in_settlement:" ..
           _get_bool_str(character:in_settlement()));
end

local function tommy_list_ca_to_mormal_table(list_ca)
  local result = {}
  for i = 0, list_ca:num_items() - 1 do result[i + 1] = list_ca:item_at(i); end
  return result;
end

-- get primary military position of faction
local function tommy_get_primary_military_force_position(faction)
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
        _get_bool_str(not is_nil(targ_region)));
  return targ_x, targ_y, targ_region;
end

local MAPPING_PICKED_POSITIONS_COUNT = {};
local function _get_random_region_position_prevent_duplicated(region_name_list_patched,
                                                              initial_positions_of_region_expand)
  local attemp_max = 3;
  local attemp = 1;
  local found_position = nil
  local found_region_name = nil
  while attemp <= attemp_max and is_nil(found_position) do
    better_math_randomseed();
    local region_name_random_picked = region_name_list_patched[math.random(#region_name_list_patched)];
    local position_list = initial_positions_of_region_expand[region_name_random_picked];

    if (not is_nil(position_list)) then
      better_math_randomseed();
      local index_random = math.random(#position_list);
      local position = position_list[index_random];
      if (not is_nil(MAPPING_PICKED_POSITIONS_COUNT["" .. region_name_random_picked .. "_" .. index_random])) then
        found_position = position;
        found_region_name = region_name_random_picked;
        MAPPING_PICKED_POSITIONS_COUNT["" .. region_name_random_picked .. "_" .. index_random] = true;
      elseif (attemp >= 3) then
        local x, y = unpack(position);
        found_position = {x + random_split_2(0.66, 6), y + random_split_2(0.66, 6)};
        found_region_name = region_name_random_picked;
        MAPPING_PICKED_POSITIONS_COUNT["" .. region_name_random_picked .. "_" .. index_random] = true;
      end
    end
    attemp = attemp + 1;
  end

  return found_position, found_region_name;
end

function enable_region_tech_for_subculture_bandits(faction, faction_handle, region_primary)
  if (faction:subculture() == "3k_dlc05_subculture_bandits") then
    local faction_name = faction:name();
    local region_primary_name = region_primary:name();
    local region_short_name = string.match(region_primary_name, '^3k_main_(%w+)_(%w+).*');
    local prefix_tech = MAPPINT_REGION_NAME_TO_BANDIT_NETWORK_TECH_PREFIX[region_short_name];
    out("tommy_randomize_all_characters_for_faction() | " .. faction_name .. " at " .. region_primary_name ..
          " in short " .. region_short_name);
    if (is_nil(prefix_tech)) then return false; end
    local tech_key = "3k_dlc05_tech_bandit_network_" .. prefix_tech .. "_" .. region_short_name;
    local result_is_enabled = false;
    -- local result_is_enabled = faction_handle:begin_tech_research(tech_key)
    out("tommy_randomize_all_characters_for_faction() | " .. faction_name .. " at " .. region_short_name ..
          " | amied tech:" .. tech_key .. " " .. _get_bool_str(result_is_enabled));
    -- faction_handle:lock_technology(tech_key)
    -- faction_handle:unlock_technology(tech_key)
    -- if (faction_name == "3k_main_faction_zheng_jiang") then
    --   campaign_tutorial.faction_settings["3k_main_faction_zheng_jiang"] = {
    --     enemy_faction_key = "3k_main_faction_han_empire",
    --     target_settlement_key = region_primary_name,
    --     own_settlement_key = region_primary_name,
    --     own_settlement_building_index = 0,
    --     starting_force_position = nil,
    --     own_force_label_left = false,
    --     enemy_force_label_left = false
    --   }
    -- end

    return true;
  end
  return false;
end

-- randomize all characters for faction
local function tommy_randomize_all_characters_for_faction(context, faction, initial_positions_of_region_expand)
  out("tommy_randomize_all_characters_for_faction() | START of script | (" .. faction:name() .. ")");
  -- local character_list = faction:character_list();
  local region_list = faction:region_list();
  local region_list_world = cm:query_model():world():region_manager():region_list();
  local is_faction_local_me = tommy_is_faction_local_human(context, faction);
  local mforce_list = faction:military_force_list();

  local region_list_normal = tommy_list_ca_to_mormal_table(region_list);
  local region_list_world_normal = tommy_list_ca_to_mormal_table(region_list_world);
  local _, __, region_primary = tommy_get_primary_military_force_position(faction);
  local region_list_adjacent_normal = tommy_list_ca_to_mormal_table(region_primary:adjacent_region_list())

  local region_name_list = {};

  local is_faction_has_no_region = region_list:num_items() == 0;
  local is_faction_has_1_region = region_list:num_items() == 1;

  function get_region_name_list_from_adjacent()
    local result = {};
    local region_list_normal = region_list_adjacent_normal;
    for r = 1, #region_list_normal do result[r] = region_list_normal[r]:name(); end
    out("tommy_randomize_all_characters_for_faction() | " .. faction:name() .. " | from adjacent region," .. #result);
    return result;
  end

  function get_region_name_list_from_all()
    local result = {};
    local region_list_normal = region_list_world_normal;
    for r = 1, #region_list_normal do result[r] = region_list_normal[r]:name(); end
    out("tommy_randomize_all_characters_for_faction() | " .. faction:name() .. " | from all region," .. #result);
    return result;
  end

  if (faction:name() == "3k_main_faction_han_empire") then
    -- noop
    region_name_list = {}
  elseif (faction:name() == "3k_main_faction_liu_bei") then
    -- 190刘备, 选择初始区域的临近区域
    region_name_list = get_region_name_list_from_adjacent();
  elseif (faction:name() == "3k_dlc05_faction_sun_ce") then
    -- 194孙策, 选择初始区域的临近区域
    region_name_list = get_region_name_list_from_adjacent();
  elseif (is_faction_has_no_region) then
    -- 如果一个阵营没有初始地区，把地区池指定为全地图范围（然后就会全地图随机找个位置
    region_name_list = get_region_name_list_from_all();
  elseif (is_faction_has_1_region) then
    region_name_list = get_region_name_list_from_adjacent();
  else
    for r = 1, #region_list_normal do region_name_list[r] = region_list_normal[r]:name(); end
    out("tommy_randomize_all_characters_for_faction() | " .. faction:name() .. " | from own," .. region_list:num_items());
  end

  if (faction:has_faction_leader()) then faction_leader = faction:faction_leader(); end

  for i = 0, mforce_list:num_items() - 1 do
    local force = mforce_list:item_at(i);
    if force:is_armed_citizenry() == false and force:has_general() == true then
      local general = force:general_character();
      out("tommy_randomize_all_characters_for_faction() | " .. tommy_get_character_infomation_readable(general));
      -- 挑选不在建筑物的角色(例如在城市或者农庄铁矿), 在建筑物的角色状态和野战可能有差别，需要特殊处理
      -- 此处本作者认为不需要处理这些角色, 让他们呆在原地就行
      if not general:in_settlement() and not general:in_port() then
        local region_name_list_patched = {unpack(region_name_list)}; -- 复制一份list数据
        local region_name_list_patched_length = #region_name_list_patched;
        region_name_list_patched[region_name_list_patched_length + 1] = general:region():name();
        -- 1) 从当前角色所在地区(初始所在地区不等于拥有地区, 例如郑酱)和玩家拥有地区中随机选一个地区
        local position, region_name_random_picked = _get_random_region_position_prevent_duplicated(
                                                      region_name_list_patched, initial_positions_of_region_expand);
        out("tommy_randomize_all_characters_for_faction() | before teleport, pick:" .. region_name_random_picked ..
              " found_position:" .. _get_bool_str(not is_nil(position)));
        if (not is_nil(position)) then
          local final_x, final_y = unpack(position);
          final_x = final_x + random_split_2(1, 0.96);
          final_y = final_y + random_split_2(1, 0.96);
          out("tommy_randomize_all_characters_for_faction() | before teleport, pick:" .. region_name_random_picked ..
                " found_position:" .. final_x .. "," .. final_y);
          cm:teleport_character(general, final_x, final_y);
        end
      end
    end
  end

  if is_faction_local_me then
    local faction_handle = cm:modify_faction(faction:name());
    local key_event_handle = "3k_tommy_randomized_start_reposition_camera";
    if (cm:is_multiplayer()) then
      -- TODO: scroll_camera_from_current for multiplayer mode
    else
      out("tommy_randomize_all_characters_for_faction() | add_listener ScriptEventCampaignCutsceneCompleted");
      core:add_listener(key_event_handle, "ScriptEventCampaignCutsceneCompleted", true, function(e)
        out("tommy_randomize_all_characters_for_faction() | on ScriptEventCampaignCutsceneCompleted");
        _debug:try{
          function()
            if (cm:query_model():turn_number() > 1) then
              core:remove_listener(key_event_handle);
              return false;
            end
            core:remove_listener(key_event_handle);
            local x_primary, y_primary, region_primary = tommy_get_primary_military_force_position(faction);
            out(
              "tommy_randomize_all_characters_for_faction() | reposition camera | tommy_get_primary_military_force_position() " ..
                _get_bool_str(not is_nil(region_primary)));
            if (is_nil(region_primary)) then return false; end
            -- 让主要目标所在的区域可以显示
            faction_handle:make_region_seen_in_shroud(region_primary:name());
            faction_handle:make_region_visible_in_shroud(region_primary:name());
            -- for i = 0, region_list_world:num_items() - 1 do end
            local x, y, d, b, h = cm:get_camera_position();
            cm:callback(function()
              out("tommy_randomize_all_characters_for_faction() | reposition camera | x_faction_leader:" .. x_primary ..
                    ", y_faction_leader:" .. y_primary .. ", at:" .. region_primary:name());
              cm:scroll_camera_from_current(1.5, nil, {x_primary, y_primary, d, b, h});
              -- cm:set_camera_position(x_primary, y_primary, d, b, h);
            end, 1);

            -- if (region_primary:is_abandoned()) and is_faction_has_no_region then
            --   -- 如果初始区域是一个废弃区域就把这个区域设置给玩家
            --   cm:modify_model():get_modify_region(region_primary):settlement_gifted_as_if_by_payload(faction_handle);
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
          local faction_handle = cm:modify_faction(faction:name());
          local _, __, region_primary = tommy_get_primary_military_force_position(faction);
          out("tommy_randomize_all_characters_for_faction() | timeout:1 | faction:" .. faction:name() ..
                " final_region_primary:" .. region_primary:name() .. " subclture:" .. faction:subculture())
          if (region_primary:is_abandoned()) then
            -- 如果初始区域是一个废弃区域就把这个区域设置给玩家/AI
            cm:modify_model():get_modify_region(region_primary):settlement_gifted_as_if_by_payload(faction_handle);
          end
          enable_region_tech_for_subculture_bandits(faction, faction_handle, region_primary);
        end
      end, _debug:catch{function(error) script_error('3k_tommy_randomized_start.lua | CAUGHT ERROR: ' .. error); end}
    }
  end, 0.2);

  out("tommy_randomize_all_characters_for_faction() | END of script ");
end

local function _get_valid_spawn_location_in_region_until_different(faction, region_name, max_attemp)
  local spawn_round = 0;
  local attemp_ = max_attemp or 2
  local spawn_used_position_pool = {}
  local result = {};
  while (spawn_round < attemp_) do
    local is_found_spawn, spawn_x, spawn_y = faction:get_valid_spawn_location_in_region(region_name, true);
    if (not spawn_used_position_pool["" .. spawn_x .. "_" .. spawn_y]) and is_found_spawn then
      result[#result + 1] = {spawn_x, spawn_y, region_name}
    else
      spawn_round = spawn_round + 1;
    end
    spawn_used_position_pool["" .. spawn_x .. "_" .. spawn_y] = true;
  end
  return result;
end

local function _get_all_valid_positions_of_region(faction_list)
  local region_list_world = cm:query_model():world():region_manager():region_list();
  local region_list_world_raw = tommy_list_ca_to_mormal_table(region_list_world);
  local position_list = {}
  for f = 0, faction_list:num_items() - 1 do
    local faction = faction_list:item_at(f);
    local mforce_list = faction:military_force_list();
    if (not faction:is_dead()) then
      out("tommy_randomize_start() | _get_all_valid_positions_of_region() | " .. faction:name());

      -- get initial military force positions in wild
      for i = 0, mforce_list:num_items() - 1 do
        local force = mforce_list:item_at(i);
        if force:is_armed_citizenry() == false and force:has_general() == true then
          local general = force:general_character();
          if not general:in_settlement() and not general:in_port() then
            local general_x = general:logical_position_x();
            local general_y = general:logical_position_y();
            position_list[#position_list + 1] = {general_x, general_y, general:region():name(), true}
          end
        end
      end

      -- get spawn position from CA get_valid_spawn_location_in_region API
      for j = 1, #region_list_world_raw do
        local region = region_list_world_raw[j]
        local positions_region_spawn = _get_valid_spawn_location_in_region_until_different(faction, region:name(), 3)
        for k = 1, #positions_region_spawn do
          local x, y, region_name = unpack(positions_region_spawn[k]);
          position_list[#position_list + 1] = {x, y, region_name, false}
        end
      end
    end
  end

  local position_region_mapping = {}

  out("tommy_randomize_start() | _get_all_valid_positions_of_region() | position_region_mapping from list, " ..
        #position_list);

  for p = 1, #position_list do
    local x, y, region_name, is_default = unpack(position_list[p]);
    local mapping = position_region_mapping[region_name]
    if (is_nil(mapping)) then mapping = {} end
    mapping["" .. x .. "," .. y] = {x, y, is_default};
    position_region_mapping[region_name] = mapping;
  end

  return position_region_mapping;
end

-- main function
local function tommy_randomize_start(context)
  out("tommy_randomize_start() | START of script ");
  if not cm:is_new_game() then
    out("tommy_randomize_start() | not cm:is_new_game()");
    return false;
  end
  out("tommy_randomize_start() | cm:is_new_game()");
  MAPPING_PICKED_POSITIONS_COUNT = {}

  local faction_list = cm:query_model():world():faction_list();
  local initial_positions_of_region = _get_all_valid_positions_of_region(faction_list);

  local initial_positions_of_region_expand = {}
  for region_name, position_list in pairs(initial_positions_of_region) do
    local count = 0;
    local position_list_expand = {}
    for _, position in pairs(position_list) do
      count = count + 1;
      local x, y, is_default = unpack(position);
      out("tommy_randomize_start() | " .. region_name .. ": " .. x .. "," .. y .. "," .. _get_bool_str(is_default));
      local random_offset_x = 0;
      local random_offset_y = 0;
      if (is_default) then
        count = count + 1;
        random_offset_x = random_split_2(0.6, 3);
        random_offset_y = random_split_2(0.6, 3);
        position_list_expand[#position_list_expand + 1] = {x + random_offset_x, y + random_offset_y}
        out("tommy_randomize_start() | " .. region_name .. ": " .. x + random_offset_x .. "," .. y + random_offset_y ..
              ", expanded");
      else
        position_list_expand[#position_list_expand + 1] = {x, y}
        if (not is_nil(REGION_DONT_SPAWN_TOO_MUCH[region_name])) then
          count = count + 1;
          random_offset_x = random_split_2(0.6, 1);
          random_offset_y = random_split_2(0.6, 1);
          position_list_expand[#position_list_expand + 1] = {x + random_offset_x, y + random_offset_y}
          out(
            "tommy_randomize_start() | " .. region_name .. ": " .. x + random_offset_x .. "," .. y + random_offset_y ..
              ", expanded");
          count = count + 1;
          random_offset_x = random_split_2(1, 1.6);
          random_offset_x = random_split_2(1, 1.6);
          position_list_expand[#position_list_expand + 1] = {x + random_offset_x, y + random_offset_y}
          out(
            "tommy_randomize_start() | " .. region_name .. ": " .. x + random_offset_x .. "," .. y + random_offset_y ..
              ", expanded");
        else
          count = count + 1;
          random_offset_x = random_split_2(0.6, 5);
          random_offset_y = random_split_2(0.6, 5);
          position_list_expand[#position_list_expand + 1] = {x + random_offset_x, y + random_offset_y}
          out(
            "tommy_randomize_start() | " .. region_name .. ": " .. x + random_offset_x .. "," .. y + random_offset_y ..
              ", expanded");
          count = count + 1;
          random_offset_x = random_split_2(2, 6.6);
          random_offset_y = random_split_2(2, 6.6);
          position_list_expand[#position_list_expand + 1] = {x + random_offset_x, y + random_offset_y}
          out(
            "tommy_randomize_start() | " .. region_name .. ": " .. x + random_offset_x .. "," .. y + random_offset_y ..
              ", expanded");
          count = count + 1;
          random_offset_x = random_split_2(2, 10);
          random_offset_y = random_split_2(2, 10);
          position_list_expand[#position_list_expand + 1] = {x + random_offset_x, y + random_offset_y}
          out(
            "tommy_randomize_start() | " .. region_name .. ": " .. x + random_offset_x .. "," .. y + random_offset_y ..
              ", expanded");
        end
      end
    end
    out("tommy_randomize_start() | " .. region_name .. " has " .. count);
    initial_positions_of_region_expand[region_name] = position_list_expand;
  end

  for f = 0, faction_list:num_items() - 1 do
    local faction = faction_list:item_at(f);
    local isHasMilitaryForceFaction = not faction:military_force_list():is_empty();
    if (isHasMilitaryForceFaction and not faction:is_null_interface() and not faction:is_dead()) then
      tommy_randomize_all_characters_for_faction(context, faction, initial_positions_of_region_expand);
    end
    -- if faction:is_human() then
    --   local isHasMilitaryForceFaction = not faction:military_force_list():is_empty();
    --   if (isHasMilitaryForceFaction) then tommy_randomize_all_characters_for_faction(faction); end
    -- end
  end

  out("tommy_randomize_start() | END of script ");
end

local function RUN_tommy_randomize_start(context)
  if (_debug.is_debug) then
    out('3k_tommy_randomized_start.lua | run debug');
    _debug:try{
      function() tommy_randomize_start(context); end,
      _debug:catch{function(error) script_error('3k_tommy_randomized_start.lua | CAUGHT ERROR: ' .. error); end}
    }
  else
    out('3k_tommy_randomized_start.lua | run');
    tommy_randomize_start(context);
  end
  out('3k_tommy_randomized_start.lua | end');
  return true;
end

cm:add_first_tick_callback(function(context) RUN_tommy_randomize_start(context) end);
-- cm:add_first_tick_callback_sp_new(function(context) RUN_tommy_randomize_start(context) end);
-- cm:add_first_tick_callback_mp_new(function(context) RUN_tommy_randomize_start(context) end);
-- events = get_events();
-- events.FirstTickAfterWorldCreated[#events.FirstTickAfterWorldCreated+1] =
-- cm.first_tick_callbacks[#cm.first_tick_callbacks + 1] = 

out("common_tommy_randomized_start.lua ****************");

package.path = package.path ..';../?.lua';

-- local _debug = require("common_tommy_debug_try_catch")

local _debug = {is_debug = true}

function _debug:catch(what) return what[1] end

function _debug:try(what)
  if (not _debug.is_debug) then return what[2](result); end
  status, result = pcall(what[1])
  if not status then what[2](result) end
  return result
end

local common_tommy_randomized_start = {}

local random_call_offset = 0;
local function better_math_randomseed()
  random_call_offset = random_call_offset + 1;
  math.randomseed(tonumber(tostring(6 * random_call_offset + os.time() * 2 * random_call_offset):reverse():sub(1, 8)));
  if (random_call_offset > 100) then random_call_offset = 0; end
end

function common_tommy_randomized_start.better_math_randomseed()
  return better_math_randomseed()
end

local function random_split_2(min, range)
  local rangeToRand = (min + range);
  better_math_randomseed();
  local randIntl = (math.random() * rangeToRand * 2) - (rangeToRand);
  local edgeLeftIntl = ((randIntl / math.abs(randIntl)) * min);
  return edgeLeftIntl + (randIntl - edgeLeftIntl);
end

function common_tommy_randomized_start.random_split_2(min, range)
  return random_split_2(min, range)
end

local function _is_faction_local_human(context, faction, params)
  local model = params.cm_query_model()
  return faction:is_human() and faction:name() == params.cm_local_faction_name()
end

function common_tommy_randomized_start.is_faction_local_human(context, faction, params)
  return _is_faction_local_human(context, faction, params)
end

local function _get_character_name_readable(character)
  local str_name_localised_string = effect.get_localised_string(character:get_surname());
  local str_forename_localised_string = effect.get_localised_string(character:get_forename());
  return ("" .. str_name_localised_string .. "" .. str_forename_localised_string .. "");
end

local function _get_bool_str(boo) return (boo and "true" or "false"); end

function common_tommy_randomized_start.get_bool_str(boo)
  return _get_bool_str(boo)
end

-- get character info mation readable
local function _get_character_infomation_readable(character)
  return ("character:" .. _get_character_name_readable(character) .. ", faction[" .. character:faction():name() ..
           "], logical pos[" .. character:logical_position_x() .. ", " .. character:logical_position_y() ..
           "], display pos[" .. character:display_position_x() .. ", " .. character:display_position_y() ..
           "], has_region:" .. _get_bool_str(character:has_region()) .. ", in_settlement:" ..
           _get_bool_str(character:in_settlement()));
end

function common_tommy_randomized_start.get_character_infomation_readable(context, faction)
  return _get_character_infomation_readable(context, faction)
end

local function _list_ca_to_mormal_table(list_ca)
  local result = {}
  for i = 0, list_ca:num_items() - 1 do result[i + 1] = list_ca:item_at(i); end
  return result;
end

function common_tommy_randomized_start.list_ca_to_mormal_table(region_list)
  return _list_ca_to_mormal_table(region_list)
end

-- main function
local function tommy_randomize_start(context, params)
  out("tommy_randomize_start() | START of script ");
  if not cm:is_new_game() then
    out("tommy_randomize_start() | not cm:is_new_game()");
    return false;
  end
  out("tommy_randomize_start() | cm:is_new_game()");
  MAPPING_PICKED_POSITIONS_COUNT = {}

  local faction_list = params.cm_query_model():world():faction_list();

  for f = 0, faction_list:num_items() - 1 do
    local faction = faction_list:item_at(f);
    local isHasMilitaryForceFaction = not faction:military_force_list():is_empty();
    if (isHasMilitaryForceFaction and not faction:is_null_interface() and not faction:is_dead()) then
      params.randomizer(context, faction, params);
    end
    -- if faction:is_human() then
    --   local isHasMilitaryForceFaction = not faction:military_force_list():is_empty();
    --   if (isHasMilitaryForceFaction) then tommy_randomize_all_characters_for_faction(faction); end
    -- end
  end

  out("tommy_randomize_start() | END of script ");
end

function common_tommy_randomized_start.run(context, params)
  if (_debug.is_debug) then
    out('3k_tommy_randomized_start.lua | run debug');
    _debug:try{
      function() tommy_randomize_start(context, params); end,
      _debug:catch{function(error) script_error('3k_tommy_randomized_start.lua | CAUGHT ERROR: ' .. error); end}
    }
  else
    out('3k_tommy_randomized_start.lua | run');
    tommy_randomize_start(context, params);
  end
  out('3k_tommy_randomized_start.lua | end');
  return true;
end

return common_tommy_randomized_start

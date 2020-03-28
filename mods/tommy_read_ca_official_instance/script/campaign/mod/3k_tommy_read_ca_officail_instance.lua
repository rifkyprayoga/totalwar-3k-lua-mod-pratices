local _debug = {is_debug = true}

function _debug:catch(what) return what[1] end

function _debug:try(what)
  if (not _debug.is_debug) then return what[2](result); end
  status, result = pcall(what[1])
  if not status then what[2](result) end
  return result
end

cm:add_first_tick_callback(function(context) 
  out("3k_tommy_read_ca_officail_instance ------ START")

  _debug:try {
    function()
      for key, _ in pairs(getmetatable(core)) do 
        out("global core:"..key);
      end
    
      out("3k_tommy_read_ca_officail_instance ------")
    
      for key, _ in pairs(getmetatable(cm)) do 
        out("global cm:"..key);
      end
    
      out("3k_tommy_read_ca_officail_instance ------")
    
      local faction_list = cm:query_model():world():faction_list();
      local faction_0 = faction_list:item_at(0);
      local faction_handle = cm:modify_faction(faction_0:name());
    
      for key, _ in pairs(getmetatable(faction_handle)) do 
        out("instance modify_faction:"..key);
      end
    
      out("3k_tommy_read_ca_officail_instance ------")
    
      local region_list_world = cm:query_model():world():region_manager():region_list();
      local region_0 = region_list_world:item_at(0);
    
      local region_handle = cm:modify_region(region_0:name());
    
      for key, _ in pairs(getmetatable(region_0)) do 
        out("instance region_0:"..key);
      end
    
      for key, _ in pairs(getmetatable(region_handle)) do 
        out("instance region_handle:"..key);
      end
    end,
    _debug:catch{function(error) script_error('3k_tommy_randomized_start.lua | CAUGHT ERROR: ' .. error); end}
  }
  
  out("3k_tommy_read_ca_officail_instance ------ END")
end);

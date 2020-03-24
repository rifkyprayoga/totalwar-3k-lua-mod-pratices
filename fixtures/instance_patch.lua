local proto = {};

function proto:new()
  return self;
end

function proto:method()
  return 1;
end

local obj = proto:new();

print(obj:method()) -- 1

obj.method_origin = obj.method;

function obj:method()
  return self:method_origin() + 1;
end

print(obj:method()) -- 2

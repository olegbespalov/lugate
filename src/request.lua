----------------------
-- The lugate module.
-- Lugate is a lua module for building JSON-RPC 2.0 Gateway APIs just inside of your Nginx configuration file.
-- Lugate is meant to be used with [ngx\_http\_lua\_module](https://github.com/openresty/lua-nginx-module) together.
--
-- @classmod request
-- @author Ivan Zinovyev <vanyazin@gmail.com>
-- @license MIT

--- Json encoder/decoder
local json = require "rapidjson"

--- Request obeject
local Request = {}

--- Create new request
-- return[type=table] New request instance
function Request:new(data)
  local request = setmetatable({}, Request)
  self.__index = self
  request.data = data

  return request
end

--- Check if request is valid JSON-RPC 2.0
-- @return[type=boolean]
function Request:is_valid()
  if nil == self.valid then
    self.valid = self.data and self.data['jsonrpc'] and self.data['method'] and self.data['params'] and self.data['id'] and true or false
  end

  return self.valid
end

--- Check if request is a valid Lugate proxy call over JSON-RPC 2.0
-- @param[type=table] data Decoded request body
-- @return[type=boolean]
function Request:is_proxy_call()
  if nil == self.proxy_call then
    self.proxy_call = self:is_valid() and self.data.params['route'] and self.data.params['params'] and self.data.params['cache'] and true or false
  end

  return self.proxy_call
end

function Request:get_jsonrpc()
  return self.data.jsonrpc
end

--- Get method name
-- @retur[type=string]
function Request:get_method()
  return self.data.method
end

--- Get request params
-- @retur[type=table]
function Request:get_params()
  return self.is_proxy_call() and self.params.params or self.params
end

--- Get request id
-- @retur[type=int]
function Request:get_id()
  return self.data.id
end

--- Get request route
-- @return[type=string]
function Request:get_route()
  return self:is_proxy_call() and self.params.route or nil
end

--- Get request cache param
-- @return[type=string]
function Request:get_cache()
  return self:is_proxy_call() and self.params.cache or false
end

--- Get request data table
-- @return[type=table]
function Request:get_data()
  return {
    jsonrpc = self:get_jsonrpc(),
    id = self:get_id(),
    method = self:get_method(),
    params = self:get_params()
  }
end

--- Get request body
-- @return[type=string] Json array
function Request:get_body()
  return json.encode(Request:get_data())
end

return Request
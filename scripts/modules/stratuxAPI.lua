local WebSockets = require("plugin.websockets")
local Json = require( "json" )

local M = {}

--local privateVariable
--local privateFunction = function() end
--M.publicFunction = function() end

local deviceHttpUrl = "http://192.168.1.1"
local deviceWsUrl = "ws://192.168.1.1"


local urls = {
  -- Settings
  getSettings   = "/getSettings",  -- GET
  radar         = "/radar",        -- SOCK
  -- Status
  getStatus     = "/getStatus",    -- GET
  getStatus     = "/status",       -- SOCK
  -- Situation
  getSituation  = "/getSituation", -- GET
  situation     = "/situation",    -- SOCK
  -- Satellites
  getSatellites = "/getSatellites",  -- GET
  -- Towers
  getTowers     = "/getTowers",    -- GET
  -- Traffic
  traffic       = "/traffic",      -- SOCK
  -- Weather
  weather       = "/weather",      -- SOCK
  -- Shutdown, Restart, Reboot
  shutdown      = "/shutdown",     -- POST
  restart       = "/restart",      -- POST
  reboot        = "/reboot",       -- POST
  -- To be tested
  downloadlog   = "/downloadlog",    -- POST
  deletelogfile = "/deletelogfile",  -- POST
  downloadahrslogs = "/downloadahrslogs", -- POST
  deletaahrslogfiles = "/deleteahrslogfiles",  -- POST
  developer     = "/developer", -- SOCK
  develmodetoggle = "/develmodetoggle", -- GET
  cageAHRS      = "/cageAHRS", -- POST
  calibrateAHRS = "/calibrateAHRS", -- POST
  orientAHRS    = "/orientAHRS", -- POST
  resetGMeter   = "/resetGMeter", -- POST
  setSettings   = "/setSettings", -- POST
  updateUpload  = "/updateUpload", -- POST
}



--
-- testing...
--

local function httpListener( event )
  if ( event.isError ) then
      print( "Network error: ", event.response )
  else
      print ( "RESPONSE: " .. event.response )
  end
end


local function postTest()
  local headers = {}
  headers["Content-Type"] = "text/json"
  --headers["Accept-Language"] = "en-US"
    
  local body = ""
  local params = {}
  params.headers = headers
  params.body = body
  network.request( "http://192.168.1.1/shutdown", "POST", networkListener, params )
end



local wsApiSituation

local function wsApiSituationListener(event)
    if event.type == wsApiSituation.ONOPEN then
      print('connected')
      --wsApiSituation:send("Connected to Situation provider")
    elseif event.type == wsApiSituation.ONMESSAGE then
      --print('Received Message from Situation provider')
      --print(event.data) --> message data

      local decoded, pos, msg = Json.decode( event.data )
      if not decoded then
          print( "Decode failed at "..tostring(pos)..": "..tostring(msg) )
      else
          local pitch = decoded["AHRSPitch"]
          local roll = decoded["AHRSRoll"]

          --print(pitch, roll)

          local attitudeEvent = { 
            name="ahrsAttitudeStratux", 
            roll=roll, 
            pitch=pitch, 
            yaw=0 
          }
          Runtime:dispatchEvent( attitudeEvent )  
    
      end

    elseif event.type == wsApiSituation.ONCLOSE then
      print('disconnected from Situation Provider')
      print(event.code, event.reason) --> closure code and reason
    elseif event.type == wsApiSituation.ONERROR then
      print('error in Situation Provider')
      print(event.code, event.reason) --> error code and reason
    end
  end


  local function apiGetStatusResponder( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
    else
        print ( "Status RESPONSE: " .. event.response )
        local decoded, pos, msg = Json.decode( event.response )
        if not decoded then
            print( "Decode failed at "..tostring(pos)..": "..tostring(msg) )
        else
          print()
          for key, value in pairs (decoded) do
            print(key..": ", value)
          end 
        end
    end
  end





M.create = function()
    wsApiSituation = WebSockets.new()
    wsApiSituation:addEventListener(wsApiSituation.WSEVENT, wsApiSituationListener)
    ----ws:connect('ws://demos.kaazing.com/echo')
    wsApiSituation:connect('ws://192.168.1.1/situation')
    
    --network.request( deviceHttpUrl..urls.getStatus, "GET", apiGetStatusResponder, {headers={["Content-Type"] = "text/json"}} )
    --network.request( "http://192.168.1.1/getStatus", "GET", apiGetStatusResponder )
    


    --postTest()


end


M.destroy = function()
    wsApiSituation:disconnect()
    wsapiSituation:removeEventListener(wsApiSituation.WSEVENT, wsApiSituationListener)
end


return M

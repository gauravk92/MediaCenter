-- <configuration> -- 
tvIpAddress = "10.0.0.22" 
tvPort = 55000 
keycodestring = "KEY_POWEROFF" 

tvAuthString = string.char(0x00,0x14,0x00,0x69,0x70,0x68,0x6f,0x6e,0x65,0x2e,0x2e,0x69,0x61,0x70,0x70,0x2e,0x73,0x61,0x6d,0x73,0x75,0x6e,0x67,0x38,0x00,0x64,0x00,0x14,0x00,0x4d,0x54,0x6b,0x79,0x4c,0x6a,0x45,0x32,0x4f,0x43,0x34,0x77,0x4c,0x6a,0x45,0x78,0x4d,0x41,0x3d,0x3d,0x18,0x00,0x4e,0x45,0x4d,0x74,0x4e,0x7a,0x49,0x74,0x51,0x6a,0x6b,0x74,0x4e,0x44,0x4d,0x74,0x4d,0x6a,0x51,0x74,0x4f,0x45,0x49,0x3d,0x04,0x00,0x54,0x51,0x3d,0x3d)
-- </configuration> -- 

-- character table string 
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' 

-- encoding to base64 
function enc(data) 
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte() 
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end 
        return r; 
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x) 
        if (#x < 6) then return '' end 
        local c=0 
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end 
        return b:sub(c+1,c+1) 
    end)..({ '', '==', '=' })[#data%3+1]) 
end 

-- helper function 
function num2bytes(num)    
    local retStr="" 
    for i=1,2 do 
        retStr = retStr .. string.char(num%256) 
        num = math.floor(num/256) 
    end 
      return retStr 
end 

tcpSocket = Net.FTcpSocket(tvIpAddress, tvPort) 

-- say hello to the TV ;) 
bytes, errorCode = tcpSocket:write(tvAuthString) 

keycodebase = string.char(0x00,0x13,0x00,0x69,0x70,0x68,0x6f,0x6e,0x65,0x2e,0x69,0x61,0x70,0x70,0x2e,0x73,0x61,0x6d,0x73,0x75,0x6e,0x67) 

-- payload 
payloadinit = string.char(0x00,0x00,0x00) 
keycode = enc(keycodestring) 

keycodesize = num2bytes(string.len(keycode)) 

payloadsize = num2bytes(string.len(payloadinit .. keycode ..keycodesize)) 

-- combining the message 
message = keycodebase .. payloadsize .. payloadinit .. keycodesize .. keycode 

-- sending keycode 
bytes, errorCode2 = tcpSocket:write(message) 

if errorCode == 0 and errorCode2 == 0 
then 
  -- printing log under virtual device 
  fibaro:log("transfer OK: " .. keycodestring) 
else 
  fibaro:log("transfer failed") 
end

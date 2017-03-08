var chr = String.fromCharCode,
base64Encode = btoa;

var config = {};

config.host = {
ip: "10.0.0.200",
mac: "00:00:00:00",
name: "NodeJS Samsung Remote"
};

var command = "KEY_POWEROFF";

config.appString = "iphone..iapp.samsung";
config.tvAppString = "iphone.UN60D6000.iapp.samsung";
config.port = 55000;
config.timeout = 5000;

var _socketChunkOne = function () {
    var ipEncoded = base64Encode(config.host.ip),
    macEncoded = base64Encode(config.host.mac);
    
    var message = chr(0x64) +
    chr(0x00) +
    chr(ipEncoded.length) +
    chr(0x00) +
    ipEncoded +
    chr(macEncoded.length) +
    chr(0x00) +
    macEncoded +
    chr(base64Encode(config.host.name).length) +
    chr(0x00) +
    base64Encode(config.host.name);
    
    return chr(0x00) +
    chr(config.appString.length) +
    chr(0x00) +
    config.appString +
    chr(message.length) +
    chr(0x00) +
    message;
},
_socketChunkTwo = function(command) {
    var message = chr(0x00) +
    chr(0x00) +
    chr(0x00) +
    chr(base64Encode(command).length) +
    chr(0x00) +
    base64Encode(command);
    
    return chr(0x00) +
    chr(config.tvAppString.length) +
    chr(0x00) +
    config.tvAppString +
    chr(message.length) +
    chr(0x00) +
    message;
};

var chunkOne = _socketChunkOne();
var chunkTwo = _socketChunkTwo(command);

console.log(encodeURI(chunkOne));
console.log(encodeURI(chunkTwo));
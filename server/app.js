/*jslint node: true */
"use strict";

var express = require('express');
var SamsungRemote = require('samsung-remote');
var remote = new SamsungRemote({
    ip: '10.0.0.200' // required: IP address of your Samsung Smart TV
});


//
//// check if TV is alive (ping)
//remote.isAlive(function(err) {
//    if (err) {
//        throw new Error('TV is offline');
//    } else {
//        console.log('TV is ALIVE!');
//    }
//});


var app = express();

app.set('view options', {
    layout: false
});

// This will route requests to the 'public' folder
//app.use(express.static(path.join(__dirname, 'public'), {
//    maxAge: 0
//}));

app.get('/k/:id', function(req, res) {

    var id = req.params['id'];
    
    remote.send(id, function callback(err) {
        if (err) {
            res.send(JSON.stringify({'success': false}));
            //throw new Error(err);
        } else {
            res.send(JSON.stringify({'success': true}));
            // command has been successfully transmitted to your tv
        }
    });
    
    //response.send(id);
    //res.send({'success':true});
});

app.listen(9000);

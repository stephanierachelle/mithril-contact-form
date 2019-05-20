//The Node Event Emitter

/*var events = require('events');
var util = require('util');

var Person = function(name){
    this.name = name;
};

util.inherits(Person, events.EventEmitter);

var james = new Person ('james');
var mary = new Person ('mary');
var ryu = new Person ('ryu');
var people = [james, mary, ryu];

people.forEach(function(person){
    person.on('speak', function(msg){
        console.log(person.name + ' said:' + msg )
    });
});

james.emit('speak', 'hey dudes');
ryu.emit('speak', 'I want a curry');*/

//Reading and Writing Files (fs)

/*var fs = require('fs');

fs.readFile('readMe.txt', 'utf8', function(err, data){
    fs.writeFile('writeMe.txt', data);
}); 
    */

//fs.writeFileSync('writeMe.txt', readMe); //creates new file

// code
/*

var fs = require('fs');

fs.unlink('writeMe.txt'); //deletes file

*/

// Creating directories 
/*
var fs = require('fs');

fs.rmdirSync('stuff');
*/

////////////////////////////////////////
//Clients & Servers
///////////////////////////////////////
// how to make a server HTTP module.
/*
var http = require('http');

var server = http.createServer(function(req, res){
    console.log('request was made: ' + req.url);
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hey ninjas');
});

server.listen(3000, '127.0.0.1');
console.log('yo, now listening to port 3000');
*/
/*
var http = require('http');
var fs = require('fs');

var myReadStream= fs.createReadStream(__dirname + '/readMe.txt', 'utf8');
var myWriteStream= fs.createWriteStream(__dirname + '/writeMe.txt');

myReadStream.on('data', function(chunk){
    console.log('new chunk received:');
    myWriteStream.write(chunk);
});

*/

//////////////////////////////////
//PIPING READ AND WRITE
/////////////////////////////////

var http = require('http');
var fs = require('fs');

var server = http.createServer(function(req, res){
    console.log('request was made: ' + req.url);
    res.writeHead(200, {'Content-Type': 'text/html'});
    var myReadStream= fs.createReadStream(__dirname + '/server.html', 'utf8');
    myReadStream.pipe(res); //ends response - sends data down the stream and responds to the client. 
});

server.listen(3000, '127.0.0.1');
console.log('yo, now listening to port 3000');

//////////////////////////////////
// SERVING HTML PAGES
/////////////////////////////////




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

var fs = require('fs');

var readMe = fs.readFileSync('readMe.txt', 'utf8');
fs.writeFileSync('writeMe.txt', readMe); //creates new file

// code

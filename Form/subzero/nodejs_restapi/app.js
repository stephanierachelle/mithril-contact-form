// load our app server using express somehow....
const express = require('express')
const app = express()
const morgan = require('morgan')
const mysql = require('mysql')

app.use(express.static('./src'))

app.use(morgan('short'))

app.post('/user_create', (req, res) => {
    console.log("trying to create a new user....")
    res.end()
})

app.get('/user/:id', (req, res) => {
    console.log("fetching user with id: " + req.params.id)

    const connection = mysql.createConnection({
        host: 'localhost',
        user: 'root',
        database: 'your_database'
    })

    //Apparently this is how we use subzero to connect
    const userID = req.params.id;
    const queryString = "SELECT * FROM users WHERE id = ?"
    connection.query(queryString, [userID], (err, rows, fields) => {

        if (err) {
            console.log("Failed to query for users: " + err)
            res.sendStatus(500)
            return
        }
        console.log("I think we fetched users successfully")

        const users = rows.map((row) => {
            return {firstName: row.firstName, lastName: row.lastName}
        })
        res.json(users)
    })

    //res.end();
})

app.get("/", (req, res) => {
    console.log("responding to route route")
    res.send("hello from roooot")
})

app.get("/users", (req, res) => {
    var user1 = {firstName: "Steph", lastName: "Curry"}
    const user2 = {firstName: "Kev", lastName: "Durant"}
    res.json([user1, user2])
})



// local host: 3003
app.listen(3003, () => {
    console.log("server is up and listening on 3003....")
})

const express = require('express');
const app = express();
const port = 3000;

const SECRET_WORD = process.env.SECRET_WORD || 'default_secret';

// Route for the home page
app.get('/', (req, res) => {
    res.send(`<h1>Welcome to the Secret Word App!</h1><p><a href="/secret_word">Get the Secret Word</a></p>`);
});

// Route to display the secret word
app.get('/secret_word', (req, res) => {
    res.send(`<h1>The Secret Word is: ${SECRET_WORD}</h1>`);
});

// Docker route for checking if app is running inside Docker container
app.get('/docker', (req, res) => {
    res.send('<h1>Running inside Docker</h1>');
});

// Load Balancer Check
app.get('/loadbalanced', (req, res) => {
    res.send('<h1>Load Balancer Check</h1>');
});

// TLS Check
app.get('/tls', (req, res) => {
    res.send('<h1>TLS Check</h1>');
});

app.listen(port, () => {
    console.log(`App listening at http://localhost:${port}`);
});

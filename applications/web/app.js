const axios = require("axios");
const path = require("path");
const express = require("express");
const app = express();
require("dotenv").config();
const port = process.env.PORT || 3000;

app.set('views', path.join(__dirname, 'public/views'));
app.set('view engine', 'ejs');

app.get('/', function(_, res) {

  axios.get('http://ifconfig.me')
  .then(callresp => {
    const ip = callresp.data;
    res.render('pages/index', {
      ip: ip
    });
  })
  .catch(err => {
    console.log('Error: ', err.message);
  });

});

app.listen(port, () => {
  console.log(`Listening: http://localhost:${port}`);
});

const axios = require("axios");
const path = require("path");
const express = require("express");
const app = express();
require("dotenv").config();
const port = process.env.PORT || 3000;
const dateurl = process.env.DATE_API_URL || 'http://localhost:3000';

app.set('views', path.join(__dirname, 'public/views'));
app.set('view engine', 'ejs');

app.get('/', function(_, res) {

  axios.get(dateurl + '/api/date')
  .then(callresp => {
    const datetime = callresp.data;
    res.render('pages/index', {
      datetime: datetime
    });
  })
  .catch(err => {
    console.log('Error: ', err.message);
  });

});

app.listen(port, () => {
  console.log(`Listening: http://localhost:${port}`);
});

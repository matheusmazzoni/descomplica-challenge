const express = require("express");
require("dotenv").config();
const app = express();

// Routes
// app.get('/api/health', function(req, res) {

// });

app.get('/api/date', function(req, res) {
  const datetime = new Date().toUTCString();
  return res.status(200).send(datetime);
});


const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Listening: http://localhost:${port}`);
});

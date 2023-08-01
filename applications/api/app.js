const express = require("express");
require("dotenv").config();
const app = express();

// Routes
app.get('/api/sleep', function(req, res) {
  const datetime = new Date().toUTCString();
  doSomething();
  return res.status(200).send(datetime);
});

async function doSomething() {
  console.log("Begin");
  await sleep(process.env.SLEEP_TIME);
  console.log("End");
}

function sleep(ms) {
  console.log(ms);
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}


const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Listening: http://localhost:${port}`);
});

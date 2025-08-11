const express = require("express");
const bodyParser = require("body-parser");
const mysql = require("mysql2");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(bodyParser.json({ limit: "10mb" })); // Allow large images

// MySQL connection
const db = mysql.createConnection({
  host: "localhost",
  user: "root", // your MySQL username
  password: "YOUR_PASSWORD",
  database: "myapp_db"
});

db.connect(err => {
  if (err) throw err;
  console.log("✅ MySQL Connected...");
});

// Add product API
app.post("/addProduct", (req, res) => {
  const { farmer_uid, product_name, image, timestamp } = req.body;

  if (!farmer_uid || !product_name || !image || !timestamp) {
    return res.status(400).send("Missing fields");
  }

  const imgBuffer = Buffer.from(image, "base64");

  const sql = "INSERT INTO products (farmer_uid, product_name, image, timestamp) VALUES (?, ?, ?, ?)";
  db.query(sql, [farmer_uid, product_name, imgBuffer, timestamp], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).send("Database error");
    }
    res.status(200).send("Product added successfully");
  });
});

// Fetch all products
app.get("/products", (req, res) => {
  db.query("SELECT id, farmer_uid, product_name, timestamp FROM products", (err, results) => {
    if (err) return res.status(500).send("Database error");
    res.json(results);
  });
});

app.listen(5000, () => console.log("🚀 Server running on port 5000"));

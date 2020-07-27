const express = require("express");
const app = express();
const { resolve } = require("path");
// This is a sample test API key. Sign in to see examples pre-filled with your key.
const stripe = require("stripe")("pk_test_51H5xzUCzY7u6lWFYbQg9CjRYyMZ7ONk4AXbcf7fAm2PqLu9afzjv0rSCHQ9zUXnBdSqK8kLs3Xd3bJiy5Easd1xC00d3xbdPOU");

app.use(express.static("."));
app.use(express.json());

const calculateOrderAmount = items => {
    // Replace this constant with a calculation of the order's amount
    // Calculate the order total on the server to prevent
    // people from directly manipulating the amount on the client
    return 7 * 100;
};

app.post("/create-payment-intent", async (req, res) => {
    const { items } = req.body;
    // Create a PaymentIntent with the order amount and currency
    const paymentIntent = await stripe.paymentIntents.create({
    amount: calculateOrderAmount(items),
    currency: "usd",
    transfer_group: null
    });
    
    res.send({
    clientSecret: paymentIntent.client_secret
    });
});

app.listen(4242, () => console.log('Node server listening on port 4242!'));

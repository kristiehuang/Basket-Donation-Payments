const express = require("express");
const app = express();
const { resolve } = require("path");

const env = require("dotenv").config({ path: "./.env" });
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);

app.use(express.static("."));
app.use(express.json());

app.post("/create-payment-intent", async (req, res) => {
    const { currency, totalAmount, basketItems, customer, transferGroup } = req.body;
    // Create a PaymentIntent with the order amount and currency
    const paymentIntent = await stripe.paymentIntents.create({
        amount: totalAmount,
        currency: currency,
        customer: customer,
    });

    res.send({
        clientSecret: paymentIntent.client_secret,
        paymentId: paymentIntent.id
    });
});

app.post("/create-new-customer", async (req, res) => {
    const { fullName, email } = req.body;
    // Create a new Stripe Customer with the order amount and currency
    const customer = await stripe.customers.create({
        name: fullName,
        email: email
    });

    res.send({
        id: customer.id
    });
});

app.post("/create-new-connected-account", async (req, res) => {
    const { authorizationCode, email } = req.body;
    // Create a new Stripe Connected Account with the return authorizationCode and email address.
    const response = await stripe.oauth.token({
        grant_type: 'authorization_code',
        code: authorizationCode,
        email: email
    });

    res.send({
        connectedAccountId: response.stripe_user_id
    });
});

app.post("/create-transfer", async (req, res) => {
    const { amount, currency, destination, source_transaction } = req.body;
    // Create a new Stripe Customer with the order amount and currency
    const response = await stripe.transfers.create({
        amount: amount,
        currency: currency,
        destination: destination,
        source_transaction: source_transaction
    });

    res.send({
        transferId: response.id
    });
});


const calculateTransferAmount = (totalAmount, basketItems) => {
    // Replace this constant with a calculation of the order's amount
    // Calculate the order total on the server to prevent
    // people from directly manipulating the amount on the client
    return 7 * 100; //FIXME:
};

// TODO: create transfer, use CreateTransferAmount to calculate amounts

app.listen(4242, () => console.log('Node server listening on port 4242!'));

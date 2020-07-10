
Original App Design Project - README Template
===

# Basket -- Donation Payments

## Table of Contents
* [Overview](#Overview)
* [Product Spec](#Product-Spec)
* [Wireframes](#Wireframes)
* [Schema](#Schema)
	* [Models](#models)
	* [Networking](#networking)

---

## Overview
### Description
Donation payments app that allows users to make donations towards a cause, rather than specific nonprofits.
Each cause (e.g. LGQBT+, racial equality, education, etc.) is associated with a predetermined "Basket" of nonprofits, and donations towards the cause are automatically split evenly among the nonprofits. User has choice of reassigning split percentages.

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Finance + Productivity + Lifestyle
- **Mobile:** Quick, one-touch donations. More convenient and phone-friendly than a website. Easy to use from social media link.
- **Story:** Lots of important causes and nonprofits that are doing good work, but oftentimes donations aren't distributed evenly among them. This leads to nonprofits (like the Minnesota Freedom Fund) receiving way too high of a volume of incoming donations than they can reasonably handle. Also makes donating towards a cause much simpler for the consumer :) Also easy to discover new nonprofits doing work in the field!
- **Market:** Activists, people who care about a cause. Anyone looking to donate towards a cause/mission. Anyone looking to discover new nonprofits.
- **Habit:** Becomes the go-to donation app instead of donating on 2384 different websites; streamlined platform.
- **Scope:** Essentially money splitter + payments API, at its core. Lots of potential features to expand on (better payments, social, adding nonprofits as users), but MVP is also worthwhile.

## Product Spec

### 1. User Stories (Required and Optional)
**Required Must-have Stories**
* Set up Parse server & deploy with Heroku
* User is able to signup (and adds to user database) + login with PayPal
* Nonprofit able to signup + login with PayPal to receive
* User is able to logout
* User able to query from Parse to see Baskets on home page
* Basket detail view displays Basket info
* Nonprofit detail view displays nonprofit info
* User can make donation
    * Keypad screen, integrates with payments API
* Screen animates when payment complete
* Profile screen displays nonprofit vs user status
* User can use camera to take profile pic
  * Can zoom-in-out of prof pic/header pictures (gesture recognizer)
-   Your app integrates with a SDK (e.g. Google Maps SDK, Facebook SDK)
-   Your app incorporates an external library to add visual polish

**Optional Nice-to-have Stories**
* User can edit split percentages
* User can create new Baskets
* Profile page displays recent/fave causes/baskets
* Add social, see friends/public activity
* Search explore sees SearchVC for categories/recents/trending/etc
* Can change payment source (e.g. Paypal, Venmo, Coinbase)
    * Use cryptocurrency to pay
* Pay in different currencies

### 2. Screen Archetypes
* Splash
* Signup / Login
    * User can signup/login
    * (extra) Preview of Basket Explore page in background
* Explore
    * See baskets on homepage
    * Search baskets
* Basket Detail
* Nonprofit detail
* **Payment flow**
    * Payment keypad screen
    * Edit split percentage
    * Payment SDK
    * Thanks for donating!
* Profile page
    * Settings

### 3. Navigation

**Tab Navigation** (Tab to Screen)
* Explore Feed
* Search Screen
* (extra) Social Feed
* Profile

**Flow Navigation** (Screen to Screen)
* Login/Signup -> User Login Details -> PayPal signup -> Explore Feed
* Explore Feed -> Basket Page
* Search -> Basket or Nonprofit Page
* Profile -> Change profile pic page -> Camera
* Basket
	* -> Nonprofit Page
	* -> Donation Flow
* Donation Flow -> number keypad -> edit percentages (optional) -> PayPal API sign in -> Thank you for donation -> Exit to explore feed

## Wireframes
<img src="https://i.imgur.com/95VG2iZ.jpg" width=600>

### [BONUS] Digital Wireframes & Mockups
*[Figma Wireframe](https://www.figma.com/file/S2gC3N8WvkxmO42AhgbzSW/Basket-App-Sketch?node-id=0%3A1)*

### [BONUS] Interactive Prototype

## Schema 

### Models
#### User (subclass of PFUser)
* userId
* username
* password
* firstName
* lastName
* paymentInfo
* profilePicFile
* nonprofit (nil if not nonprofit, pointer to Nonprofit object if is). ??????
* recentDonations (Array<BasketTransaction>)
* favoriteNonprofits (Array<Nonprofit>)

#### Nonprofit
* nonprofitId
* nonprofitName
* description
* profilePicFile
* headerPicFile
* total value donated
* user (pointer to User)
* belongsInBaskets (NSArray<Basket>)
* *PayPal payments*
	* paymentId
	* merchantId
	* email
* metadata:
	* website
	* category
* updatedAt (joined or new activity)

#### Basket
* basketId
* name
* description
* createdAt
* headerPicFile
* totalValueDonated
* isFeatured (BOOL)
* nonprofits (Array<Nonprofit>)
* createdBy (pointer to User)

#### BasketTransaction
* basketTransactionId
* payment method
* user (pointer to User)
* totalAmount
* basketRecipient (pointer to Basket)
* individual nonprofit txs (Array<NSDict>)
	* nonprofit (pointer to Nonprofit)
	* percentage to nonprofit
	* individualTransactionId
* timestamp (NSDate)

### Networking
#### List of network requests by screen
* Signup / Login
	* User login / signup (GET or PUT new user)
	* Nonprofit login/signup (GET or PUT new nonprofit)
	* PayPal account creation or login (GET or PUT)
* Explore & Search
	* (GET) Query featured baskets & recently added baskets
* Basket Detail
	* (GET) Query baskets & nonprofits
	* ((FASTER TO CACHE???))
* Nonprofit detail
	* (GET) Nonprofit data and display
* **Payment flow**
    * (GET) updated PayPal info for all nonprofits
    * (POST) Create new transaction for each nonprofit (or batch tx, so you can undo entire tx if one fails)
    * (POST to Parse) Save BasketTransaction to Parse API
* Profile page
    * Settings

https://developer.paypal.com/docs/api/payments/v2/

[Identity API - PayPal Developer](https://developer.paypal.com/docs/api/identity/v1/) - user authentication
* GET */v1/identity/oauth2/userinfo*
[Orders API - PayPal Developer](https://developer.paypal.com/docs/api/orders/v2/)
* POST */v2/checkout/orders*
[Payouts API - PayPal Developer](https://developer.paypal.com/docs/api/payments.payouts-batch/v1/)
* create payment to multiple accounts
* POST */v1/payments/payouts*

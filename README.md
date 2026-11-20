# Prairie Peak Outfitters

Prairie Peak Outfitters is a fictional Winnipeg outdoor-gear shop with a complete
Ruby on Rails storefront. Shoppers can browse and search gear, save items in a
cart, create an account, see provincial taxes, and pay through Stripe Checkout.
Staff can manage products, photos, categories, pages, customers, provincial tax
rates, and orders in the admin area.

This guide is written for someone setting up the project for the first time.
Follow the steps in order. You do not need to know how Rails works to run the
store, but you will need to copy commands carefully.

## What you need

Choose one way to run the store:

- **Docker (recommended):** Install Docker Desktop and make sure it is running.
- **Run it directly on your computer:** Install Ruby 3.1 or newer, PostgreSQL,
  Node.js/npm, and libvips. PostgreSQL must be running before you start Rails.

An Internet connection is needed the first time to download project packages.
Stripe test keys are needed only to try the card-payment handoff. Never put live
payment keys or cloud credentials in a public repository.

## Option A: run with Docker

1. Open a terminal in the `prairie_peak` project folder.
2. Make a private settings file from the example:

   ```sh
   cp .env.example .env
   ```

   On Windows PowerShell, use `Copy-Item .env.example .env`.

3. Generate a private app key by running `openssl rand -hex 64` in a terminal.
   Copy the result into `.env` as `SECRET_KEY_BASE=...`. Set a new,
   hard-to-guess `ADMIN_PASSWORD`. Add Stripe **test-mode** keys if you want to
   try payment. Leave the AWS settings empty for local image storage. Docker
   Compose will not start the app if `SECRET_KEY_BASE` is blank.
4. Start the database and store:

   ```sh
   docker compose up --build
   ```

   The first start builds the app, creates the database, and loads the sample
   catalogue. Wait for the Rails server message, then open
   <http://localhost:3000>.
5. To stop the store, press `Ctrl+C` in the terminal. To start it again, run
   `docker compose up`.

The sample staff login is the email in `ADMIN_EMAIL` and the password in
`ADMIN_PASSWORD` in your private `.env` file. Open
<http://localhost:3000/admin>. Change the example credentials before sharing or
deploying the app. Production seeding refuses to create the first staff account
with the example `password123` password.

## Option B: run directly on your computer

1. Install and start PostgreSQL. Create a database user that can create
   databases, or update the database username and password in `.env` to match
   your PostgreSQL setup.
2. Copy `.env.example` to `.env` as described above. Set `DB_USER` and
   `DB_PASSWORD` to the PostgreSQL account on your computer. Generate
   `SECRET_KEY_BASE` with `bin/rails secret` and add it to `.env`. Stripe keys
   are optional until you try payment.
3. Install the Ruby packages:

   ```sh
   bundle install
   ```

4. Create the database, build its tables, and add the sample store information:

   ```sh
   bin/rails db:prepare
   bin/rails db:seed
   ```

5. Start the website:

   ```sh
   bin/rails server
   ```

6. Open <http://localhost:3000>. Stop the server with `Ctrl+C`.

The default local staff login is `admin@prairiepeak.example` and
`password123`. You can change these before seeding by setting `ADMIN_EMAIL` and
`ADMIN_PASSWORD` in `.env`. Do not use the example password on a public site.

Staff sign in with their email and password at `/admin`. Customers can sign in
with either their username or email. Creating a customer account requires a
unique username, a valid email address, and a password of at least eight
characters entered in both password fields. Address details can be added later
and are required at checkout.

## How to use the store

- **Browse:** The home page features six adventure slides linking to categories,
  plus new arrivals and sale items. Use the arrows, slide selectors, or
  pause/play button to control the slideshow. Choose a category in the menu
  to see its products.
- **Search:** Use the search box in the top navigation. Enter a word and, if
  desired, choose a category. Leave the category blank to search the whole
  catalogue. Results match product names and descriptions.
- **Filter:** On the product list, choose On sale, New, or Recently updated.
  Long product lists have page controls.
- **Product details:** Select a product to see its description, image, price,
  stock, category links, and related products.
- **Cart:** Add products, change a quantity with Update, or remove a product
  with its separate Remove button. The cart is saved in the current browser
  session.
- **Account and address:** Create an account with an email, username, and
  password. Add a Canadian postal address and province when asked at checkout.
- **Checkout:** The invoice shows the saved product prices and taxes for the
  selected province before sending you to Stripe's hosted card form. Use Stripe's
  test card `4242 4242 4242 4242`, any future expiry date, and any CVC. A
  successful test payment marks the order paid; a cancelled payment keeps the
  cart.
- **Order history:** After signing in, use My orders to see past orders,
  products, tax, totals, and status.
- **Staff tools:** Sign in at `/admin` to manage products, categories, product
  photos, About/Contact text, customers, tax rates, and orders. Marking an order
  shipped is available once it has been paid.

## Sample catalogue

Seeding creates 13 provinces and territories, 6 categories, 59 sample products
(at least 10 per category),
an administrator, and editable About and Contact pages. Product names and
descriptions are written for this fictional shop; no scraped or third-party
dataset is required for the assignment's invented-product option. Each product
has a locally stored outdoor photo selected to match the item's type. Some
related products reuse the same illustrative photo; these do not show exact
Prairie Peak models. Photo creators, source pages, and licenses are listed in
[db/seeds/images/README.md](./db/seeds/images/README.md).

Seeding is safe to repeat: it finds existing province, category, product, admin,
and page records rather than intentionally creating duplicates. About/Contact
pages edited by staff are not overwritten on later seed runs. Reseeding does
reset seeded product details, categories, stock and changed image attachments,
so back up any staff edits to sample products first. To load the expanded
catalogue and updated sample photos, run:

```sh
bin/rails db:seed
```

## Project checks

Run the Ruby style checker and Rails tests:

```sh
bundle exec rubocop
bin/rails test
```

For browser tests, start PostgreSQL, prepare and seed the database, and start
Rails in one terminal. In another terminal run:

```sh
npm install
npm run cy:run
```

The Cypress suite checks sign-up/login and the cart-to-invoice flow, including
error cases. Stripe's hosted card form is not automated by Cypress.

The GitHub Actions workflow runs RuboCop and the Rails test suite when code is
pushed or a pull request is opened.

## Images and optional cloud storage

Uploaded product photos use Rails Active Storage. Local development stores
uploads on your computer. Production automatically selects the S3 service when
`AWS_BUCKET` is set. To enable S3, create a private bucket, give the app's AWS
identity permission to access it, then set `AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, and `AWS_BUCKET` in the hosting
environment. Never commit those values. Test uploads and image variants after
configuring the bucket; this repository does not include AWS credentials or a
provisioned bucket.

The product-specific seed photos are downloaded from Wikimedia Commons and
Unsplash and redistributed under the licenses listed in
[db/seeds/images/README.md](./db/seeds/images/README.md). The seed script maps
each SKU to its own local image, so storefront pages do not rely on an external
image service at runtime. Responsive square card photos are served at up to
480 x 480 pixels, and product details at up to 840 x 840 pixels; display sizes
are capped on wide screens and scale down on phones. If a stored image cannot
load, the storefront displays a built-in product-image fallback. To attach the
current seed photos to an existing database, run:

```sh
bin/rails db:seed
```

### New adventure and hiking photo credits

The following resized photos are used under the
[Unsplash License](https://unsplash.com/license). Images illustrate outdoor
equipment and are not endorsements by the photographers or pictured brands.

| Use | Photographer | Original photograph |
| --- | --- | --- |
| Footwear and apparel slide | David Cerini | [Woman looking across mountains](https://unsplash.com/photos/a-woman-standing-on-top-of-a-mountain-with-a-backpack-qwyEEBEwQu0) |
| Packs and bags slide | Alin Gavriliuc | [Hiker with a backpack](https://unsplash.com/photos/a-man-hiking-up-a-mountain-with-a-backpack-J0x5ZqtTUxA) |
| Tents slide | Miguel Cortes | [Tent in the mountains](https://unsplash.com/photos/a-tent-is-set-up-on-a-mountain-landscape-Mi84slgkTiY) |
| Sleeping gear slide | Chaewul Kim | [Tent and sleeping bag in the snow](https://unsplash.com/photos/a-tent-with-a-sleeping-bag-in-the-snow-next-to-a-tree-HW3-TXyfMlY) |
| Cooking slide | Hanna Lazar | [Preparing food on a camping stove](https://unsplash.com/photos/person-preparing-food-on-camping-stove-Gypo3bJGMqw) |
| Paddling slide | Maxime Doré | [Canoeing in Canada](https://unsplash.com/photos/a-group-of-people-in-canoes-paddling-down-a-river-r9e0EboZguI) |
| Hiking boots | Wes Hicks | [Boots crossing a creek](https://unsplash.com/photos/person-stepping-on-rock--zqLoHuYkj4) |
| Black hiking shoe | Ajeet Panesar | [Shoe on a rock](https://unsplash.com/photos/a-black-shoe-on-a-rock-p3rDtB66cws) |
| Hiking shoes | Clay Banks | [Shoes on a trail](https://unsplash.com/photos/person-in-gray-nike-running-shoes-nj0a29qb_jo) |

The remaining seed-image credits and licenses are in
[db/seeds/images/README.md](./db/seeds/images/README.md).
## Design and record-keeping notes

- Order items save the unit price charged at purchase; orders save the applied
  tax rates, tax amounts, and total. Later catalogue or tax edits do not rewrite
  past order totals.
- Products already used by an order cannot be deleted. Staff can deactivate
  them instead, preserving order history.
- Stripe Checkout is configured for test-mode use. An order is marked paid only
  after Stripe reports a paid checkout session.
- Province tax rates are sample values in `db/seeds.rb`; verify applicable
  rates before using the app for real sales.

# Rip Vinyl

The purpose of this app is to help you know which record from your Discogs collection has been ripped or not.

You import your collection at first connection (via OAuth) then you can visualize it and communicate via Discogs API, it will add a text field on the itmes of your collection with the text "RIP ok".
You can mark certain records "to be ripped", to create some sort of list.
You can sort your collection.

## Usage

The app uses Redis/Sidekiq for some queues jobs, like fetching HD photos from Discogs Database and storing them in Cloudinary.
The app uses Cloudinary, so you may need a free account if you wanna use this feature.

```bash
DISCOGS_API_CONSUMER=
DISCOGS_API_SECRET=
CLOUDINARY_URL=

```

Huge thanks to buntine and his Ruby [Discogs API Wrapper](https://github.com/buntine/discog)

## Admin Setup

To create an admin user, run the following rake task:

```bash
rails admin:create
```

You will be prompted to enter:

- Admin email address
- Admin password

The task will create the admin user and confirm successful creation.

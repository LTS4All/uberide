# Uberide legacy web build

This folder is a standalone website for iPod touch devices running iOS 9.3.5 Safari. It uses HTML5 markup supported by iOS 9, CSS without modern layout dependencies, and ES5 JavaScript without `fetch`, promises, arrow functions, modules, or other newer browser features.

Open `index.html` from a web server over HTTPS. The Food and Rides tabs work without a backend. Restaurant and ride entries are real named options, while BUY and GO buttons send the user to official Uber Eats or Uber web destinations for checkout/request handling.

## Hosting

Upload the contents of this folder to any HTTPS static host, such as GitHub Pages. On the iPod, open the HTTPS URL in Safari and choose **Add to Home Screen**.

## Nearby places and photos

The FIND button geocodes any typed US or UK location with OpenStreetMap Nominatim and requests up to 100 nearby named food places within 8 km from the public Overpass API. USE MY LOCATION uses the iPod browser's embedded geolocation permission, then performs the same nearby lookup. Use these as low-volume, user-triggered lookups and follow each service's current usage policy. The cards show the location, place name, and review availability; they do not invent review scores. Local open-photo assets are used as lightweight visual fallbacks because many OpenStreetMap places do not publish a photo.

The corner **Uberide AI** button is key-free and works as a lightweight in-page helper. Tap a place, open Uberide AI, and ask about directions, reviews, location, or ordering; the answers use the place facts already loaded in the page. Its X button closes the panel.

## Limitations

This is a shortcut interface, not a replacement for Uber's account, payment, checkout, or ride-request systems. The URLs may change by region or over time. It does not scrape Uber and does not require third-party certificates.

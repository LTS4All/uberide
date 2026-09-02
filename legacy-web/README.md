# Uberide legacy web build

This folder is a standalone website for iPod touch devices running iOS 9.3.5 Safari. It uses HTML5 markup supported by iOS 9, CSS without modern layout dependencies, and ES5 JavaScript without `fetch`, promises, arrow functions, modules, or other newer browser features.

Open `index.html` from a web server over HTTPS. The Food and Rides tabs work without a backend. Restaurant and ride entries are real named options, while BUY and GO buttons send the user to official Uber Eats or Uber web destinations for checkout/request handling.

## Hosting

Upload the contents of this folder to any HTTPS static host, such as GitHub Pages. On the iPod, open the HTTPS URL in Safari and choose **Add to Home Screen**.

## Nearby places and photos

The FIND button geocodes any typed US or UK location with OpenStreetMap Nominatim and requests up to 100 nearby named food places within 8 km from the public Overpass API. USE MY LOCATION uses the iPod browser's embedded geolocation permission, then performs the same nearby lookup. Use these as low-volume, user-triggered lookups and follow each service's current usage policy. The cards show the location, place name, and review availability; they do not invent review scores. Local open-photo assets are used as lightweight visual fallbacks because many OpenStreetMap places do not publish a photo.

The optional AI button sends the returned place list to OpenRouter using the key the user enters for that browser session. The key is not written to local storage, committed to GitHub, or embedded in the site. For a public production site, proxy the AI call through your own server so the key is not exposed to the browser.

## Limitations

This is a shortcut interface, not a replacement for Uber's account, payment, checkout, or ride-request systems. The URLs may change by region or over time. It does not scrape Uber and does not require third-party certificates.

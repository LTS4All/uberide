# Uberide legacy web build

This folder is a standalone website for iPod touch devices running iOS 9.3.5 Safari. It uses HTML5 markup supported by iOS 9, CSS without modern layout dependencies, and ES5 JavaScript without `fetch`, promises, arrow functions, modules, or other newer browser features.

Open `index.html` from a web server over HTTPS. The Food and Rides tabs work without a backend. Restaurant and ride entries are real named options, while BUY and GO buttons send the user to official Uber Eats or Uber web destinations for checkout/request handling.

## Hosting

Upload the contents of this folder to any HTTPS static host, such as GitHub Pages. On the iPod, open the HTTPS URL in Safari and choose **Add to Home Screen**.

## Limitations

This is a shortcut interface, not a replacement for Uber's account, payment, checkout, or ride-request systems. The URLs may change by region or over time. It does not scrape Uber and does not require third-party certificates.

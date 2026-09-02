(function () {
  'use strict';

  var foods = [
    { name: 'Pret A Manger', cuisine: 'Sandwiches · Coffee', note: 'Popular near you', review: 'Reviews supplied by the place data source', photo: 'photos/food-table.jpg' },
    { name: 'PizzaExpress', cuisine: 'Pizza · Italian', note: 'Comfort food favourites', review: 'Reviews supplied by the place data source', photo: 'photos/food-table.jpg' },
    { name: 'Five Guys', cuisine: 'Burgers · American', note: 'Made to order', review: 'Reviews supplied by the place data source', photo: 'photos/restaurant-exterior.jpg' },
    { name: 'Wagamama', cuisine: 'Japanese · Noodles', note: 'Fresh bowls and sides', review: 'Reviews supplied by the place data source', photo: 'photos/restaurant-exterior.jpg' },
    { name: 'Costa Coffee', cuisine: 'Coffee · Bakery', note: 'Coffee and light bites', review: 'Reviews not provided by the data source', photo: 'photos/food-table.jpg' },
    { name: 'Nando\'s', cuisine: 'Chicken · Portuguese', note: 'Grilled chicken and sides', review: 'Reviews not provided by the data source', photo: 'photos/restaurant-exterior.jpg' },
    { name: 'Dishoom', cuisine: 'Indian · Breakfast', note: 'Small plates and chai', review: 'Reviews not provided by the data source', photo: 'photos/food-table.jpg' },
    { name: 'Honest Burgers', cuisine: 'Burgers · British', note: 'Burgers and rosemary chips', review: 'Reviews not provided by the data source', photo: 'photos/restaurant-exterior.jpg' }
  ];
  var rides = [
    { name: 'UberX', detail: 'Affordable everyday rides', note: 'Continue securely on Uber', icon: 'X' },
    { name: 'Uber Comfort', detail: 'Extra legroom and comfort', note: 'Continue securely on Uber', icon: 'C' },
    { name: 'UberXL', detail: 'Room for more passengers', note: 'Continue securely on Uber', icon: 'L' }
  ];
  var places = foods.slice(0);
  var lastLocation = '';
  var selectedPlace = null;
  var currentCoordinates = null;

  function byId(id) { return document.getElementById(id); }
  function encode(value) { return encodeURIComponent(value || ''); }
  function safe(value) { return String(value || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;'); }
  function setStatus(message) { byId('status').innerHTML = message; }
  function openOfficialSite(url) { window.location.href = url; }

  function xhr(method, url, body, callback) {
    var request = new XMLHttpRequest();
    request.open(method, url, true);
    request.setRequestHeader('Accept', 'application/json');
    if (method === 'POST') { request.setRequestHeader('Content-Type', 'application/json'); }
    request.onreadystatechange = function () {
      if (request.readyState !== 4) { return; }
      if (request.status >= 200 && request.status < 300) { callback(null, request.responseText); }
      else { callback(new Error('Request failed: ' + request.status), null); }
    };
    request.onerror = function () { callback(new Error('Network request failed'), null); };
    request.send(body || null);
  }

  function renderFood(query) {
    var list = byId('foodList');
    var html = '';
    var q = (query || '').toLowerCase();
    var i;
    var item;
    var matches = 0;
    for (i = 0; i < places.length; i += 1) {
      item = places[i];
      if (q && (item.name + ' ' + item.cuisine + ' ' + (item.location || '')).toLowerCase().indexOf(q) === -1) { continue; }
      matches += 1;
      html += '<div class="place-row" data-place-index="' + i + '"><div class="photo-cell"><img class="place-photo" src="' + safe(item.photo || 'photos/food-table.jpg') + '" alt="' + safe(item.name) + '"></div>';
      html += '<div class="row-copy"><strong>' + safe(item.name) + '</strong><small>' + safe(item.location || item.cuisine || 'Food place') + '</small><em>' + safe(item.cuisine || item.note || 'Nearby place') + '</em><span class="review">' + safe(item.review || 'Reviews not provided') + '</span></div>';
      html += '<div class="action-cell"><button class="buy-button" type="button" data-url="https://www.ubereats.com/">BUY</button></div></div>';
    }
    list.innerHTML = matches ? html : '<div class="empty">No places found. Try another location or place name.</div>';
    bindExternalButtons(list);
    bindPlaceRows(list);
  }

  function renderRides(query) {
    var list = byId('rideList');
    var html = '';
    var q = (query || '').toLowerCase();
    var i;
    var item;
    var matches = 0;
    for (i = 0; i < rides.length; i += 1) {
      item = rides[i];
      if (q && item.name.toLowerCase().indexOf(q) === -1) { continue; }
      matches += 1;
      html += '<div class="ride-row"><div class="row-icon"><span>' + item.icon + '</span></div><div class="row-copy"><strong>' + item.name + '</strong><small>' + item.detail + '</small><em>' + item.note + '</em></div><div class="action-cell"><button class="go-button" type="button" data-url="https://m.uber.com/ul/">GO</button></div></div>';
    }
    list.innerHTML = matches ? html : '<div class="empty">No ride types found.</div>';
    bindExternalButtons(list);
  }

  function bindExternalButtons(root) {
    var buttons = root.querySelectorAll('[data-url]');
    var i;
    for (i = 0; i < buttons.length; i += 1) {
      buttons[i].onclick = function (event) {
        if (event) { event.cancelBubble = true; }
        openOfficialSite(this.getAttribute('data-url'));
        return false;
      };
    }
  }

  function bindPlaceRows(root) {
    var rows = root.querySelectorAll('[data-place-index]');
    var i;
    for (i = 0; i < rows.length; i += 1) {
      rows[i].onclick = function () { showDetails(places[parseInt(this.getAttribute('data-place-index'), 10)]); };
    }
  }

  function showSection(section) {
    var food = byId('foodSection');
    var ridesSection = byId('ridesSection');
    var foodTab = byId('foodTab');
    var ridesTab = byId('ridesTab');
    if (section === 'food') {
      food.className = 'section active-section'; ridesSection.className = 'section'; foodTab.className = 'tab active'; ridesTab.className = 'tab';
    } else {
      food.className = 'section'; ridesSection.className = 'section active-section'; foodTab.className = 'tab'; ridesTab.className = 'tab active';
    }
  }

  function directionsUrl(place) {
    var destination = place.name + ', ' + (place.location || lastLocation || '');
    if (place.lat && place.lon) { destination = place.lat + ',' + place.lon; }
    return 'https://www.google.com/maps/dir/?api=1&destination=' + encode(destination);
  }

  function showDetails(place) {
    var body;
    selectedPlace = place;
    body = '<img class="detail-photo" src="' + safe(place.photo || 'photos/food-table.jpg') + '" alt="' + safe(place.name) + '">';
    body += '<p><strong>Location</strong><br>' + safe(place.location || lastLocation || 'Location not supplied') + '</p>';
    body += '<p><strong>Place name</strong><br>' + safe(place.name) + '</p>';
    body += '<p><strong>Category</strong><br>' + safe(place.cuisine || 'Food place') + '</p>';
    body += '<p><strong>Reviews</strong><br>' + safe(place.review || 'Reviews not provided by the data source') + '</p>';
    body += '<p class="detail-hint">Tap GET DIRECTIONS for Google Maps, or OPEN ON UBER EATS to order.</p>';
    byId('detailTitle').innerHTML = safe(place.name);
    byId('detailBody').innerHTML = body;
    byId('detailPanel').className = 'detail-panel visible';
    byId('detailPanel').setAttribute('aria-hidden', 'false');
  }

  function closeDetails() {
    byId('detailPanel').className = 'detail-panel';
    byId('detailPanel').setAttribute('aria-hidden', 'true');
    selectedPlace = null;
  }

  function requestLocation() {
    if (!navigator.geolocation) { setStatus('This iPod browser cannot provide location. Type a location instead.'); return; }
    setStatus('Requesting your location...');
    navigator.geolocation.getCurrentPosition(function (position) {
      currentCoordinates = { lat: position.coords.latitude, lon: position.coords.longitude };
      lastLocation = 'your current location';
      lookupNearbyCoordinates(currentCoordinates.lat, currentCoordinates.lon, lastLocation);
    }, function () {
      setStatus('Location permission was not granted. Type a town or postcode instead.');
    }, { enableHighAccuracy: false, timeout: 15000, maximumAge: 300000 });
  }

  function lookupLocationName(name) {
    setStatus('Finding ' + safe(name) + '...');
    xhr('GET', 'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&q=' + encode(name), null, function (error, text) {
      var result;
      if (error) { setStatus('Location lookup failed. Check the spelling and try again.'); return; }
      try { result = JSON.parse(text)[0]; } catch (ignore) { result = null; }
      if (!result) { setStatus('Location not found. Try a town, street, or postcode.'); return; }
      currentCoordinates = { lat: result.lat, lon: result.lon };
      lookupNearbyCoordinates(result.lat, result.lon, name);
    });
  }

  function lookupNearbyCoordinates(latitude, longitude, locationName) {
    var query = '[out:json][timeout:30];nwr(around:8000,' + latitude + ',' + longitude + ')[amenity~"restaurant|cafe|fast_food|food_court|pub"];out center;';
    setStatus('Loading places near ' + safe(locationName) + '...');
    xhr('GET', 'https://overpass-api.de/api/interpreter?data=' + encode(query), null, function (error, text) {
      if (error) { setStatus('Nearby place service is busy. Try again in a moment.'); return; }
      showNearbyPlaces(text, locationName);
    });
  }

  function showNearbyPlaces(text, locationName) {
    var response;
    var elements;
    var nextPlaces = [];
    var i;
    var item;
    var name;
    try { response = JSON.parse(text); elements = response.elements || []; } catch (ignore) { elements = []; }
    for (i = 0; i < elements.length && nextPlaces.length < 100; i += 1) {
      item = elements[i];
      name = item.tags && item.tags.name;
      if (!name) { continue; }
      nextPlaces.push({ name: name, cuisine: (item.tags.cuisine || item.tags.amenity || 'Food place').replace(/_/g, ' '), location: locationName, note: 'Found nearby with OpenStreetMap', review: item.tags && item.tags['contact:website'] ? 'Website available' : 'Reviews not provided by OpenStreetMap', lat: item.lat || (item.center && item.center.lat), lon: item.lon || (item.center && item.center.lon), photo: i % 2 ? 'photos/food-table.jpg' : 'photos/restaurant-exterior.jpg' });
    }
    if (!nextPlaces.length) { setStatus('No named food places were found near ' + safe(locationName) + '.'); return; }
    places = nextPlaces;
    lastLocation = locationName;
    renderFood('');
    setStatus('Found ' + nextPlaces.length + ' places near ' + safe(locationName) + '. Tap a place for details.');
  }

  function openAiPanel() {
    byId('aiPanel').className = 'ai-panel visible';
    byId('aiPanel').setAttribute('aria-hidden', 'false');
    byId('aiQuestion').focus();
  }

  function closeAiPanel() {
    byId('aiPanel').className = 'ai-panel';
    byId('aiPanel').setAttribute('aria-hidden', 'true');
  }

  function answerAi() {
    var question = byId('aiQuestion').value.replace(/^\s+|\s+$/g, '').toLowerCase();
    var answer;
    if (!question) { byId('aiAnswer').innerHTML = 'Type a question first.'; return; }
    if (selectedPlace) {
      if (question.indexOf('direction') !== -1 || question.indexOf('map') !== -1 || question.indexOf('where') !== -1) {
        answer = 'Use GET DIRECTIONS in the ' + safe(selectedPlace.name) + ' details panel to open Google Maps.';
      } else if (question.indexOf('order') !== -1 || question.indexOf('buy') !== -1 || question.indexOf('uber') !== -1) {
        answer = 'Use OPEN ON UBER EATS in the ' + safe(selectedPlace.name) + ' details panel to continue ordering on Uber Eats.';
      } else if (question.indexOf('review') !== -1 || question.indexOf('rating') !== -1) {
        answer = safe(selectedPlace.review || 'Reviews are not provided by the current place data source.');
      } else {
        answer = safe(selectedPlace.name) + ' is listed as ' + safe(selectedPlace.cuisine || 'a food place') + ' near ' + safe(selectedPlace.location || lastLocation || 'your selected location') + '. ' + safe(selectedPlace.review || 'Review information is not provided.');
      }
    } else if (question.indexOf('location') !== -1 || question.indexOf('near') !== -1) {
      answer = 'Type a US or UK location, or tap USE MY LOCATION, to find nearby named places.';
    } else {
      answer = 'Tap a place for details. I can explain its location, reviews, directions, or how to continue on Uber Eats.';
    }
    byId('aiAnswer').innerHTML = answer;
  }

  byId('foodTab').onclick = function () { showSection('food'); };
  byId('ridesTab').onclick = function () { showSection('rides'); };
  byId('findButton').onclick = function () { var value = byId('locationInput').value.replace(/^\s+|\s+$/g, ''); if (value) { lookupLocationName(value); } else { setStatus('Type a location first.'); } };
  byId('myLocationButton').onclick = requestLocation;
  byId('locationInput').onkeypress = function (event) { if (event.keyCode === 13) { byId('findButton').onclick(); } };
  byId('rideSearch').onkeyup = function () { renderRides(this.value); };
  byId('detailClose').onclick = closeDetails;
  byId('aiCornerButton').onclick = openAiPanel;
  byId('aiPanelClose').onclick = closeAiPanel;
  byId('aiAskButton').onclick = answerAi;
  byId('aiQuestion').onkeypress = function (event) { if (event.keyCode === 13) { answerAi(); } };
  byId('detailDirections').onclick = function () { if (selectedPlace) { openOfficialSite(directionsUrl(selectedPlace)); } };
  byId('detailBuy').onclick = function () { openOfficialSite('https://www.ubereats.com/'); };
  bindExternalButtons(document);
  renderFood('');
  renderRides('');
}());

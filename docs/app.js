(function () {
  'use strict';

  var foods = [
    { name: 'Pret A Manger', cuisine: 'Sandwiches · Coffee', note: 'Popular near you', review: 'Reviews supplied by the place data source', photo: 'photos/food-table.jpg' },
    { name: 'PizzaExpress', cuisine: 'Pizza · Italian', note: 'Comfort food favourites', review: 'Reviews supplied by the place data source', photo: 'photos/food-table.jpg' },
    { name: 'Five Guys', cuisine: 'Burgers · American', note: 'Made to order', review: 'Reviews supplied by the place data source', photo: 'photos/restaurant-exterior.jpg' },
    { name: 'Wagamama', cuisine: 'Japanese · Noodles', note: 'Fresh bowls and sides', review: 'Reviews supplied by the place data source', photo: 'photos/restaurant-exterior.jpg' }
  ];
  var rides = [
    { name: 'UberX', detail: 'Affordable everyday rides', note: 'Continue securely on Uber', icon: '&#128663;' },
    { name: 'Uber Comfort', detail: 'Extra legroom and comfort', note: 'Continue securely on Uber', icon: '&#128186;' },
    { name: 'UberXL', detail: 'Room for more passengers', note: 'Continue securely on Uber', icon: '&#128652;' }
  ];
  var places = foods.slice(0);
  var lastLocation = '';

  function byId(id) { return document.getElementById(id); }

  function setStatus(message) { byId('status').innerHTML = message; }

  function openOfficialSite(url) { window.location.href = url; }

  function encode(value) { return encodeURIComponent(value || ''); }

  function xhr(method, url, body, callback) {
    var request = new XMLHttpRequest();
    request.open(method, url, true);
    request.setRequestHeader('Accept', 'application/json');
    if (method === 'POST') { request.setRequestHeader('Content-Type', 'application/json'); }
    request.onreadystatechange = function () {
      if (request.readyState !== 4) { return; }
      if (request.status >= 200 && request.status < 300) {
        callback(null, request.responseText);
      } else {
        callback(new Error('Request failed: ' + request.status), null);
      }
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
      if (q && (item.name + ' ' + item.cuisine + ' ' + item.location).toLowerCase().indexOf(q) === -1) { continue; }
      matches += 1;
      html += '<div class="place-row"><div class="photo-cell"><img class="place-photo" src="' + (item.photo || 'photos/food-table.jpg') + '" alt="' + item.name + '"></div>';
      html += '<div class="row-copy"><strong>' + item.name + '</strong><small>' + (item.location || item.cuisine || 'Food place') + '</small><em>' + (item.cuisine || item.note || 'Nearby place') + '</em>';
      html += '<span class="review">' + (item.review || 'Reviews not provided') + '</span></div>';
      html += '<div class="action-cell"><button class="buy-button" type="button" data-url="https://www.ubereats.com/">BUY</button></div></div>';
    }
    list.innerHTML = matches ? html : '<div class="empty">No places found. Try another location or place name.</div>';
    bindExternalButtons(list);
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
      html += '<div class="ride-row"><div class="row-icon"><span>' + item.icon + '</span></div>';
      html += '<div class="row-copy"><strong>' + item.name + '</strong><small>' + item.detail + '</small><em>' + item.note + '</em></div>';
      html += '<div class="action-cell"><button class="go-button" type="button" data-url="https://m.uber.com/ul/">GO</button></div></div>';
    }
    list.innerHTML = matches ? html : '<div class="empty">No ride types found.</div>';
    bindExternalButtons(list);
  }

  function bindExternalButtons(root) {
    var buttons = root.querySelectorAll('[data-url]');
    var i;
    for (i = 0; i < buttons.length; i += 1) {
      buttons[i].onclick = function () { openOfficialSite(this.getAttribute('data-url')); };
    }
  }

  function showSection(section) {
    var food = byId('foodSection');
    var ridesSection = byId('ridesSection');
    var foodTab = byId('foodTab');
    var ridesTab = byId('ridesTab');
    if (section === 'food') {
      food.className = 'section active-section';
      ridesSection.className = 'section';
      foodTab.className = 'tab active';
      ridesTab.className = 'tab';
    } else {
      food.className = 'section';
      ridesSection.className = 'section active-section';
      foodTab.className = 'tab';
      ridesTab.className = 'tab active';
    }
  }

  function locationSearchDone(error, text, locationName) {
    var result;
    var latitude;
    var longitude;
    var query;
    if (error) { setStatus('Location lookup failed. Check the spelling and try again.'); return; }
    try { result = JSON.parse(text)[0]; } catch (ignore) { result = null; }
    if (!result) { setStatus('Location not found. Try a town, street, or postcode.'); return; }
    latitude = result.lat;
    longitude = result.lon;
    query = '[out:json][timeout:20];nwr(around:3500,' + latitude + ',' + longitude + ')[amenity~"restaurant|cafe|fast_food|food_court"];out center;';
    setStatus('Loading places near ' + locationName + '...');
    xhr('GET', 'https://overpass-api.de/api/interpreter?data=' + encode(query), null, function (overpassError, overpassText) {
      if (overpassError) { setStatus('Nearby place service is busy. Try again in a moment.'); return; }
      showNearbyPlaces(overpassText, locationName);
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
    for (i = 0; i < elements.length && nextPlaces.length < 18; i += 1) {
      item = elements[i];
      name = item.tags && item.tags.name;
      if (!name) { continue; }
      nextPlaces.push({
        name: name,
        cuisine: (item.tags.cuisine || item.tags.amenity || 'Food place').replace(/_/g, ' '),
        location: locationName,
        note: 'Found nearby with OpenStreetMap',
        review: item.tags && item.tags['contact:website'] ? 'Website available' : 'Reviews not provided by OpenStreetMap',
        photo: i % 2 ? 'photos/food-table.jpg' : 'photos/restaurant-exterior.jpg'
      });
    }
    if (!nextPlaces.length) { setStatus('No named food places were found near ' + locationName + '.'); return; }
    places = nextPlaces;
    lastLocation = locationName;
    renderFood('');
    setStatus('Found ' + nextPlaces.length + ' named places near ' + locationName + '.');
  }

  function findPlaces() {
    var locationName = byId('locationInput').value.replace(/^\s+|\s+$/g, '');
    if (!locationName) { setStatus('Type a location first.'); return; }
    setStatus('Finding ' + locationName + '...');
    xhr('GET', 'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&q=' + encode(locationName), null, function (error, text) {
      locationSearchDone(error, text, locationName);
    });
  }

  function rankWithOpenRouter() {
    var key = byId('openRouterKey').value.replace(/^\s+|\s+$/g, '');
    var model = byId('openRouterModel').value.replace(/^\s+|\s+$/g, '') || 'openai/gpt-4o-mini';
    var prompt;
    var payload;
    if (!key) { setStatus('Add your OpenRouter key first, or use FIND to load places without AI.'); return; }
    if (!places.length) { setStatus('Find places near a location first.'); return; }
    prompt = 'Rank these nearby places for a user. Return only a JSON array of the place names in the best order. Do not invent places. Places: ' + JSON.stringify(places);
    payload = JSON.stringify({ model: model, temperature: 0, messages: [
      { role: 'system', content: 'You rank nearby food places. Return only valid JSON.' },
      { role: 'user', content: prompt }
    ] });
    setStatus('Asking OpenRouter to rank the places...');
    xhr('POST', 'https://openrouter.ai/api/v1/chat/completions', payload, function (error, text) {
      var response;
      var content;
      var names;
      var ranked = [];
      var i;
      var j;
      if (error) { setStatus('OpenRouter request failed. Check the key and try again.'); return; }
      try { response = JSON.parse(text); content = response.choices[0].message.content; } catch (ignore) { content = ''; }
      try { names = JSON.parse(content.replace(/```json|```/g, '').replace(/^\s+|\s+$/g, '')); } catch (ignoreAgain) { names = []; }
      if (!(names instanceof Array)) { setStatus('OpenRouter returned an unexpected ranking.'); return; }
      for (i = 0; i < names.length; i += 1) {
        for (j = 0; j < places.length; j += 1) {
          if (places[j].name === names[i]) { ranked.push(places[j]); break; }
        }
      }
      for (i = 0; i < places.length; i += 1) {
        if (ranked.indexOf(places[i]) === -1) { ranked.push(places[i]); }
      }
      places = ranked;
      renderFood('');
      setStatus('AI ranking applied' + (lastLocation ? ' near ' + lastLocation : '') + '.');
    });
  }

  byId('foodTab').onclick = function () { showSection('food'); };
  byId('ridesTab').onclick = function () { showSection('rides'); };
  byId('findButton').onclick = findPlaces;
  byId('rankButton').onclick = rankWithOpenRouter;
  byId('locationInput').onkeypress = function (event) { if (event.keyCode === 13) { findPlaces(); } };
  byId('rideSearch').onkeyup = function () { renderRides(this.value); };
  bindExternalButtons(document);
  renderFood('');
  renderRides('');
}());

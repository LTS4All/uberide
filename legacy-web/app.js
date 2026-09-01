(function () {
  'use strict';

  var foods = [
    { name: 'Pret A Manger', cuisine: 'Sandwiches · Coffee', note: 'Popular near you', icon: '&#9749;' },
    { name: 'PizzaExpress', cuisine: 'Pizza · Italian', note: 'Comfort food favourites', icon: '&#9679;' },
    { name: 'Five Guys', cuisine: 'Burgers · American', note: 'Made to order', icon: '&#127828;' },
    { name: 'Wagamama', cuisine: 'Japanese · Noodles', note: 'Fresh bowls and sides', icon: '&#127860;' }
  ];
  var rides = [
    { name: 'UberX', detail: 'Affordable everyday rides', note: 'Continue securely on Uber', icon: '&#128663;' },
    { name: 'Uber Comfort', detail: 'Extra legroom and comfort', note: 'Continue securely on Uber', icon: '&#128186;' },
    { name: 'UberXL', detail: 'Room for more passengers', note: 'Continue securely on Uber', icon: '&#128652;' }
  ];

  function byId(id) { return document.getElementById(id); }

  function openOfficialSite(url) {
    window.location.href = url;
  }

  function renderFood(query) {
    var list = byId('foodList');
    var html = '';
    var q = (query || '').toLowerCase();
    var i;
    var item;
    var matches = 0;
    for (i = 0; i < foods.length; i += 1) {
      item = foods[i];
      if (q && (item.name + ' ' + item.cuisine).toLowerCase().indexOf(q) === -1) { continue; }
      matches += 1;
      html += '<div class="place-row"><div class="row-icon"><span>' + item.icon + '</span></div>';
      html += '<div class="row-copy"><strong>' + item.name + '</strong><small>' + item.cuisine + '</small><em>' + item.note + '</em></div>';
      html += '<div class="action-cell"><button class="buy-button" type="button" data-url="https://www.ubereats.com/">BUY</button></div></div>';
    }
    list.innerHTML = matches ? html : '<div class="empty">No places found. Try a restaurant or cuisine.</div>';
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

  byId('foodTab').onclick = function () { showSection('food'); };
  byId('ridesTab').onclick = function () { showSection('rides'); };
  byId('foodSearch').onkeyup = function () { renderFood(this.value); };
  byId('rideSearch').onkeyup = function () { renderRides(this.value); };
  bindExternalButtons(document);
  renderFood('');
  renderRides('');
}());

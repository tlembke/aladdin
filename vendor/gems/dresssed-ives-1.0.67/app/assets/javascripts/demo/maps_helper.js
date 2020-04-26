function animateGoogleMap() {
  if ($('#map_canvas_1')[0] === undefined) {
    return;
  }

  var oldMarker;

  var map = new GMaps({
    div: '#map_canvas_1',
    lat: 0,
    lng: 0,
    disableDefaultUI: true,
    scaleControl: false,
    scrollwheel: false,
    disableDoubleClickZoom: true,
    zoomControl: true,
    zoomControlOpt: {
      style: 'SMALL',
      position: 'TOP_RIGHT'
    },
    height: '485px',
    zoom: 1
  });

  function removeMarkers() {
    map.removeMarkers();
  }

  function update() {
    map.addMarker({
      lat: Math.random() * 280,
      lng: Math.random() * 360
    });

    if (!Modernizr.touch) {
      setTimeout(update, Math.random() * 1000);
      setTimeout(removeMarkers, 10000);
    }
  }

  update();
}

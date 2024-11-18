//assets/js/hooks/map_hook.js
const MapHook = {
  mounted() {
    this.initMap()
    this.initLocationTracking()
  },

  updated() {
    this.updateMarkers()
    this.updateRoute()
  },

  initMap() {
    this.map = new maplibregl.Map({
      container: this.el,
      style: 'https://api.maptiler.com/maps/streets/style.json?key=YOUR_KEY',
      center: [-74.5, 40],
      zoom: 9
    });

    // Add a source for the route
    this.map.on('load', () => {
      this.map.addSource('route', {
        type: 'geojson',
        data: {
          type: 'Feature',
          properties: {},
          geometry: {
            type: 'LineString',
            coordinates: []
          }
        }
      });

      this.map.addLayer({
        id: 'route',
        type: 'line',
        source: 'route',
        layout: {
          'line-join': 'round',
          'line-cap': 'round'
        },
        paint: {
          'line-color': '#4A90E2',
          'line-width': 4,
          'line-opacity': 0.8
        }
      });
    });

    this.driverMarker = new maplibregl.Marker({ color: '#4A90E2' })
    this.passengerMarker = new maplibregl.Marker({ color: '#50E3C2' })
  },

  updateRoute() {
    const route = JSON.parse(this.el.dataset.route);
    if (route && route.geometry) {
      const source = this.map.getSource('route');
      if (source) {
        source.setData({
          type: 'Feature',
          properties: {},
          geometry: route.geometry
        });
      }
    }
  }

  initLocationTracking() {
    if (!navigator.geolocation) {
      console.error('Geolocation is not supported by this browser.');
      return;
    }

    this.watchId = navigator.geolocation.watchPosition(
      (position) => {
        const location = {
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          heading: position.coords.heading,
          speed: position.coords.speed,
          accuracy: position.coords.accuracy
        };

        this.pushEvent("update_location", { location });
      },
      (error) => {
        console.error('Error getting location:', error);
      },
      {
        enableHighAccuracy: true,
        timeout: 5000,
        maximumAge: 0
      }
    );
  },

  updateMarkers() {
    const driverLocation = JSON.parse(this.el.dataset.driverLocation);
    const passengerLocation = JSON.parse(this.el.dataset.passengerLocation);

    if (driverLocation) {
      this.driverMarker
        .setLngLat([driverLocation.longitude, driverLocation.latitude])
        .addTo(this.map);
    }

    if (passengerLocation) {
      this.passengerMarker
        .setLngLat([passengerLocation.longitude, passengerLocation.latitude])
        .addTo(this.map);
    }

    // Fit bounds to include both markers
    if (driverLocation && passengerLocation) {
      const bounds = new maplibregl.LngLatBounds()
        .extend([driverLocation.longitude, driverLocation.latitude])
        .extend([passengerLocation.longitude, passengerLocation.latitude]);

      this.map.fitBounds(bounds, {
        padding: 50
      });
    }
  },

  destroyed() {
    if (this.watchId) {
      navigator.geolocation.clearWatch(this.watchId);
    }
  }
};

export default MapHook;
import maplibregl from "maplibre-gl"
import "maplibre-gl/dist/maplibre-gl.css"

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.map = new maplibregl.Map({
      container: this.containerTarget,
      style: '/objets-map/style.json',
      center: [2.087, 46],
      zoom: 4,
      zoomMobile: 3
    });
    this.map.on('load', () => this.fetchDepartements())
    this.map.on('load', () => this.fetchCommunes())

    this.popup = new maplibregl.Popup({
      closeButton: true,
      closeOnClick: true
    })
  }

  async fetchDepartements() {
    const res = await fetch('/objets-map/departements.geojson')
    const parsed = await res.json()
    const resCounts = await fetch("/api/v1/departements.json")
    const parsedCounts = await resCounts.json()
    const joined = parsed.features.map(feature => {
      const rowCount = parsedCounts
        .find(row => row.number == feature.properties.code) || {}
      return {
        ...feature,
        properties: {
          ...feature.properties,
          objetsCount: rowCount.objets_count || 0,
          communesCount: rowCount.communes_count || 0,
          fillColor: ["#F4F269", "#CEE26B", "#A8D26D", "#82C26E", "#5CB270"][[2000, 3000, 4000, 5000, 1000000].findIndex(r => (rowCount.objets_count || 0) < r)]
        }
      }
    })
    parsed.features = joined
    this.map.addSource("departements", { type: "geojson", data: parsed })
    this.map.addLayer({
      'id': 'departements-lines',
      'type': 'line',
      'source': 'departements',
      'maxzoom': 9,
      paint: {
        'line-color': "black",
        'line-width': 1,
        'line-dasharray': [2, 3],
      }
    });
    this.map.addLayer({
      'id': 'departements-fill',
      'type': 'fill',
      'source': 'departements',
      'maxzoom': 9,
      paint: {
        'fill-color': ["get", "fillColor"],
        'fill-opacity': 0.3,
      }
    });

    this.map.addLayer({
      'id': 'departements-text',
      'type': 'symbol',
      'source': 'departements',
      'maxzoom': 9,
      layout: {
        'text-field': ["get", "objetsCount"],
      }
    });

    this.map.on("mouseenter", "departements-fill", e => {
      this.map.getCanvas().style.cursor = 'pointer'
    })

    this.map.on("mouseleave", "departements-fill", e => {
      this.map.getCanvas().style.cursor = 'grab'
    })

    this.map.on('click', 'departements-fill', e => {
      let features = this.map.queryRenderedFeatures(e.point)
      const { nom, objetsCount, communesCount, code } = features[0].properties
      let description = `
          <div class="popup">
            <p><b>${code} - ${nom}</b></p>
            <p>${objetsCount} objets protégés<br /></p>
            <p><a href="/departements/${code}">Voir les ${communesCount} communes</a></p>
          </div>`
      this.popup.setLngLat(e.lngLat).setHTML(description).addTo(this.map)
    })
  }

  async fetchCommunes() {
    const res = await fetch('/api/v1/communes.json')
    const parsed = await res.json()
    const geojson = {
      "type": "geojson",
      "data": {
        "type": "FeatureCollection",
        "features": parsed.map(row => ({
          "type": "Feature",
          "properties": {
            "nom": row.nom,
            "objetsCount": row.objets_count,
            "codeInsee": row.code_insee,
            "circleRadius": [2, 5, 10, 20][[5, 20, 50, 100000].findIndex(i => row.objets_count < i)]
          },
          "geometry": {
            "type": "Point",
            "coordinates": [row.latitude, row.longitude]
          }
        }))
      }
    }

    this.map.addSource("communes", geojson)

    this.map.addLayer({
      'id': 'communes-circles',
      'type': 'circle',
      'source': 'communes',
      'minzoom': 9,
      paint: {
        'circle-radius': ["get", "circleRadius"],
        'circle-stroke-color': 'black',
        'circle-stroke-width': 1,
        'circle-opacity': 0.8,
        'circle-color': '#ccc',
        'circle-opacity': 0.5
      }
    });

    this.map.on("mouseenter", "communes-circles", e => {
      this.map.getCanvas().style.cursor = 'pointer'
    })

    this.map.on("mouseleave", "communes-circles", e => {
      this.map.getCanvas().style.cursor = 'grab'
    })

    this.map.on('click', 'communes-circles', e => {
      let features = this.map.queryRenderedFeatures(e.point)
      const { nom, objetsCount, codeInsee } = features[0].properties
      let description = `
          <div class="popup">
            <p><b>${nom}</b></p>
            <p><a href="/objets?commune_code_insee=${codeInsee}">Voir les ${objetsCount} objets protégés</a></p>
          </div>`
      this.popup.setLngLat(e.lngLat).setHTML(description).addTo(this.map)
    })
  }
}

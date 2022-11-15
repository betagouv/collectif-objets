import maplibregl from "maplibre-gl"
import "maplibre-gl/dist/maplibre-gl.css"
import OpenmaptilesStyle from "../lib/openmaptiles_style"

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.objetsCountBins = JSON.parse(this.containerTarget.dataset.binsJson)
    const { layers: defaultLayers, ...defaultStyle } = OpenmaptilesStyle

    this.map = new maplibregl.Map({
      container: this.containerTarget,
      center: [2.087, 46],
      zoom: 4,
      zoomMobile: 3,
      minZoom: 3,
      maxZoom: 8,
      style: {
        layers: defaultLayers.concat([
          {
            "id": "departements-fills",
            "type": "fill",
            "source": "decoupage-administratif",
            "source-layer": "departements",
            "paint": {
              "fill-outline-color": [
                "case",
                ["==", ["feature-state", "hovered"], true],
                "black",
                "#666"
              ],
              "fill-opacity": [
                "case",
                ["==", ["feature-state", "hovered"], true],
                1,
                0.7
              ],
              "fill-color": [
                'case',
                ['==', ['feature-state', 'objetsCountBin'], 0],
                this.objetsCountBins[0].color,
                ['==', ['feature-state', 'objetsCountBin'], 1],
                this.objetsCountBins[1].color,
                ['==', ['feature-state', 'objetsCountBin'], 2],
                this.objetsCountBins[2].color,
                ['==', ['feature-state', 'objetsCountBin'], 3],
                this.objetsCountBins[3].color,
                ['==', ['feature-state', 'objetsCountBin'], 4],
                this.objetsCountBins[4].color,
                'transparent'
              ]
            }
          }
        ]),
        ...defaultStyle
      }
    });
    this.map.on('load', () => {
      this.initHover()
      this.hydrateDepartements()
      this.initClick()
    })

    this.popup = new maplibregl.Popup({
      closeButton: true,
      closeOnClick: true
    })
  }

  initHover() {
    this.hoveredId = null;
    this.map.on('mousemove', 'departements-fills', event => {
      if (event.features.length == 0) return
      this.clearHover()
      const feature = event.features[0]
      if (!feature.state.selectable) return
      this.hoveredId = feature.id;
      this.setFeatureState(this.hoveredId, { hovered: true })
      this.map.getCanvas().style.cursor = 'pointer'
    });
    this.map.on('mouseleave', 'departements-fills', () => this.clearHover());
  }

  setFeatureState(id, state) {
    this.map.setFeatureState(
      { source: "decoupage-administratif", sourceLayer: "departements", id },
      state
    )
  }

  clearHover() {
    if (!this.hoveredId) return

    this.map.getCanvas().style.cursor = ''
    this.setFeatureState(this.hoveredId, { hovered: false })
  }

  hydrateDepartements() {
    const departements = JSON.parse(this.containerTarget.dataset.departementsJson)

    departements.forEach(({ code, objetsCount, ...rest }) => {
      const objetsCountBin = this.objetsCountBins.findIndex(r => (objetsCount || 0) < r.threshold)
      this.setFeatureState(code, { code, objetsCount, objetsCountBin, selectable: true, ...rest })
    })
  }

  initClick() {
    this.map.on('click', 'departements-fills', e => {
      let features = this.map.queryRenderedFeatures(e.point)
      const { nom, objetsCount, communesCount, code } = features[0].state
      let description = `
          <div class="popup">
            <p><b>${code} - ${nom}</b></p>
            <p>${objetsCount} objets protégés<br /></p>
            <p><a href="/departements/${code}">Voir les ${communesCount} communes</a></p>
          </div>`
      this.popup.setLngLat(e.lngLat).setHTML(description).addTo(this.map)
    })
  }
}

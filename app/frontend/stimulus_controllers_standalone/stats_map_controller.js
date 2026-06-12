import maplibregl from "maplibre-gl"
import OpenmaptilesStyle from "../lib/openmaptiles_style"
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "tooltip", "insetGuadeloupe", "insetMartinique", "insetGuyane", "insetReunion", "insetMayotte"]
  static values = {
    departements: Array
  }

  connect() {
    this.setupMap()
    this.insetMaps = []
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
      this.map = null
    }
    this.insetMaps.forEach(map => map.remove())
    this.insetMaps = []
  }

  filterLayers(layers) {
    const textLayers = ['place-village', 'place-town', 'place-city', 'place-city-capital', 'waterway-name', 'water-name-lakeline', 'water-name-ocean', 'water-name-other', 'poi-railway']
    return layers.filter(layer => layer.id !== 'background' && !textLayers.includes(layer.id))
  }

  buildDepartementsLayers() {
    return [
      {
        "id": "departements-fills",
        "type": "fill",
        "source": "decoupage-administratif",
        "source-layer": "departements",
        "paint": {
          "fill-opacity": 0.8,
          "fill-color": [
            'case',
            ['>=', ['feature-state', 'campaignsCount'], 5],
            '#000091',
            ['>=', ['feature-state', 'campaignsCount'], 3],
            '#6a6af4',
            ['>=', ['feature-state', 'campaignsCount'], 2],
            '#9a9aff',
            ['==', ['feature-state', 'campaignsCount'], 1],
            '#c6c6ff',
            '#e5e5e5'
          ]
        }
      },
      {
        "id": "departements-contours",
        "type": "line",
        "source": "decoupage-administratif",
        "source-layer": "departements",
        "paint": {
          "line-color": "#666666",
          "line-width": 1
        }
      }
    ]
  }

  buildMapStyle(defaultLayers, defaultStyle) {
    const filteredLayers = this.filterLayers(defaultLayers)
    return {
      layers: [
        {
          "id": "background",
          "type": "background",
          "paint": {
            "background-color": "transparent"
          }
        }
      ].concat(filteredLayers).concat(this.buildDepartementsLayers()),
      ...defaultStyle
    }
  }

  setupMap() {
    const { layers: defaultLayers, ...defaultStyle } = OpenmaptilesStyle

    const bounds = [
      [-5.5, 41.0],  // Southwest (includes Corsica)
      [10.0, 51.5]   // Northeast
    ]

    this.map = new maplibregl.Map({
      container: this.containerTarget,
      bounds,
      fitBoundsOptions: { padding: 20 },
      minZoom: 3,
      maxZoom: 8,
      attributionControl: false,
      style: this.buildMapStyle(defaultLayers, defaultStyle),
      locale: {
        'NavigationControl.ZoomIn': 'Zoomer',
        'NavigationControl.ZoomOut': 'Dézoomer',
      }
    })

    this.map.on('load', () => {
      this.hydrateDepartements(this.departementsValue)
      this.setupMapInteractions(this.map, this.departementsValue)
      this.setupInsetMaps(this.departementsValue, defaultLayers, defaultStyle)
      this.map.getCanvas().removeAttribute('tabindex')
    })

    this.map.addControl(new maplibregl.NavigationControl({ showCompass: false }), 'top-left')
  }

  setupInsetMaps(departements, defaultLayers, defaultStyle) {
    const insets = [
      { target: 'insetGuadeloupe', code: '971', name: 'Guadeloupe', bounds: [[-61.8, 15.8], [-61.0, 16.5]] },
      { target: 'insetMartinique', code: '972', name: 'Martinique', bounds: [[-61.3, 14.4], [-60.8, 14.9]] },
      { target: 'insetGuyane', code: '973', name: 'Guyane', bounds: [[-54.6, 2.1], [-51.6, 5.8]] },
      { target: 'insetReunion', code: '974', name: 'La Réunion', bounds: [[55.2, -21.4], [55.8, -20.9]] },
      { target: 'insetMayotte', code: '976', name: 'Mayotte', bounds: [[45.0, -13.0], [45.3, -12.6]] }
    ]

    insets.forEach(inset => {
      if (!this[`has${inset.target.charAt(0).toUpperCase() + inset.target.slice(1)}Target`]) return

      const insetMap = new maplibregl.Map({
        container: this[`${inset.target}Target`],
        bounds: inset.bounds,
        dragPan: false,
        scrollZoom: false,
        doubleClickZoom: false,
        attributionControl: false,
        style: this.buildMapStyle(defaultLayers, defaultStyle)
      })

      insetMap.on('load', () => {
        this.hydrateDepartements(departements, insetMap)
        this.setupMapInteractions(insetMap, departements)
        insetMap.getCanvas().removeAttribute('tabindex')
      })

      this.insetMaps.push(insetMap)
    })
  }

  setupMapInteractions(map, departements) {
    map.on('mousemove', 'departements-fills', (event) => {
      if (event.features.length === 0) return

      const feature = event.features[0]
      const code = feature.properties.code
      const departement = departements.find(d => d.code === code)

      if (departement) {
        map.getCanvas().style.cursor = 'pointer'
        this.showTooltip(event, departement, map)
      }
    })

    map.on('mouseleave', 'departements-fills', () => {
      map.getCanvas().style.cursor = ''
      this.hideTooltip()
    })
  }

  showTooltip(event, departement, map = this.map) {
    if (!this.hasTooltipTarget) return

    const campaignsText = `${departement.campaigns_count} ${departement.campaigns_label}`

    this.tooltipTarget.innerHTML = `
      <strong>${departement.code} - ${departement.nom}</strong><br>
      ${campaignsText}
    `

    // Calculate position relative to the map container
    const container = map.getContainer()
    const containerRect = container.getBoundingClientRect()
    const wrapperRect = this.element.getBoundingClientRect()

    const left = containerRect.left - wrapperRect.left + event.point.x
    const top = containerRect.top - wrapperRect.top + event.point.y

    this.tooltipTarget.style.left = `${left}px`
    this.tooltipTarget.style.top = `${top}px`
    this.tooltipTarget.style.display = 'block'
  }

  hideTooltip() {
    if (!this.hasTooltipTarget) return
    this.tooltipTarget.style.display = 'none'
  }

  hydrateDepartements(departements, map = this.map) {
    departements.forEach(departement => {
      map.setFeatureState({
        source: "decoupage-administratif",
        sourceLayer: "departements",
        id: departement.code
      }, {
        campaignsCount: departement.campaigns_count
      })
    })
  }
}

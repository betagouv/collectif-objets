import maplibregl from "maplibre-gl"
import "maplibre-gl/dist/maplibre-gl.css"
import OpenmaptilesStyle from "../lib/openmaptiles_style"

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wrapper", "container", "sidebar", "tooltip", "sidebarCommuneTemplate"]

  connect() {
    const { layers: defaultLayers, ...defaultStyle } = OpenmaptilesStyle
    const departement = JSON.parse(this.wrapperTarget.dataset.departementJson)
    this.map = new maplibregl.Map({
      container: this.containerTarget,
      bounds: [departement.bounding_box_sw, departement.bounding_box_ne],
      minZoom: 8,
      maxZoom: 12,
      zoom: 8,
      zoomMobile: 3,
      style: {
        layers: defaultLayers.concat([
          {
            "id": "communes-contours",
            "type": "line",
            "source": "decoupage-administratif",
            "source-layer": "communes",
            "layout": { "visibility": "visible" },
            "paint": {
              "line-color": [
                "case",
                ["==", ["feature-state", "selected"], true],
                "white",
                ["==", ["get", "departement"], departement.code],
                "black",
                "transparent"
              ],
              "line-width": [
                "case",
                ["==", ["feature-state", "selected"], true],
                5,
                1
              ]
            }
          },
          {
            "id": "communes-fills",
            "type": "fill",
            "source": "decoupage-administratif",
            "source-layer": "communes",
            "paint": {
              "fill-opacity": [
                "case",
                ["==", ["feature-state", "selected"], true],
                1,
                ["==", ["feature-state", "hovered"], true],
                .8,
                0.5
              ],
              "fill-color": [
                'case',
                ['==', ['feature-state', 'status'], "prioritaire"],
                '#b34001',
                ['==', ['feature-state', 'status'], "completed"],
                '#6b6af4',
                'transparent'
              ]
            }
          }
        ]),
        ...defaultStyle
      },
    });

    this.map.on('load', () => {
      this.initHover()
      this.initClick()
      this.hydrateStatuses()
    })

    this.map.addControl(new maplibregl.NavigationControl({showCompass: false}));
  }

  initHover() {
    this.hoveredCodeInsee = null;
    this.map.on('mousemove', 'communes-fills', event => {
      if (event.features.length == 0) return
      this.clearHover()
      const feature = event.features[0]
      if (!feature.state.selectable) return
      this.hoveredCodeInsee = feature.id;
      this.setCommuneState(this.hoveredCodeInsee, { hovered: true })
      this.map.getCanvas().style.cursor = 'pointer'
    });
    this.map.on('mouseleave', 'state-fills', () => this.clearHover());
  }

  clearHover() {
    if (!this.hoveredCodeInsee) return

    this.map.getCanvas().style.cursor = ''
    this.setCommuneState(this.hoveredCodeInsee, { hovered: false })
  }

  setCommuneState(codeInsee, state) {
    this.map.setFeatureState({
      source: "decoupage-administratif",
      sourceLayer: "communes",
      id: codeInsee
    }, state)
  }

  hydrateStatuses() {
    const communes = JSON.parse(this.wrapperTarget.dataset.communesJson)
    communes.filter(c => c.status == "completed").forEach(commune => {
      const isPrioritaire = (commune.recensements_prioritaires_count || 0) > 0
      const status = isPrioritaire ? "prioritaire" : "completed"
      this.setCommuneState(commune.code_insee, { selectable: true, status })
    })
  }

  initClick() {
    this.selectedCodeInsee = null
    this.map.on('click', 'communes-fills', event => {
      this.closeSidebar()
      if (event.features.length == 0) return
      const feature = event.features[0]
      if (!feature.state.selectable) return
      this.selectedCodeInsee = feature.id
      this.onSelectCommune()
    })
  }

  closeSidebar() {
    this.setCommuneState(this.selectedCodeInsee, { selected: false })
    this.selectedCodeInsee = null
    this.sidebarTarget.setAttribute("data-collapsed", "true")
    this.map.setPaintProperty("background", "background-color", "#f8f4f0")
  }

  onSelectCommune() {
    this.setCommuneState(this.selectedCodeInsee, { selected: true })
    this.map.setPaintProperty("background", "background-color", "#999999")
    const template = this.sidebarCommuneTemplateTargets.find(t => t.dataset.codeInsee == this.selectedCodeInsee)
    this.sidebarTarget.innerHTML = ''
    this.sidebarTarget.appendChild(template.content.cloneNode(true))
    this.sidebarTarget.removeAttribute("data-collapsed")
  }
}

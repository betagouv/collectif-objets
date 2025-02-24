import maplibregl from "maplibre-gl"
import "maplibre-gl/dist/maplibre-gl.css"
import OpenmaptilesStyle from "../lib/openmaptiles_style"

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wrapper", "container", "sidebar", "tooltip", "sidebarCommuneTemplate"]

  connect() {
    this.setupMap()
    this.setupKeyboardNavigation()
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  setupMap() {
    const { layers: defaultLayers, ...defaultStyle } = OpenmaptilesStyle
    const departement = JSON.parse(this.wrapperTarget.dataset.departementJson)
    // Plus d'infos sur l'utilisation des tuiles ici : https://guides.data.gouv.fr/reutiliser-des-donnees/utiliser-les-api-geographiques/utiliser-les-tuiles-vectorielles
    this.map = new maplibregl.Map({
      container: this.containerTarget,
      bounds: departement.boundingBox,
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
                ["==", ["feature-state", "focused"], true],
                3,
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
                ["==", ["feature-state", "focused"], true],
                .8,
                0.5
              ],
              "fill-color": [
                'case',
                ['==', ['feature-state', 'status'], "prioritaire"],
                '#b34001',
                ['==', ['feature-state', 'status'], "completed"],
                '#99C221',
                ['==', ['feature-state', 'status'], "started"],
                '#6b6af4',
                ['==', ['feature-state', 'status'], "inactive"],
                '#dddddd',
                'transparent'
              ]
            }
          }
        ]),
        ...defaultStyle
      },
    })

    this.map.on('load', () => {
      this.initInteractions()
      this.hydrateStatuses()
    })

    this.map.addControl(new maplibregl.NavigationControl({ showCompass: false }))
  }

  setupKeyboardNavigation() {
    this.containerTarget.setAttribute("tabindex", "0")
    this.containerTarget.setAttribute("role", "region")
    this.containerTarget.setAttribute("aria-label", "Carte des communes")

    this.communes = []
    this.currentFocusIndex = -1

    this.containerTarget.addEventListener("keydown", this.handleKeyDown.bind(this))
  }

  initInteractions() {
    this.focusedCodeInsee = null
    this.selectedCodeInsee = null

    this.map.on("mousemove", "communes-fills", event => {
      if (event.features.length == 0) return
      const feature = event.features[0]
      const state = this.map.getFeatureState({
        source: "decoupage-administratif",
        sourceLayer: "communes",
        id: feature.id
      })

      if (state.selectable) {
        this.focusCommune(feature.id)
        this.map.getCanvas().style.cursor = "pointer"
      }
    })

    this.map.on("mouseleave", "communes-fills", () => {
      this.map.getCanvas().style.cursor = ""
      if (this.focusedCodeInsee && this.focusedCodeInsee !== this.selectedCodeInsee) {
        this.clearFocus()
      }
    })

    this.map.on("click", "communes-fills", event => {
      if (event.features.length == 0) {
        this.clearFocus()
        this.closeSidebar()
        return
      }

      const feature = event.features[0]
      const state = this.map.getFeatureState({
        source: "decoupage-administratif",
        sourceLayer: "communes",
        id: feature.id
      })

      if (state.selectable) {
        this.selectCommune(feature.id)
      } else {
        this.clearFocus()
        this.closeSidebar()
      }
    })
  }

  handleKeyDown(event) {
    if (!this.communes.length) {
      const communesData = JSON.parse(this.wrapperTarget.dataset.communesJson)
      this.communes = communesData.map(c => c.code_insee)
    }

    switch(event.key) {
      case "Tab":
        event.preventDefault()
        if (event.shiftKey) {
          this.focusPreviousCommune()
        } else {
          this.focusNextCommune()
        }
        break
      case "Enter":
      case " ":
        event.preventDefault()
        if (this.currentFocusIndex >= 0) {
          this.selectCommune(this.communes[this.currentFocusIndex])
        }
        break
      case "Escape":
        event.preventDefault()
        this.closeSidebar()
        break
    }
  }

  focusNextCommune() {
    if (this.currentFocusIndex < this.communes.length - 1) {
      this.currentFocusIndex++
    } else {
      this.currentFocusIndex = 0
    }
    this.focusCommune(this.communes[this.currentFocusIndex])
  }

  focusPreviousCommune() {
    if (this.currentFocusIndex > 0) {
      this.currentFocusIndex--
    } else {
      this.currentFocusIndex = this.communes.length - 1
    }
    this.focusCommune(this.communes[this.currentFocusIndex])
  }

  focusCommune(codeInsee) {
    if (this.focusedCodeInsee === codeInsee) return

    this.clearFocus()
    this.focusedCodeInsee = codeInsee
    this.setCommuneState(codeInsee, { focused: true })
  }

  clearFocus() {
    if (!this.focusedCodeInsee) return
    this.setCommuneState(this.focusedCodeInsee, { focused: false })
    this.focusedCodeInsee = null
  }

  selectCommune(codeInsee) {
    if (this.selectedCodeInsee) {
      this.setCommuneState(this.selectedCodeInsee, { selected: false })
    }

    this.selectedCodeInsee = codeInsee
    this.setCommuneState(codeInsee, { selected: true })
    this.openSidebar()
  }

  openSidebar() {
    this.map.setPaintProperty("background", "background-color", "#999999")
    const template = this.sidebarCommuneTemplateTargets.find(t => t.dataset.codeInsee == this.selectedCodeInsee)
    this.sidebarTarget.innerHTML = ''
    this.sidebarTarget.appendChild(template.content.cloneNode(true))
    this.sidebarTarget.removeAttribute("data-collapsed")
  }

  closeSidebar() {
    if (this.selectedCodeInsee) {
      this.setCommuneState(this.selectedCodeInsee, { selected: false })
      this.selectedCodeInsee = null
    }
    this.sidebarTarget.setAttribute("data-collapsed", "true")
    this.map.setPaintProperty("background", "background-color", "#f8f4f0")
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
    communes.forEach(commune => {
      let status = commune.status
      if (status === "completed" && (commune.en_peril_count || 0) > 0) {
        status = "prioritaire"
      }
      this.setCommuneState(commune.code_insee, { status, selectable: true })
    })
  }
}

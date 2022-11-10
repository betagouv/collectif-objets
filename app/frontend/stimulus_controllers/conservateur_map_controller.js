import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wrapper", "sidebar", "tooltip", "sidebarCommuneTemplate"]

  connect() {
    this.svgTarget = this.wrapperTarget.querySelector("svg")
    const communes = JSON.parse(this.wrapperTarget.dataset.communesJson)
    communes.filter(c => c.status == "completed").forEach(commune => {
      const pathTarget = this.svgTarget.querySelector(`path[id="${commune.code_insee}"]`)
      if (!pathTarget) {
        console.log(`no path found for id`, commune.code_insee)
        return
      }
      const klass = (commune.recensements_prioritaires_count || 0) > 0 ? "prioritaire" : "completed"
      pathTarget.classList.add(`selectable`)
      pathTarget.classList.add(`commune-${klass}`)
    })

    const { left, top } = this.svgTarget.getBoundingClientRect()
    this.svgOffset = { left, top }
    this.svgTarget.querySelectorAll(`path[data-nom]:not([class*="svg-pan"])`).forEach(pathElt => {
      pathElt.addEventListener("mouseover", () => {
        const { x: left, y: top } = pathElt.getBBox();
        this.tooltipTarget.style.left = `${Math.round(left)}px`;
        this.tooltipTarget.style.top = `${Math.round(top)}px`;
        this.tooltipTarget.innerHTML = pathElt.dataset.nom
        this.wrapperTarget.classList.add("tooltip-show")
      })
      pathElt.addEventListener("mouseout", () => {
        this.wrapperTarget.classList.remove("tooltip-show")
        this.tooltipTarget.innerHTML = pathElt.dataset.nom
      })
    })
    this.svgTarget.querySelectorAll(`path.selectable:not([class*="svg-pan"])`).forEach(pathElt =>
      pathElt.addEventListener("click", e => this.onPathClick(e))
    )
  }

  onPathClick(event) {
    if (this.wrapperTarget.classList.contains("select-overlay"))
      return
    event.stopPropagation()
    const selectedPath = event.currentTarget
    const codeInsee = selectedPath.getAttribute("id")
    const template = this.sidebarCommuneTemplateTargets.find(t => t.dataset.codeInsee == codeInsee)
    this.sidebarTarget.innerHTML = ''
    this.sidebarTarget.appendChild(template.content.cloneNode(true))
    this.sidebarTarget.removeAttribute("data-collapsed")
    this.wrapperTarget.classList.add("select-overlay")
    selectedPath.classList.add("selected")
    this.svgTargetListener = () => { this.closeSidebar() }
    this.svgTarget.addEventListener("click", this.svgTargetListener)
    return false;
  }

  closeSidebar() {
    if (!this.wrapperTarget.classList.contains("select-overlay"))
      return
    this.wrapperTarget.classList.remove("select-overlay")
    this.svgTarget.querySelector("path.selected").classList.remove("selected")
    this.sidebarTarget.setAttribute("data-collapsed", "true")
    this.svgTarget.removeEventListener("click", this.svgTargetListener)
  }
}

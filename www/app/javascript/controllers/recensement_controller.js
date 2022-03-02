import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "localisation",
    "recensable",
    "edificeNom",
    "etatSanitaireEdifice",
    "etatSanitaire",
    "securisation",
    "notes",
    "form"
  ]

  connect() {
    document.querySelectorAll('input[name="recensement[confirmation]"], input[name="recensement[localisation]"], input[name="recensement[recensable]"]')
      .forEach(elt => elt.addEventListener("change", _e => this.refreshFields()))
    this.refreshFields()
  }

  getCurrentValues() {
    return {
      confirmation: this.formTarget.
        querySelector('input[name="recensement[confirmation]"]').checked,
      localisation: this.formTarget.
        querySelector('input[name="recensement[localisation]"]:checked')?.value,
      recensable: this.formTarget
        .querySelector('input[name="recensement[recensable]"]:checked')
        ?.value == "true"
    }
  }

  toggleSection(sectionElt, enabled) {
    sectionElt.querySelector("legend")?.classList?.
      toggle("co-legend--disabled", !enabled)
    sectionElt.querySelectorAll('input[type=radio], input[type=text], textarea')
      .forEach(elt => elt.toggleAttribute("disabled", !enabled))
    sectionElt.querySelectorAll('.fr-input-group')
      .forEach(elt => elt.classList.toggle("fr-input-group--disabled", !enabled))
  }

  refreshFields() {
    const { confirmation, localisation, recensable } = this.getCurrentValues()
    this.toggleSection(this.localisationTarget, confirmation)
    this.toggleSection(this.edificeNomTarget, confirmation && localisation == "autre_edifice")
    this.toggleSection(this.recensableTarget, confirmation && ["edifice_initial", "autre_edifice"].includes(localisation))
    this.toggleSection(this.etatSanitaireEdificeTarget, confirmation && localisation != "absent" && recensable)
    this.toggleSection(this.etatSanitaireTarget, confirmation && localisation != "absent" && recensable)
    this.toggleSection(this.securisationTarget, confirmation && localisation != "absent" && recensable)
    this.toggleSection(this.notesTarget, confirmation && recensable)
    document.querySelector("input[type=submit]")
      .toggleAttribute("disabled", !confirmation)
  }
}

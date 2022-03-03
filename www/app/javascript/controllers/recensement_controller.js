import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "localisation",
    "recensable",
    "edificeNom",
    "etatSanitaireEdifice",
    "etatSanitaire",
    "securisation",
    "photos",
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
    sectionElt.querySelectorAll('input[type=radio], input[type=text], input[type=file], textarea')
      .forEach(elt => elt.toggleAttribute("disabled", !enabled))
    sectionElt.querySelectorAll('.fr-input-group, .fr-upload-group')
      .forEach(elt => elt.classList.toggle("fr-input-group--disabled", !enabled))
  }

  refreshFields() {
    const { confirmation, localisation, recensable } = this.getCurrentValues()
    this.toggleSection(this.localisationTarget, confirmation)
    this.toggleSection(this.edificeNomTarget, confirmation && localisation == "autre_edifice")
    this.toggleSection(this.recensableTarget, confirmation && ["edifice_initial", "autre_edifice"].includes(localisation))
    const mainFieldsCondition = confirmation && ["edifice_initial", "autre_edifice"].includes(localisation) && recensable
    this.toggleSection(this.etatSanitaireEdificeTarget, mainFieldsCondition)
    this.toggleSection(this.etatSanitaireTarget, mainFieldsCondition)
    this.toggleSection(this.securisationTarget, mainFieldsCondition)
    this.toggleSection(this.photosTarget, mainFieldsCondition)
    this.toggleSection(this.notesTarget, confirmation && recensable)
    document.querySelector("input[type=submit]")
      .toggleAttribute("disabled", !confirmation)
  }
}

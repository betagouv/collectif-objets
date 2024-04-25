import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "edificeNomFieldset", "edificeNomInput", "autreEdifice" ]

  check_autre_edifice() {
    this.edificeNomFieldsetTarget.classList.toggle("fr-hidden");
    if (this.autreEdificeTarget.selected)
      this.edificeNomInputTarget.value = "";
  }
}
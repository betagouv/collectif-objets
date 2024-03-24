import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "edificeNom", "edificeId", "autreEdificeCheckbox" ]

  connect() {
    this.check_autre_edifice();
  }

  check_autre_edifice() {
    this.edificeIdTarget.disabled = this.autreEdificeCheckboxTarget.checked;
    this.edificeNomTarget.style.display = this.autreEdificeCheckboxTarget.checked ? "block" : "none";
  }
}
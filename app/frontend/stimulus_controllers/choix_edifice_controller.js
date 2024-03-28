import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "edificeNom", "autreEdifice" ]

  connect() {
    this.check_autre_edifice();
  }

  check_autre_edifice() {
    this.edificeNomTarget.style.display = this.autreEdificeTarget.selected ? "block" : "none";
  }
}
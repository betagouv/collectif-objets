import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "edificeNomFieldset", "edificeNomInput", "autreEdifice" ]

  // connect() {
  //   this.check_autre_edifice();
  // }

  check_autre_edifice() {
    this.edificeNomFieldsetTarget.classList.toggle("fr-hidden");
    if (this.autreEdificeTarget.selected)
      this.edificeNomInputTarget.value = "";
  }

  autre_commune_selected(event) {
    // event.currentTarget.closest("form").requestSubmit();
  }

}
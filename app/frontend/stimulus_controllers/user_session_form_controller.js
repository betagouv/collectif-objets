import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["communeForm", "submitCommuneFormButton", "changeButton", "departementSelect", "communeGroup"]

  connect() {
    this.changeButtonTargets.forEach((button) => button.remove());
    this.departementSelectTarget.removeAttribute("disabled");
    this.communeGroupTarget.classList.remove("hide");
    if (this.hasSubmitCommuneFormButtonTarget)
      this.submitCommuneFormButtonTarget.setAttribute("disabled", "disabled");
  }

  submitCommuneForm() {
    this.communeFormTarget.requestSubmit();
  }
}

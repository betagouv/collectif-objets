import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleClick(event) {
    event.preventDefault();
    Turbo.visit(event.currentTarget.dataset.href, { frame: "recensement_form_step" })
    return false;
  }
}

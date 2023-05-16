import { Controller } from "@hotwired/stimulus"
import { debounce } from 'throttle-debounce';

export default class extends Controller {
  static targets = [
    "form",
    "input",
    "inputWrap",
    "results"
  ]

  initialize() {
    this.debouncedSubmit = debounce(400, () => this.formTarget.requestSubmit()).bind(this)
  }

  performSearch() {
    this.toggleSpinner(true)
    this.debouncedSubmit()
  }

  toggleSpinner(show) {
    this.inputWrapTarget.classList.toggle("fr-icon-refresh-line", show)
  }

  hideSpinner() {
    this.toggleSpinner(false)
    this.hasResultsTarget && this.resultsTarget.classList.toggle("hide", false)
  }

  hideResults() {
    this.hasResultsTarget && this.resultsTarget.classList.toggle("hide", true)
  }
}

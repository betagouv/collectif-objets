import { Controller } from "@hotwired/stimulus"
import { Chart } from "frappe-charts";

export default class extends Controller {
  static targets = ["wrapper"]

  connect() {
    const values = JSON.parse(this.wrapperTarget.dataset.values)
    const labels = JSON.parse(this.wrapperTarget.dataset.labels)
    const colors = JSON.parse(this.wrapperTarget.dataset.colors)

    new Chart(
      this.wrapperTarget,
      {
        data: { labels, datasets: [{ values }] },
        type: 'percentage',
        colors
      }
    )
  }
}

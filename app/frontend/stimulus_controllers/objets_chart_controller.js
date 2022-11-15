import { Controller } from "@hotwired/stimulus"
import { Chart } from "frappe-charts";

export default class extends Controller {
  static targets = ["wrapper"]

  connect() {
    const values = JSON.parse(this.wrapperTarget.dataset.values)
    if (!this.wrapperTarget.dataset.type == "etats-sanitaires") return

    new Chart(
      this.wrapperTarget,
      {
        data: {
          labels: ["En péril", "Mauvais état", "État moyen", "Bon état"],
          datasets: [{ values: values }]
        },
        type: 'percentage',
        height: 150,
        colors: ['#b34001', '#8585f7', "#aeadf9", "#cdcefc"],
        // format_tooltip_x: d => `${d} objets`
      }
    )
  }
}

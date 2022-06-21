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
          labels: ["Bon état", "État moyen", "Mauvais état", "En péril"],
          datasets: [{ values: values }]
        },
        type: 'percentage',
        height: 150,
        colors: ['#9EF9BE', '#FDE2B5', "#EAC7AD", "#FDDFDB"],
        // format_tooltip_x: d => `${d} objets`
      }
    )
  }
}

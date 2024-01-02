import { Controller } from "@hotwired/stimulus"
import Chart from 'chart.js/auto'

export default class extends Controller {
  static targets = ["chart"]

  connect() {
    this.elt = this.scope.element
    const datasets = JSON.parse(this.elt.dataset.datasets)
    const unitSuffix = this.elt.dataset.unitSuffix
    const xTitle = this.elt.dataset.xTitle
    new Chart(
      this.elt,
      {
        type: 'bar',
        data: {
          labels: [""],
          datasets
        },
        options: {
          indexAxis: 'y',
          scales: { y: { stacked: true }, x: { stacked: true, title: { display: true, text: xTitle } } },
          plugins: {
            tooltip: {
              callbacks: {
                label: (context) => `${context.dataset.label} : ${context.parsed.x} ${unitSuffix}`
              }
            }
          },
          aspectRatio: 3,
          animation: {
            duration: 0
          }
        }
      }
    )
  }
}

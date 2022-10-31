import { Controller } from "@hotwired/stimulus"
import Spotlight from "spotlight.js/src/js/spotlight"
import 'spotlight.js/dist/css/spotlight.min.css'

export default class extends Controller {
  static targets = ["photos", "gallery", "anchor"]

  show(e) {
    e.preventDefault()
    const data = JSON.parse(this.photosTarget.dataset.imagesJson)
    const index = e.currentTarget.dataset.index ? Number(e.currentTarget.dataset.index) : null
    Spotlight.init({ force: true })
    Spotlight.show(data, { index: index })
  }
}

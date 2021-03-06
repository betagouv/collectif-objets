import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["photos", "gallery", "anchor"]

  show(e) {
    e.preventDefault()
    const urls = JSON.parse(this.photosTarget.dataset.urlsJson)
    const index = e.currentTarget.dataset.index ? Number(e.currentTarget.dataset.index) : null
    Spotlight.show(
      urls.map(url => ({ src: url })),
      { index: index }
    )
  }
}

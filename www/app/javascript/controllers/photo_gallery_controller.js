import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["photos", "gallery", "anchor"]

  show(e) {
    e.preventDefault()
    Spotlight.show(
      Array.from(this.photosTarget.querySelectorAll("img")).map(e => ({
        src: e.getAttribute("src"),
        thumb: e.getAttribute("src"),
      }))
    )
  }
}

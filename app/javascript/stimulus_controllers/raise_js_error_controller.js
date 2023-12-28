import { Controller } from "@hotwired/stimulus"

class OnPurposeJSError extends Error { }

export default class extends Controller {
  connect() {
    throw new OnPurposeJSError("testing!");
  }
}

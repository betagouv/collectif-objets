import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["accordionMember"]

  print(event) {
    event.preventDefault()
    if (this.hasAccordionMemberTarget) {
      this.accordionMemberTargets.forEach(t => this.discloseAccordionMember(t))
    }
    window.setTimeout(() => window.print(), 300)
  }

  discloseAccordionMember(accordionMember) {
    if (!window.dsfr) return
    const accordionGroup = accordionMember.closest("[data-fr-js-accordions-group]")
    if (!accordionGroup) return
    const index = [...accordionGroup.children].indexOf(accordionMember);
    if (index < 0) return
    window.dsfr(accordionGroup).accordionsGroup.members[index].disclose()
  }
}

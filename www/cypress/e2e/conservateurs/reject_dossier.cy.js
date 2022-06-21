const BASE_URL = "http://localhost:3090"

describe('empty spec', () => {
  beforeEach(() => {
    cy.request('/cypress_rails_reset_state')
    cy.request("post", `${BASE_URL}/cypress/fixtures`)
  })

  it('passes', async () => {
    cy.visit(BASE_URL)
    cy.contains("Connexion").click()
    cy.contains("div", "Email").find("input").first().type("jeanne@culture.gouv.fr")
    cy.contains("Recevoir un lien de connexion").click()
    const getLastMail = () => {
      return new Promise(resolve => {
        cy.request(`${BASE_URL}/cypress/mails/last`).then(resolve)
      })
    }
    const res = await getLastMail()
    const raw_html = res.body.body.raw_source
    const token = raw_html.match(/login_token=([a-z0-9]+)/)[1]
    cy.visit(`${BASE_URL}/conservateurs/sign_in_with_token?login_token=${token}`)
    cy.contains("Drôme").click()
    cy.contains("Albon").click()

    // override field on first recensement
    cy.contains("Bouquet d'Autel").click()
    cy.contains(".attribute-group", "Comment évaluez-vous l’état sanitaire de l’objet ?")
      .contains("Modifier")
      .click()
    cy.contains(".attribute-group", "Comment évaluez-vous l’état sanitaire de l’objet ?")
      .find("select")
      .first()
      .select("En péril")
    cy.contains(".attribute-group", "Comment évaluez-vous l’état sanitaire de l’objet ?")
      .contains("Choisir")
      .click()
    cy.contains("Sauvegarder").click()

    cy.contains("Retour à la liste des recensements de la commune").click()

    cy.contains("Renvoyer le dossier à la commune …").click()

    cy.contains("div", "Vos retours pour la commune")
      .find("textarea")
      .type("Veuillez renseigner les photos please")
    cy.contains("Photos floues").click()

    cy.contains("div", "Vos retours pour la commune")
      .find("textarea")
      .should("include.value", "Une partie des photos que vous avez envoyées sont trop floues")

    cy.contains("Préparer le mail de renvoi").click()
    cy.get('.co-mail-preview-iframe')
      .iframe()
      .should('include.text', "Monsieur le Maire")

    cy.contains("input", "Renvoyer le dossier").click()
    cy.get("body").should("include.text", "Dossier renvoyé à la commune")


  })
})

# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.feature "Reset password", type: :feature, js: true do
  let!(:conservateur) do
    create(
      :conservateur,
      email: "jeanne.michel@culture.gouv.fr",
      password: "alexandre-lenoir-a-ete-le-premier-conservateur-sympa"
    )
  end

  scenario "reset password happy path" do
    visit "/"
    click_on "Connexion"
    click_on "Je suis conservateur ou conservatrice"
    click_on "Mot de passe oublié ?"
    fill_in "Email", with: "jeanne.michel@culture.gouv.fr"
    click_on "Recevoir un lien de réinitialisation du mot de passe"
    expect(page).to have_text(
      "Vous allez recevoir sous quelques minutes un email vous " \
      "indiquant comment réinitialiser votre mot de passe."
    )
    email = ActionMailer::Base.deliveries.last
    expect(email.subject).to eq("Instructions pour changer le mot de passe")
    res = email.body.match(%r{/conservateurs/password/edit\?reset_password_token=[a-zA-Z0-9\-_]+})
    expect(res).not_to be_nil
    reset_password_path = res[0]
    visit(reset_password_path)
    expect(page).to have_text("Changer votre mot de passe")
    fill_in "Nouveau mot de passe", with: "le-nouveau-mot-de-passe-est-tres-long"
    fill_in "Confirmation du nouveau mot de passe", with: "le-nouveau-mot-de-passe-est-tres-long"
    click_on "Changer le mot de passe"
    expect(page).to have_text("Votre mot de passe a bien été modifié. Vous êtes maintenant connecté(e)")
    expect(conservateur.reload.valid_password?("le-nouveau-mot-de-passe-est-tres-long")).to be(true)
  end

  scenario "reset password unknown email" do
    visit "/"
    click_on "Connexion"
    click_on "Je suis conservateur ou conservatrice"
    click_on "Mot de passe oublié ?"
    fill_in "Email", with: "jean.marc@culture.gouv.fr"
    click_on "Recevoir un lien de réinitialisation du mot de passe"
    expect(page).to have_text(
      "Impossible de trouver un compte conservateur ou conservatrice pour l'email jean.marc@culture.gouv.fr"
    )
  end

  context "expired token" do
    let!(:reset_password_token) { conservateur.send_reset_password_instructions }
    before do
      conservateur.update_columns(reset_password_sent_at: 2.weeks.ago)
    end
    scenario "reset password expired token" do
      visit "/conservateurs/password/edit?reset_password_token=#{reset_password_token}"
      fill_in "Nouveau mot de passe", with: "lhistoire-de-lart-est-passionnante-nest-ce-pas"
      fill_in "Confirmation du nouveau mot de passe", with: "lhistoire-de-lart-est-passionnante-nest-ce-pas"
      click_on "Changer le mot de passe"
      expect(page).to have_text("Ce lien de réinitialisation a expiré")
    end
  end

  context "valid token" do
    let!(:conservateur) do
      create(
        :conservateur,
        email: "jeanne.michel@culture.gouv.fr",
        password: "alexandre-lenoir-a-ete-le-premier-conservateur-sympa"
      )
    end
    let!(:reset_password_token) { conservateur.send_reset_password_instructions }
    scenario "reset password confirmation mismatch" do
      visit "/conservateurs/password/edit?reset_password_token=#{reset_password_token}"
      fill_in "Nouveau mot de passe", with: "lhistoire-de-lart-est-passionnante-nest-ce-pas"
      fill_in "Confirmation du nouveau mot de passe", with: "ca-na-rien-a-voir-cette-confirmation-cest-nul"
      click_on "Changer le mot de passe"
      expect(page).to have_text("Les deux mots de passe ne correspondent pas, veuillez réessayer")
    end

    scenario "reset password too short" do
      visit "/conservateurs/password/edit?reset_password_token=#{reset_password_token}"
      fill_in "Nouveau mot de passe", with: "tropcourt"
      fill_in "Confirmation du nouveau mot de passe", with: "tropcourt"
      click_on "Changer le mot de passe"
      expect(page).to have_text("Le mot de passe doit contenir au minimum 20 caractères")
    end
  end
end
# rubocop:enable Metrics/BlockLength

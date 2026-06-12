# frozen_string_literal: true

require "rails_helper"

feature "Authentification à deux facteurs des admins", js: true do
  def sign_in_with(email:, password: "password", otp: nil)
    visit new_admin_user_session_path
    fill_in "admin_user[email]", with: email
    fill_in "admin_user[password]", with: password
    fill_in "admin_user[otp_attempt]", with: otp if otp
    click_on "Se connecter"
  end

  # Wait for DSFR accordion to be interactive, and open the requested section
  def open_accordion(title, selector)
    3.times do
      click_button title
      return if page.has_css?(selector, wait: 2)
    end
    expect(page).to have_css(selector)
  end

  def current_otp
    admin.reload.update!(consumed_timestep: nil)
    admin.current_otp
  end

  context "admin sans 2FA" do
    let!(:admin) { create(:admin_user, otp_required_for_login: false, otp_secret: nil) }

    scenario "est forcé d'activer la 2FA et voit un QR code" do
      sign_in_with(email: admin.email)

      expect(page).to have_current_path(admin_two_factor_settings_path)

      visit admin_communes_path
      expect(page).to have_current_path(admin_two_factor_settings_path)
      expect(page).to have_text("Vous devez activer l’authentification à deux facteurs")
      expect(page).to have_css("svg.otp-qrcode")
      expect(page).to have_button("Activer l'authentification à deux facteurs")
    end
  end

  context "admin avec 2FA" do
    let!(:admin) { create(:admin_user) }

    scenario "se connecte avec un code temporaire, gère ses codes de secours puis désactive la 2FA" do
      sign_in_with(email: admin.email, otp: admin.current_otp)
      expect(page).to have_link("Déconnexion")

      visit admin_communes_path
      expect(page).to have_current_path(admin_communes_path)

      visit admin_two_factor_settings_path
      expect(page).to have_text("Votre compte est protégé par l'authentification à deux facteurs")

      open_accordion "Générer de nouveaux codes de secours", "form[action$='regenerate_backup_codes']"
      within("form[action$='regenerate_backup_codes']") do
        fill_in "password", with: "password"
        fill_in "otp_attempt", with: current_otp
        click_on "Générer de nouveaux codes"
      end
      expect(page).to have_current_path(backup_codes_admin_two_factor_settings_path)
      expect(page).to have_text("Nouveaux codes de secours générés")
      expect(page).to have_text("sauvegardez ces codes de secours")

      visit admin_two_factor_settings_path
      open_accordion "Désactiver l'authentification à 2 facteurs", "form[action$='disable']"
      within("form[action$='disable']") do
        fill_in "password", with: "password"
        fill_in "otp_attempt", with: current_otp
        click_on "Désactiver l'authentification à deux facteurs"
      end
      expect(page).to have_text("Authentification à deux facteurs désactivée")

      visit admin_communes_path
      expect(page).to have_current_path(admin_two_factor_settings_path)
      expect(page).to have_text("Vous devez activer l’authentification à deux facteurs")
      expect(page).to have_css("svg.otp-qrcode")
    end

    scenario "se connecte avec un code de secours" do
      backup_codes = admin.generate_otp_backup_codes!
      admin.save!

      sign_in_with(email: admin.email, otp: backup_codes.first)

      expect(page).to have_link("Déconnexion")
      expect(page).to have_text("Connecté avec un code de secours")
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Stats, type: :model do
  let(:stats) { described_class.new }

  describe "#total_départements_actifs" do
    subject { stats.total_départements_actifs }

    before do
      departements = create_list(:departement, 5)
      create(:campaign, :draft, departement: departements[0])
      create(:campaign, :planned, departement: departements[1])

      # Make departments 2 and 3 active
      create(:campaign, :ongoing, departement: departements[2])
      create(:campaign, :finished, departement: departements[2])
      create(:campaign, :finished, departement: departements[3])
    end

    it { is_expected.to eq(2) }
  end

  describe "#total_objets_protégés" do
    subject { stats.total_objets_protégés }

    before do
      commune = create(:commune)
      create(:objet, commune:)
      create(:objet, :classé, commune:)
      create(:objet, :inscrit, commune:)
    end

    it { is_expected.to eq(3) }
  end

  describe "#total_objets_protégés_dans_départements_actifs" do
    subject { stats.total_objets_protégés_dans_départements_actifs }

    before do
      dept_actif = create(:departement, code: "01")
      dept_inactif = create(:departement, code: "02")
      create(:campaign, :ongoing, departement: dept_actif)

      commune_active = create(:commune, departement: dept_actif)
      commune_inactive = create(:commune, departement: dept_inactif)

      create(:objet, :classé, commune: commune_active)
      create(:objet, :inscrit, commune: commune_active)
      create(:objet, :classé, commune: commune_inactive)
    end

    it { is_expected.to eq(2) }
  end

  describe "#total_objets_recensés" do
    subject { stats.total_objets_recensés }

    before do
      dept_actif = create(:departement, code: "01")
      dept_inactif = create(:departement, code: "02")
      create(:campaign, :ongoing, departement: dept_actif)

      commune_active = create(:commune, departement: dept_actif)
      commune_inactive = create(:commune, departement: dept_inactif)

      objet1 = create(:objet, commune: commune_active)
      objet2 = create(:objet, commune: commune_active)
      objet3 = create(:objet, commune: commune_inactive)

      create(:recensement, objet: objet1)
      create(:recensement, objet: objet2)
      create(:recensement, objet: objet3)
    end

    it "returns distinct objets recensés in active départements only" do
      expect(subject).to eq(2)
    end
  end

  describe "#ratio_objets_recensés" do
    subject { stats.ratio_objets_recensés }

    before do
      dept = create(:departement)
      create(:campaign, :ongoing, departement: dept)
      commune = create(:commune, departement: dept)

      objets = create_list(:objet, 5, :classé, commune:)
      create(:recensement, objet: objets[0])
      create(:recensement, objet: objets[1])
    end

    it "returns percentage of recensed objets" do
      expect(subject).to eq(40)
    end
  end

  describe "#total_campagnes_actives" do
    subject { stats.total_campagnes_actives }

    before do
      dept1 = create(:departement, code: "01")
      dept2 = create(:departement, code: "02")
      dept3 = create(:departement, code: "03")
      dept4 = create(:departement, code: "04")

      create(:campaign, :draft, departement: dept1)
      create(:campaign, :planned, departement: dept2)
      create(:campaign, :ongoing, departement: dept3)
      create(:campaign, :finished, departement: dept4)
    end

    it { is_expected.to eq(2) }
  end

  describe "#total_communes_participantes" do
    subject { stats.total_communes_participantes }

    before do
      commune1 = create(:commune)
      commune2 = create(:commune)
      commune3 = create(:commune)

      create(:dossier, :submitted, commune: commune1)
      create(:dossier, :accepted, commune: commune2)
      create(:dossier, :construction, commune: commune3)
    end

    it "returns communes with submitted dossiers" do
      expect(subject).to eq(2)
    end
  end

  describe "#total_communes_contactées" do
    subject { stats.total_communes_contactées }

    before do
      dept = create(:departement)
      dept2 = create(:departement, code: "99")
      campaign1 = create(:campaign, :ongoing, departement: dept)
      campaign2 = create(:campaign, :draft, departement: dept2)

      commune1 = create(:commune, :with_user, departement: dept)
      commune2 = create(:commune, :with_user, departement: dept)
      commune3 = create(:commune, :with_user, departement: dept2)

      campaign1.recipients.create!(commune: commune1, unsubscribe_token: "token1")
      campaign1.recipients.create!(commune: commune2, unsubscribe_token: "token2")
      campaign2.recipients.create!(commune: commune3, unsubscribe_token: "token3")
    end

    it "returns distinct communes in active campaigns" do
      expect(subject).to eq(2)
    end
  end

  describe "#ratio_communes_contactées" do
    subject { stats.ratio_communes_contactées }

    before do
      dept = create(:departement)
      create(:campaign, :ongoing, departement: dept)
      communes = create_list(:commune, 10, :with_user, departement: dept)

      campaign = Campaign.active.first
      communes.take(3).each do |commune|
        campaign.recipients.create!(commune:, unsubscribe_token: SecureRandom.hex(10))
      end
    end

    it "returns percentage of contacted communes in active depts" do
      expect(subject).to eq(30)
    end
  end

  describe "#list_campagnes_par_département" do
    subject { stats.list_campagnes_par_département }

    before do
      dept1 = create(:departement, code: "01")
      dept2 = create(:departement, code: "02")

      create(:campaign, :ongoing, departement: dept1)
      create(:campaign, :finished, departement: dept1)
      create(:campaign, :ongoing, departement: dept2)
      create(:campaign, :draft, departement: dept2)
    end

    it "returns hash of active campaigns count per département" do
      expect(subject).to eq({ "01" => 2, "02" => 1 })
    end
  end

  describe "#total_recensements_préoccupants" do
    subject { stats.total_recensements_préoccupants }

    before do
      dossier_accepted = create(:dossier, :accepted)
      dossier_submitted = create(:dossier, :submitted)

      create(:recensement, :bon_etat, dossier: dossier_accepted)
      create(:recensement, :en_peril, dossier: dossier_accepted)
      create(:recensement, :mauvais_etat, dossier: dossier_accepted)
      create(:recensement, :mauvais_etat, dossier: dossier_submitted)
    end

    it "returns count of préoccupants recensements in accepted dossiers only" do
      expect(subject).to eq(2)
    end
  end

  describe "#ratio_recensements_préoccupants" do
    subject { stats.ratio_recensements_préoccupants }

    before do
      dossier = create(:dossier, :accepted)
      create_list(:recensement, 8, :bon_etat, dossier:)
      create_list(:recensement, 2, :mauvais_etat, dossier:)
    end

    it "returns percentage of préoccupants recensements" do
      expect(subject).to eq(20)
    end
  end

  describe "#total_objets_prioritaires_pris_en_charge" do
    subject { stats.total_objets_prioritaires_pris_en_charge }

    before do
      dept_actif = create(:departement, code: "01")
      dept_inactif = create(:departement, code: "02")
      create(:campaign, :ongoing, departement: dept_actif)

      commune_active = create(:commune, departement: dept_actif)
      commune_inactive = create(:commune, departement: dept_inactif)
      dossier_actif = create(:dossier, :construction, commune: commune_active)
      dossier_inactif = create(:dossier, :construction, commune: commune_inactive)
      conservateur = create(:conservateur)

      # Objet prioritaire, analysé, département actif - COUNTED
      objet_complet = create(:objet, commune: commune_active)
      rec1 = create(:recensement, :en_peril, objet: objet_complet, dossier: dossier_actif)
      rec1.update!(analysed_at: Time.current, conservateur:)

      # Objet prioritaire (disparu), analysé, département actif - COUNTED
      objet_disparu = create(:objet, commune: commune_active)
      rec2 = create(:recensement, :disparu, objet: objet_disparu, dossier: dossier_actif)
      rec2.update!(analysed_at: Time.current, conservateur:)

      # Objet prioritaire, non analysé, département actif - NOT COUNTED
      objet_non_analysé = create(:objet, commune: commune_active)
      create(:recensement, :en_peril, objet: objet_non_analysé, dossier: dossier_actif)

      # Objet non prioritaire, analysé, département actif - NOT COUNTED
      objet_non_prioritaire = create(:objet, commune: commune_active)
      rec4 = create(:recensement, :bon_etat, objet: objet_non_prioritaire, dossier: dossier_actif)
      rec4.update!(analysed_at: Time.current, conservateur:)

      # Objet prioritaire, analysé, département inactif - NOT COUNTED
      objet_dept_inactif = create(:objet, commune: commune_inactive)
      rec5 = create(:recensement, :en_peril, objet: objet_dept_inactif, dossier: dossier_inactif)
      rec5.update!(analysed_at: Time.current, conservateur:)
    end

    it "returns count of prioritaire objets that are analysed in active départements" do
      expect(subject).to eq(2)
    end
  end

  describe "#ratio with zero denominator" do
    subject { stats.ratio_objets_recensés }

    it "returns 0 when no objets exist" do
      expect(subject).to eq(0)
    end
  end
end

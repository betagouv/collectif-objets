# frozen_string_literal: true

require "csv"

namespace :campaigns do

  # rake "campaigns:import[../collectif-objets-data/2022_08_29_import_campaigns.csv]"
  task :import, [:path] => :environment do |_, args|
    CSV.read(args[:path], headers: :first_row)
      .map(&:to_h).map(&:symbolize_keys)
      .select { _1[:finished].downcase == "yes" }
      .reject { _1[:departement_code] == "52" }
      # .first(1)
      .each { ImportCampaign.new(_1).perform; puts }
  end

  class ImportCampaign
    def initialize(raw)
      @raw = raw.with_indifferent_access
    end

    def perform
      puts "importing campaign #{raw}"
      puts "found #{sib_contacts.count} sib contacts and #{communes.count} communes"
      log_missing_communes
      campaign = Campaign.new(**campaign_attributes, recipients_attributes:)
      success = campaign.save
      if success
        Campaigns::RefreshCampaignStatsJob.perform_async(campaign.id)
        return
      end

      raise "campaign for #{raw[:departement_code]} errors : #{campaign.errors.full_messages.join(",")}"
    end

    private

    attr_reader :raw

    def campaign_attributes
      {
        departement: Departement.find(raw[:departement_code]),
        date_lancement: Date.parse(raw[:date_lancement]),
        date_relance1: Date.parse(raw[:date_relance1]),
        date_relance2: Date.parse(raw[:date_relance2]),
        date_relance3: Date.parse(raw[:date_relance3]),
        date_fin: Date.parse(raw[:date_fin]),
        nom_drac: raw[:nom_drac],
        sender_name: raw[:sender_name],
        signature: raw[:signature],
        status: "finished",
        imported: true
      }
    end

    def log_missing_communes
      sib_contacts_without_communes.each do |sib_contact|
        puts "⚠️ no commune found for #{sib_contact[:email]}"
      end
    end

    def recipients_attributes
      sib_contacts_augmented_to_import.map do |sib_contact|
        {
          commune_id: sib_contact[:commune_id],
          current_step: "fin",
          opt_out: sib_contact[:opt_out].presence,
          opt_out_reason: sib_contact[:opt_out_reason].presence,
        }.compact
      end
    end

    def sib_contacts
      @sib_contacts ||= [:end_list, :enrolled_list, :started_list]
        .map { Co::SendInBlueClient.instance.get_list_id_contacts(raw[_1]) }
        .flatten
        .map { { email: _1[:email] } }
        .uniq { _1[:email] }
    end

    def sib_contacts_augmented
      @sib_contacts_augmented ||= \
        sib_contacts.map do |sib_contact|
          commune = communes.find { _1.email == sib_contact[:email] }
          sib_contact.merge(commune ? {commune_id: commune.id, commune_nom: commune.nom} : {})
        end
    end

    def sib_contacts_augmented_to_import
      sib_contacts_augmented
        .select { _1[:commune_id].present? }
        .uniq { _1[:commune_id] }
    end

    def sib_contacts_without_communes
      @sib_contacts_without_communes ||= sib_contacts_augmented.select { _1[:commune_id].nil? }
    end

    def communes
      @communes ||= communes_arel.to_a
    end

    def communes_arel
      User
        .joins(:commune)
        .where(communes: { departement_code: raw[:departement_code] })
        .where(email: sib_contacts.pluck(:email))
        .select("email", "communes.id", "communes.nom")
    end
  end

end

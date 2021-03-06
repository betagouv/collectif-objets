# frozen_string_literal: true

# rubocop:disable all
class SibExportCommunesCsv
  COMMUNES_TO_EXCLUDE_CODES_INSEE = {
    "58" => %w[
      58002 58005 58006 58007 58008 58015 58016 58021 58029 58036 58039
      58041 58043 58045 58046 58050 58054 58057 58060 58062 58066 58070
      58071 58075 58080 58081 58084 58086 58095 58096 58097 58098 58103
      58104 58113 58116 58117 58120 58121 58126 58130 58138 58139 58144
      58147 58148 58150 58152 58153 58158 58159 58160 58165 58166 58169
      58170 58181 58182 58187 58193 58194 58195 58197 58207 58211 58213
      58214 58216 58224 58225 58230 58237 58242 58251 58260 58264 58271
      58281 58283 58284 58286 58288 58289 58304 58305 58308
    ],
    "08" => %w[
      08106 08109 08166 08174 08189 08214 08304 08326 08331 08366 08385
      08394 08468 08480 08482 08483 08486
    ]
  }.freeze

  def initialize(departement)
    @departement = departement
  end

  def perform
    CSV.generate do |csv|
      csv << csv_headers
      communes.each do |commune|
        main_objet = main_objet(commune)
        magic_token = commune.users.first&.magic_token
        if magic_token
          magic_link = "https://collectif-objets.beta.gouv.fr/magic-authentication?magic-token=#{magic_token}"
        end
        if main_objet
          objet_desc_html = "<h3 style=\"padding:0 0 10px 0; margin: 0;\">#{main_objet.nom_formatted}</h3>Objet présent à #{commune.nom}<br /><b>#{main_objet.edifice_nom_formatted}</b>#{main_objet.emplacement}"
        end
        csv << [
          commune.nom,
          commune.departement,
          commune.users.first&.email,
          magic_link,
          commune.objets.count,
          main_objet&.image_urls&.first,
          objet_desc_html
        ]
      end
    end
  end

  private

  def csv_headers
    headers = %w[
      NOM
      DEPARTEMENT
      EMAIL
      TMP_MAGIC_LINK
      OBJETS_COMMUNE
      TMP_OBJET_IMG_URL
      TMP_OBJET_DESC_HTML
    ]
  end

  def set_departement
    @departement = params[:departement]
  end

  def communes
    @communes ||= Commune
      .where(departement: @departement)
      .where.not(code_insee: COMMUNES_TO_EXCLUDE_CODES_INSEE[@departement] || [])
      .includes(:objets)
      .to_a
      .sort_by { _1.objets.count }
      .reverse
  end

  def select_best_objets(objets_arr)
    current_arr = objets_arr
    [
      ->(obj) { obj.image_urls.any? },
      ->(obj) { obj.nom.exclude?(";") },
      ->(obj) { obj.nom.match?(/[A-Z]/) },
      ->(obj) { obj.edifice_nom.present? },
      ->(obj) { obj.edifice_nom&.match?(/[A-Z]/) },
      ->(obj) { obj.emplacement.blank? }
    ].each do |filter_fun|
      filtered_arr = current_arr.filter { filter_fun.call(_1) }
      current_arr = filtered_arr if filtered_arr.any?
    end
    current_arr
  end

  def main_objet(commune)
    select_best_objets(commune.objets.where.not(palissy_DENO: nil).to_a)
    .first
  end
end
# rubocop:enable all

# RSpec.describe Commune, type: :model do
#   describe "#main_objet" do
#     let!(:commune) { create(:commune) }

#     subject { commune.main_objet }
#     context "some objet has image" do
#       let!(:objet_without_image) { create(:objet, :without_image, commune:) }
#       let!(:objet_with_image) { create(:objet, :with_image, commune:) }
#       it { should eq objet_with_image }
#     end
#     context "none objets has image" do
#       let!(:objet_without_image1) { create(:objet, :without_image, commune:, palissy_DENO: "Statue de Jules Verne") }
#       let!(:objet_without_image2) { create(:objet, :without_image, commune:, palissy_DENO: "nom; pas terrible") }
#       it { should eq objet_without_image1 }
#     end
#     context "no objets at all" do
#       it { should eq nil }
#     end
#   end
# end

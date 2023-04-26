# frozen_string_literal: true

class RapportPresenter
  delegate :commune, :accepted_at, :conservateur, :notes_commune, :notes_conservateur, to: :dossier

  def initialize(dossier)
    @dossier = dossier
  end

  def each_recensement_item
    ordered_recensements.each_with_index do |recensement, index|
      yield recensement:,
            objet: recensement.objet,
            commune: recensement.commune,
            presenter: RecensementPresenter.new(recensement),
            index: index + 1
    end
  end

  def each_fiche_item
    fiches.each_with_index do |fiche, index|
      yield fiche:,
            recensements: ordered_recensements.select { _1.analyse_fiches.include?(fiche.id) },
            index: index + 1
    end
  end

  attr_reader :dossier

  def fiches
    @fiches ||= fiche_ids.map { Fiche.load_from_id(_1) }
  end

  private

  def ordered_recensements
    @ordered_recensements ||= @dossier
      .recensements
      .includes(:objet)
      .order('objets."palissy_EDIF" ASC, objets."palissy_REF"')
  end

  def fiche_ids
    @fiche_ids ||= ordered_recensements.map(&:analyse_fiches).flatten.uniq.sort
  end
end

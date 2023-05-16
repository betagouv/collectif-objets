# frozen_string_literal: true

Ransack.configure do |config|

  # cf https://github.com/activerecord-hackery/ransack/issues/349#issuecomment-381278150
  config.add_predicate 'unaccented_cont',
     arel_predicate: 'matches',
     formatter: proc { |s| ActiveSupport::Inflector.transliterate("%#{s}%") }, # Note the %%
     validator: proc { |s| s.present? },
     compounds: true,
     type: :string


  config.custom_arrows = {
    up_arrow: '<span class="fr-icon-arrow-up-s-fill" aria-hidden="true"></span>',
    down_arrow: '<span class="fr-icon-arrow-down-s-fill" aria-hidden="true"></span>',
    default_arrow: '<span class="fr-icon-arrow-down-s-line" aria-hidden="true"></span>'
  }
end

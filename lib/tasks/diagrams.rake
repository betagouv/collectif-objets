# frozen_string_literal: true

require 'aasm-diagram' if Rails.env.development?

namespace :diagrams do
  task :generate, [:path] => :environment do |_, args|
    AASMDiagram::Diagram.new(Commune.new.aasm, 'doc/commune_state_machine_diagram.png')
    AASMDiagram::Diagram.new(Dossier.new.aasm, 'doc/dossier_state_machine_diagram.png')
    AASMDiagram::Diagram.new(Campaign.new.aasm, 'doc/campaign_state_machine_diagram.png')
    # bundle exec erd
    # mv entity-relationship-diagram.svg doc
  end
end

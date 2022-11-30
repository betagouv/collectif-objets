# frozen_string_literal: true

require "csv"

namespace :edifices do
  task :shortest_slugs, [:path] => :environment do |_, args|
    Edifice.pluck(:slug)
      .tally
      .sort_by { |slug, count| slug&.length || 0 }
      .first(30)
      .each { puts "- slug '#{_1[0]}' : #{_1[1]} edifices "}
  end
end


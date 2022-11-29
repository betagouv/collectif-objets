# frozen_string_literal: true

require "csv"

namespace :objets do
  # rake "objets:stats[tmp/stats_avant.csv]"
  desc "export stats on objets"
  task :stats, [:path] => :environment do |_, args|
    PalissyStats.new(args[:path]).perform
  end
end


class PalissyStats
  def initialize(path)
    @path = path
  end

  def perform
    @file = File.open(@path, "wb")
    @total = Objet.count
    log "total: #{@total} objets"
    Synchronizer::ObjetRow::ALL_FIELDS.each { log_field(_1) }
    log_photos
    @file.close
  end

  private

  def log_field(field)
    db_field = "palissy_#{field}"
    log "\n\n---- #{field} ---\n"
    present_count = Objet.where.not(db_field => ["", nil]).count
    log "#{present_count} present values (#{percent(present_count)}%)"
    top_values = Objet.pluck(db_field).tally.sort_by(&:last).reverse.first(10)
    log "most common values:"
    top_values.each { log "- '#{_1[0]}' (#{_1[1]} objets - #{percent(_1[1])}%)" }
  end

  def log_photos
    log "\n\n ------ PHOTOS ------"
    present_count = Objet.with_images.count
    log "#{present_count}  objets have at least 1 photo (#{percent(present_count)}%)"
    total_photos = q('select count(*) as total from objets cross join unnest("palissy_photos") photos')[0]["total"]
    log "in total there are #{total_photos} photos"
    %w[url credit].each do |field_name|
      present_count = q(sql_json_present_count(field_name))[0]["total"]
      log "\namong all photos, #{field_name} is filled on #{present_count} photos (#{percent(present_count, total: total_photos)}%)"
      log "most common #{field_name} values:"
      top_values = q sql_json_top_values(field_name)
      top_values.map(&:values).each { log "- '#{_1[0]}' (#{_1[1]} objets - #{percent(_1[1])}%)" }
    end
  end

  def sql_json_present_count(field_name)
    <<~SQL.squish
      select count(*) as total
      from objets
      cross join unnest("palissy_photos") photos
      where (photos -> '#{field_name}')::text != 'null';
    SQL
  end

  def sql_json_top_values(field_name)
    <<~SQL.squish
      select (photo -> '#{field_name}')::text as field, count(*) as total
      from objets
      cross join unnest("palissy_photos") photo
      group by field
      order by total desc
      limit 10;
    SQL
  end

  def q(query)
    ActiveRecord::Base.connection.execute(query)
  end

  def log message
    puts message
    @file.puts message
  end

  def percent(count, total: @total)
    ((count.to_i * 100).to_f / total).round(2)
  end
end

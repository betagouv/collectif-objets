# frozen_string_literal: true

module Synchronizer
  class Logger
    def initialize(filename_prefix:)
      @counters = Hash.new(0)
      @file = File.open("tmp/#{filename_prefix}-#{timestamp}.log", "a+")
      Rails.logger.info "opened log file : #{file.path}"
    end

    def log(message, counter: nil)
      if message.present?
        Rails.logger.info message
        file.puts(message)
      end
      file.flush
      counters[counter] += 1 if counter
    end

    def close
      Rails.logger.info "counters: #{counters}"
      file.puts "\n---\n"
      file.puts "counters: #{counters}"
      file.flush
      file.close
      Rails.logger.info "wrote logs to : #{file.path}"
    end

    private

    attr_reader :file, :counters

    def timestamp = Time.zone.now.strftime("%Y_%m_%d_%HH%M")
  end
end

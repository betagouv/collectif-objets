# frozen_string_literal: true

require "net/http"
require "open-uri"
require "json"
require "fileutils"

def get_latest_npm_version(package_name)
  JSON.parse(Net::HTTP.get(URI("https://registry.npmjs.org/#{package_name}")))["dist-tags"]["latest"]
end

def get_current_local_version(package_name)
  File.read("config/importmap.rb").match(/pin "#{package_name}".* # @([0-9\.]+)/)[1]
end

def bump_local_version(package_name, version)
  text = File.read("config/importmap.rb")
  line_index = text.lines.find_index { _1.match(/pin "#{package_name}"/) }
  raise "Could not find line matching #{regex}" if line_index.nil?

  lines = text.lines.clone
  lines[line_index].gsub!(/\d+\.\d+\.\d+/, version)
  File.open("config/importmap.rb", "w") { |file| file.puts lines }
  puts "bumped #{package_name} to #{version} in config/importmap.rb !"
end

def download(url, to:)
  puts "downloading #{url}..."
  File.write(to, URI.open(url).read) # rubocop:disable Security/Open
end

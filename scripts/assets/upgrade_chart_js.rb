# frozen_string_literal: true

require_relative "base"

latest = get_latest_npm_version("chart.js")
current = get_current_local_version("chart.js")

if latest == current && !ARGV.include?("--force") # rubocop:disable Rails/NegateInclude
  puts "chart.js is already on #{latest} which is the latest version"
  exit
end

url = "https://cdn.jsdelivr.net/npm/chart.js@#{latest}/+esm"
path = "vendor/javascript/chart.js.js"
download(url, to: path)

File.write(
  path,
  File.read(path).gsub(%r{/npm/@kurkle/color@\d+\.\d+\.\d+/\+esm}, "@kurkle/color")
)
puts "manually replaced @kurkle/color import name in #{path}"

bump_local_version("chart.js", latest)

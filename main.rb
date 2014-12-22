# This example logs a user in to rubyforge and prints out the body of the
# page after logging the user in.
require 'rubygems'
require 'mechanize'
require 'logger'
require 'pry'
require 'pry-remote'
require 'pry-stack_explorer'
require 'ruby-daj'
require 'httparty'

# Create a new mechanize object
mech = Mechanize.new
mech.log = Logger.new $stderr
mech.agent.http.debug_output = $stderr

# Load the rubyforge website


class WebSite
  include HTTParty
  format :html
end

data = []

20.times do |i|
  sleep 2
  urls = JSON.parse(WebSite.get("http://www.kappastore.fr/adjnav/ajax/category/id/129/?&no_cache=true&p=#{i+1}").body)['products'].split(/\s+/).find_all { |u| u =~ /http?:/ }.reject{|s| s.match(/src/)}.map{|s| s[6..-1]}[2..-3]

  data << urls.map do |url|
    # puts "buuuuuuuug: #{url}"
    page = mech.get(url)
    name = page.search(".product-name h1").first.children.to_s
    description = page.search(".description .std").first.children.to_s
    image_url = page.search(".MagicToolboxContainer img").first[:src]
    {'Nom' => name, 'Description' => description, "Url de l'image" => image_url, 'id' => 1}
  end

end

data = data.first#.uniq{|hash| hash["Nom"]}

CSV.open('export.csv', "w") do |csv|
  csv << data.first.keys # adds the attributes name on the first line
  data.each {|hash| csv << hash.values}
end






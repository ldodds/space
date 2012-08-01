require 'rubygems'
require 'pho'

user = ENV["TALIS_USER"]
pass = ENV["TALIS_PASS"]

storename = "http://api.talis.com/stores/space"
if ENV["TALIS_STORE"]
  storename = "http://api.talis.com/stores/#{ENV["TALIS_STORE"]}"
end

store = Pho::Store.new(storename, user, pass)

Dir.glob("js/*.js").each do |file|
  puts file
  resp = store.upload_item( File.new(file), "application/javascript", "/items/#{file}")
  puts resp.status
end


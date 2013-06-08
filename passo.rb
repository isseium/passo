#!/usr/bin/env ruby

require "fitgem"
require "pp"
require "yaml"
require "twitter"
require 'sqlite3'
require 'logger'

# Setting Logger
log = Logger.new(STDOUT)
log.level = Logger::INFO

# DB
db = SQLite3::Database.new("data.db")
sql = <<SQL
CREATE TABLE IF NOT EXISTS apsave (
  key   VARCHAR(32),
  value VARCHAR(32)
);
SQL
db.execute(sql)

# 最新データ取得
result = db.get_first_row("SELECT value FROM apsave WHERE key = 'latest_steps'")
if result == nil
  p "First time: init database"
  db.execute("INSERT INTO apsave(key, value) VALUES ('latest_steps', '1')")
  result = db.get_first_row("SELECT value FROM apsave WHERE key = 'latest_steps'")
end
latest_steps = result[0].to_i

# Load the existing yml config
config = begin
  Fitgem::Client.symbolize_keys(YAML.load(File.open(".fitgem.yml")))
rescue ArgumentError => e
  puts "Could not parse YAML: #{e.message}"
  exit
end

# Twitter
Twitter.configure do |tw_config|
  tw_config.consumer_key = config[:twitter][:consumer_key]
  tw_config.consumer_secret = config[:twitter][:consumer_secret]
  tw_config.oauth_token = config[:twitter][:token]
  tw_config.oauth_token_secret = config[:twitter][:secret]
end

client = Fitgem::Client.new(config[:oauth])

# With the token and secret, we will try to use them
# to reconstitute a usable Fitgem::Client
if config[:oauth][:token] && config[:oauth][:secret]
  begin
    access_token = client.reconnect(config[:oauth][:token], config[:oauth][:secret])
  rescue Exception => e
    puts "Error: Could not reconnect Fitgem::Client due to invalid keys in .fitgem.yml"
    exit
  end
# Without the secret and token, initialize the Fitgem::Client
# and send the user to login and get a verifier token
else
  request_token = client.request_token
  token = request_token.token
  secret = request_token.secret

  puts "Go to http://www.fitbit.com/oauth/authorize?oauth_token=#{token} and then enter the verifier code below"
  verifier = gets.chomp

  begin
    access_token = client.authorize(token, secret, { :oauth_verifier => verifier })
  rescue Exception => e
    puts "Error: Could not authorize Fitgem::Client with supplied oauth verifier"
    exit
  end

  puts 'Verifier is: '+verifier
  puts "Token is:    "+access_token.token
  puts "Secret is:   "+access_token.secret

  user_id = client.user_info['user']['encodedId']
  puts "Current User is: "+user_id

  config[:oauth].merge!(:token => access_token.token, :secret => access_token.secret, :user_id => user_id)

  # Write the whole oauth token set back to the config file
  File.open(".fitgem.yml", "w") {|f| f.write(config.to_yaml) }
end

# ============================================================
# Add Fitgem API calls on the client object below this line


# 1000 歩ごとにツイートする
activities = client.activities_on_date 'today'
new_steps = activities["summary"]["steps"].to_i

## もし 歩数が前回よりも少なくなっていたら日が変わったとかんがえる
if new_steps < latest_steps then
  latest_steps = 1
end

## 1000歩ごとにツイート
base_steps = ((latest_steps / 1000) + 1) * 1000 
if  new_steps > base_steps then
  log.info "NEW " + ((new_steps / 1000) * 1000).to_s + " steps walked"
  # Twitter.update(round(latest_steps).to_s + "歩 あるきました #fitbitpasso")
end

## 最新歩数を保存
db.execute("UPDATE apsave SET value = ? WHERE key = 'latest_steps'", new_steps)
log.info new_steps.to_s + " steps walked"

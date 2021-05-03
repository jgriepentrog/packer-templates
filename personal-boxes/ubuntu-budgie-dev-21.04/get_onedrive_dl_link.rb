require 'net/http'
require 'json'
require 'base64'

sharing_link = ARGV[0]
password = ARGV[1]

$base_shares_api_url = "https://api.onedrive.com/v1.0/shares"
app_id = "5cbed6ac-a083-4e14-b191-b4ba07653de2"

def get_encoded_sharing_link(sharing_link)
  urlsafe_encoded_link = Base64.urlsafe_encode64(sharing_link).sub("=","")
  return "u!#{urlsafe_encoded_link}"
end

def get_driveitem(encoded_sharing_link, badger_token)
  header = nil

  if !badger_token.nil?
    header = {"Authorization" => "Badger #{badger_token}"}
  end

  uri = URI("#{$base_shares_api_url}/#{encoded_sharing_link}/driveitem")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  response = http.get(uri.request_uri, header)

  return JSON.parse(response.body)
end

def get_badgertoken(app_id)
  badger_endpoint_url = "https://badgerprod.cloudapp.net/v1.0/token"
  body = {:appId => app_id}.to_json
  response = Net::HTTP.post(URI(badger_endpoint_url), body, {"Content-Type" => "application/json"})
  return JSON.parse(response.body)["token"]
end

def get_driveitem_authorization(encoded_sharing_link, challenge_token, item_password, badger_token)
  authorization_url = "#{$base_shares_api_url}/#{encoded_sharing_link}/root/action.validatePermission"
  body = {:challengeToken => challenge_token, :password => item_password}.to_json
  response = Net::HTTP.post(URI(authorization_url), body, {"Content-Type" => "application/json", "Authorization" => "Badger #{badger_token}"})

  if response.code != "200"
    raise "Getting DriveItem authorization failed with error code #{response.code}. Details: #{response.body}"
  end
end

encoded_sharing_link = get_encoded_sharing_link(sharing_link)
drive_item_response = get_driveitem(encoded_sharing_link, nil)
download_url = drive_item_response.fetch("@content.downloadUrl", nil)
name = drive_item_response.fetch("name", nil)

if download_url.nil? then
  challenge_url_query = URI(drive_item_response["error"]["fixItUrl"]).query
  challenge_token = Hash[URI.decode_www_form(challenge_url_query)]["challengeToken"]
  
  badger_token = get_badgertoken(app_id)
  get_driveitem_authorization(encoded_sharing_link, challenge_token, password, badger_token)

  drive_item_response = get_driveitem(encoded_sharing_link, badger_token)
  download_url = drive_item_response.fetch("@content.downloadUrl", nil)
  name = drive_item_response.fetch("name", nil)
end

puts "#{name}\t#{download_url}"

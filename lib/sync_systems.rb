puts "Systems sync"
url = URI.parse(ENV.fetch("SYSTEMS_API_URL"))
req = Net::HTTP::Get.new(url.to_s)
req['X-Api-Key'] = ENV.fetch("SYSTEMS_API_TOKEN")
req['X-Zero-Trust-Token'] = ENV.fetch("ZTA_TOKEN")
res = Net::HTTP.start(url.host, url.port, :use_ssl => true) {|http|
  http.request(req)
}
body = JSON.parse(res.body)
all_systems = System.all
active_systems = []
body.each do |system|
  obj = System.find_or_initialize_by(id: system["id"])
  obj.assign_attributes(
    name: system["name"]
  )
  obj.save
  active_systems << system["id"]
end

all_systems.each do |system|
  system.destroy unless active_systems.include?(system.id)
end
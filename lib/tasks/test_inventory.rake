namespace :test_inventory do
  desc 'Test inventory'
  task update: :environment do
    ### Scipt to test inventory integration. Set SERIAL and see if it prints username in result. Feel free to edit if required
    SERIAL = '13660106'
    INVENTORY_HOSTNAME = ENV['INVENTORY_HOSTNAME']
    INVENTORY_TOKEN = ENV['INVENTORY_TOKEN']
    filter = %Q|[{"operator": "eq", "value": "Yubico", "property": "vendor"}, {"operator": "eq", "value": "#{SERIAL}", "property": "serial"}]|
    filter = filter.to_query("filter")
    url = URI.parse("https://#{INVENTORY_HOSTNAME}/ajax/data.php?o=r&c=Equipment&start=0&limit=1&#{filter}")
    p url
    req = Net::HTTP::Get.new(url)
    req['Authorization'] = "Bearer #{INVENTORY_TOKEN}"
    res = Net::HTTP.start(url.host, url.port, :use_ssl => true) {|http|
        http.request(req)
    }
    body = JSON.parse(res.body)
    username = body["data"].first["user"]["login"]
    p username

    # if body["data"].first["state"] == "1" || body["data"].first["state"] == "2" # 1 = reserved, 2 = issued
    #   return username
    # end

  end
end
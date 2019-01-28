title 'Endpoint Checks'

kong_url = ENV['KONG_URL']

control 'endpoint-01' do
  title 'Kong'

  describe http(kong_url) do
    its('headers.Server') { should start_with 'kong/' }
  end
end

control 'endpoint-02' do
  title 'Kong Admin API'

  describe http("#{kong_url}/admin-api") do
    its('status') { should cmp 200 }
    its('body') { should include 'nginx_kong_conf' }
    its('headers.Server') { should start_with 'kong/' }
  end
end

control 'endpoint-03' do
  title 'Hello World'

  describe http("#{kong_url}/hello") do
    its('status') { should cmp 200 }
    its('body') { should include 'Hello World' }
  end
end

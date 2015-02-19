include_recipe 'deploy'

node[:deploy].each do |application, deploy|
    
  bash "docker-run" do
    user "root"
    code <<-EOH
      docker run -d \
      -p 9292:9292 \
      -p 9200:9200 \
      pblittle/docker-logstash
    EOH
  end

end
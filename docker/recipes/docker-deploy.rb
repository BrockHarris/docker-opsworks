include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  
  if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
    Chef::Log.debug("Skipping deploy::docker application #{application} as it is not deployed to this layer")
    next
  end

  bash "docker-cleanup" do
    user "root"
    code <<-EOH
      if docker ps -a 
      then
        docker stop $(docker ps -a -q)
        sleep 3
        docker rm $(docker ps -a -q)
        sleep 3
      fi
    EOH
  end

  bash "docker-run" do
    user "root"
    code <<-EOH
      docker run -d -e LOGSTASH_CONFIG_URL=#{deploy[:environment_variables][:logstash_conf_path]} -p 5228:5228/udp -p 5000:5000/udp -p 9292:9292 -p 9200:9200 -v /opt/logstash_backup:/opt/logstash_backup_mnt pblittle/docker-logstash
    EOH
  end
end
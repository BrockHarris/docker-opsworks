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
        sleep 10
        docker rm $(docker ps -a -q)
        sleep 3
      fi
    EOH
  end

  bash "docker-run" do
    user "root"
    code <<-EOH
      docker run -d --name elasticsearch helder/elasticsearch
      docker run -d --link elasticsearch:elasticsearch -p 80:80 --name kibana helder/kibana

      docker exec kibana htpasswd -b /etc/nginx/.htpasswd #{deploy[:environment_variables][:auth_username]} #{deploy[:environment_variables][:auth_passwd]}
      docker exec kibana htpasswd -D /etc/nginx/.htpasswd kibana

      wget -O /opt/logstash_config/logstash.conf #{deploy[:environment_variables][:logstash_conf_url]}

      docker run -d -v /opt/logstash_backup:/opt/logstash_backup_mnt -v /opt/logstash_config/logstash.conf:/etc/logstash.conf -p 5228:5228/udp -p 5000:5000/udp --link elasticsearch:es --name logstash helder/logstash  \
      bin/logstash -f /etc/logstash.conf
    EOH
  end
end
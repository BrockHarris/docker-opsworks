include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  
  if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
    Chef::Log.debug("Skipping deploy::docker application #{application} as it is not deployed to this layer")
    next
  end



  bash "docker-cleanup" do
    user "root"
    code <<-EOH
      if docker ps | grep #{deploy[:application]}; 
      then
        docker stop #{deploy[:application]}
        sleep 3
        docker rm #{deploy[:application]}
        sleep 3
      fi
      if docker images | grep #{deploy[:application]}; 
      then
        docker rmi #{deploy[:application]}
      fi
    EOH
  end


  
  bash "docker-run" do
    user "root"
    #cwd "#{deploy[:deploy_to]}/current"

    #docker run -p 9292:9292 -p 9200:9200 -d pblittle/docker-logstash
    code <<-EOH
      docker run -p 9292:9292 -p 9200:9200 -d pblittle/docker-logstash
    EOH

    #docker run #{dockerenvs} -p #{node[:opsworks][:instance][:private_ip]}:#{deploy[:environment_variables][:service_port]}:#{deploy[:environment_variables][:container_port]} --name #{deploy[:application]} -d 
    #docker run -p 10.183.61.222:80:80 -p 10.183.61.222:443:443 -d mydocker
  end

end
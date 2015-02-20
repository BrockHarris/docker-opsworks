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
    #cwd "#{deploy[:deploy_to]}/current"

    code <<-EOH
      docker run -d -p 9292:9292 -p 9200:9200 #{deploy[:application]}
    EOH

    #docker run #{dockerenvs} -p #{node[:opsworks][:instance][:private_ip]}:#{deploy[:environment_variables][:service_port]}:#{deploy[:environment_variables][:container_port]} --name #{deploy[:application]} -d 
  end

end
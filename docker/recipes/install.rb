case node[:platform]
when "ubuntu","debian"
  bash "docker-install" do
    user "root"
    code <<-EOH
      sudo apt-get update
      sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9

      sudo sh -c "echo deb https://get.docker.com/ubuntu docker main\
      /etc/apt/sources.list.d/docker.list"      
      sudo apt-get install lxc-docker
    EOH
  end
when 'centos','redhat','fedora','amazon'
  package "docker" do
    action :install
  end
end

directory "/opt/logstash_backup" do
  mode 0755
  owner 'root'
  group 'root'
  action :create
end

directory "/opt/logstash_config" do
  mode 0755
  owner 'root'
  group 'root'
  action :create
end

service "docker" do
  action :start
end
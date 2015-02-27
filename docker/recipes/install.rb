case node[:platform]
when "ubuntu","debian"
  package "docker.io" do
    action :install
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

service "docker" do
  action :start
end
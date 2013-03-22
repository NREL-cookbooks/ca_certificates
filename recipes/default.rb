#
# Cookbook Name:: ca_certificates
# Recipe:: default
#
# Copyright 2013, NREL
#
# All rights reserved - Do Not Redistribute
#

certs = []
begin
  certs = data_bag("ca_certificates").map do |item|
    data_bag_item("ca_certificates", item)
  end
rescue
  Chef::Log.info "Could not load data bag 'ca_certificates'"
end

template "/etc/ssl/certs/ca-bundle.crt" do
  source "ca-bundle.crt.erb" 
  variables :certs => certs
end

# Fix for the OmniBus chef installs not picking up on the certs:
# http://tickets.opscode.com/browse/CHEF-2840
link "/opt/chef/embedded/ssl/cert.pem" do
  to "/etc/ssl/certs/ca-bundle.crt"
end

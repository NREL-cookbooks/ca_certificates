#
# Cookbook Name:: ca_certificates
# Recipe:: default
#
# Copyright 2013, NREL
#
# All rights reserved - Do Not Redistribute
#

certs = []

# Read custom certs out of the data bag.
begin
  certs = data_bag("ca_certificates").map do |item|
    data_bag_item("ca_certificates", item)
  end
rescue
  Chef::Log.info "Could not load data bag 'ca_certificates'"
end

# Also read custom certs out of the attributes.
certs += node[:ca_certificates][:certs]

# Remove duplicate certs.
certs.uniq! { |cert| cert['pem'] }

template "/etc/ssl/certs/ca-bundle.crt" do
  source "ca-bundle.crt.erb" 
  variables :certs => certs
end

# Fix for the OmniBus chef installs not picking up on the certs:
# http://tickets.opscode.com/browse/CHEF-2840
link "/opt/chef/embedded/ssl/cert.pem" do
  to "/etc/ssl/certs/ca-bundle.crt"
end

# Setup environment variables to force certain applications to use the system
# CA bundle. 
template "/etc/profile.d/ca_certificates.sh" do
  source  "profile.sh.erb"
  owner   "root"
  mode    "0644"
end

# Make sure anything set in profile.d is set on the current environment, so
# Chef won't fail on first run.
ENV["PIP_CERT"] = "/etc/ssl/certs/ca-bundle.crt"

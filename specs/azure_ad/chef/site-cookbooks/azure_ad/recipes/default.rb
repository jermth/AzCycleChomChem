#
# Cookbook Name:: azure_ad
# Recipe:: default.rb
#
# Copyright 2013, Cycle Computing, LLC
#
# All rights reserved - Do Not Redistribute
#


if node["azure_ad"]["domain"]["domain_name"].nil? || node["azure_ad"]["domain"]["service_user"].nil? || node["azure_ad"]["domain"]["service_user_password"].nil? 
  Chef::Log.error("Azure AD domain settings (domain-name, service-user or password not defined")
  raise
end

domain_name = node["azure_ad"]["domain"]["domain_name"].upcase
service_user = node["azure_ad"]["domain"]["service_user"]
service_user_password = node["azure_ad"]["domain"]["service_user_password"] 

chefstate = node[:cyclecloud][:chefstate]

# package requirements
%w(realmd sssd krb5-workstation krb5-libs oddjob oddjob-mkhomedir adcli samba-common-tools).each { |p| package p }

# fetch the keytab used for kinit
# Commenting this out till we have the Kerberos keytab  
# remote_file "#{chefstate}/kerberos.keytab" do
#   source kerberos_keytab_url
#   owner 'root'
#   mode '0600'
#   action :create_if_missing  
# end

execute "Realm discover" do
  command  "realm discover #{domain_name} && touch #{chefstate}/realm.discovered"
  creates "#{chefstate}/realm.discovered"
end

# Commenting this out till we have the Kerberos keytab 
# execute "Kinit" do 
#   command "kinit #{service_user}@#{domain_name} -k -t #{chefstate}/kerberos.keytab && touch #{chefstate}/kinit.complete"
#   creates "#{chefstate}/kinit.complete"
# end

execute "Kinit" do
  command "echo '#{service_user_password}' | kinit #{service_user}@#{domain_name} && touch #{chefstate}/kinit.complete"
  creates "#{chefstate}/kinit.complete"
end

execute "Realm join" do
  command "realm join --verbose #{domain_name} --no-password && touch #{chefstate}/realm.joined"
  creates "#{chefstate}/realm.joined"
end

fallback_homedir = "/home/\%u"
if node.recipe?('cshared::server') || node.recipe?('cshared::client')
  fallback_homedir = "/shared/home/\%u"
end

ruby_block "Update sssd.conf for homedir and username" do
  block do
    file = Chef::Util::FileEdit.new("/etc/sssd/sssd.conf")
    file.search_file_replace_line(/^fallback_homedir/, "fallback_homedir = #{fallback_homedir}")
    file.search_file_replace_line(/^use_fully_qualified_names/, "use_fully_qualified_names = False")
    file.write_file
  end
  not_if "grep -q 'use_fully_qualified_names = False' /etc/sssd/sssd.conf"
  notifies :restart, 'service[sssd]', :immediately 
end

service "sssd" do
  action :nothing
end

include_recipe "::generate_sshkey"


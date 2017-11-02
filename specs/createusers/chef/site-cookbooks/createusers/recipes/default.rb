#
# Cookbook Name:: createusers
# Recipe:: default.rb
#
# Copyright 2013, Cycle Computing, LLC
#
# All rights reserved - Do Not Redistribute
#
require 'net/http'
include_recipe "cuser::default"

gem_package "ruby-shadow" do
  action :install
  ignore_failure false
end

group "users" do
  gid node[:createusers][:users][:gid]
end

group "admins" do
  gid node[:createusers][:admins][:gid]
end

directory "#{node[:createusers][:base_home_dir]}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  only_if "test -d /shared"
end

# Note: There is different behavior on chef-server and chef-solo with regard to data bags
# If the databag is NOT found on the file-system in chef-solo an empty list is returned by the data_bag call
# If the databag is NOT found on the chef-server, an 404 exception is thrown. For compatibility we catch this exception
# and return an empty list.
begin
  users = data_bag('users')
rescue Net::HTTPServerException
  Chef::Log.warn "'users' databag not found... defaulting to [] for chef-solo compatibility!"
  users = []
end

begin
  admins = data_bag('admins')
rescue Net::HTTPServerException
  Chef::Log.warn "'admins' databag not found... defaulting to [] for chef-solo compatibility!"
  admins = []
end

cookbook_file "/etc/sudoers.d/admins" do
  source "admins"
  owner "root"
  group "root"
  mode "0400"
  action :create
end

admins.each do |login|
  admin = data_bag_item('admins', login)
  home = "#{node[:createusers][:base_home_dir]}/#{login}"

  user(login) do
    uid admin['uid']
    gid "admins"
    shell admin['shell']
    comment admin['comment']
    home home
    supports :manage_home => true
    only_if "test -d #{node[:createusers][:base_home_dir]}"
  end
  directory "#{home}/.ssh" do
    owner login
    group "admins"
    mode "0700"
    action :create
    only_if "test -d #{home}"
  end

  template "#{home}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    mode "0600"
    owner login
    group "admins"
    variables(:pubkey => admin['sshpubkey'])
    only_if "test -d #{home}/.ssh"
    not_if "test -e #{home}/.ssh/authorized_keys"
  end

  execute "generate ssh keys for #{login}." do
    user login
    creates "#{home}/.ssh/id_rsa.pub"
    command "ssh-keygen -t rsa -q -f #{home}/.ssh/id_rsa -P \"\" && cat #{home}/.ssh/id_rsa.pub >> #{home}/.ssh/authorized_keys"
  end

  execute "add user to admins group" do
    command "usermod -a -G admins #{login}"
  end

end


users.each do |login|
  loginUser = data_bag_item('users', login)
  home = "#{node[:createusers][:base_home_dir]}/#{login}"

  user(login) do
    uid loginUser['uid']
    gid "users"
    shell loginUser['shell']
    comment loginUser['comment']
    password loginUser['password']
    home home
    supports :manage_home => true
    only_if "test -d #{node[:createusers][:base_home_dir]}"
  end
  directory "#{home}/.ssh" do
    owner login
    group "users"
    mode "0700"
    action :create
    only_if "test -d #{home}"
  end
  execute "generate ssh keys for #{login}." do
    user login
    creates "#{home}/.ssh/id_rsa.pub"
    command "ssh-keygen -t rsa -q -f #{home}/.ssh/id_rsa -P \"\""
  end
  execute "generate authorized_keys for #{login}." do
    user login
    creates "#{home}/.ssh/authorized_keys"
    command "cp #{home}/.ssh/id_rsa.pub #{home}/.ssh/authorized_keys"
    not_if "test -e #{home}/.ssh/authorized_keys"
  end
  
  execute "Force password reset" do
    command "chage -d 0 #{login} && touch #{home}/.ssh/.password_set"
    not_if "test -e #{home}/.ssh/.password_set"
  end

end

strict_host_stanza = "\nHost *\n  StrictHostKeyChecking no"
ruby_block 'turn off strict host key checking' do
  block do
    file = ::File.open("/etc/ssh/ssh_config", 'a')
    file.write(strict_host_stanza)
    file.close
  end
  not_if do
    ::File.read('/etc/ssh/ssh_config').include?(strict_host_stanza)
  end 
end


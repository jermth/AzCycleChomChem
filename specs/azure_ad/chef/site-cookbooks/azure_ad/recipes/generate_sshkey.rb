cookbook_file "/etc/profile.d/generate_sshkey.sh" do
  source "generate_sshkey.sh"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

cookbook_file "/etc/profile.d/generate_sshkey.csh" do
  source "generate_sshkey.csh"
  owner "root"
  group "root"
  mode "0755"
  action :create
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



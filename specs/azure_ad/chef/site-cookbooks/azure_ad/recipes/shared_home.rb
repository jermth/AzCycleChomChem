if node.recipe?('cshared::server') || node.recipe?('cshared::client')
  bash "Move CycleCloud user home dir" do
    code <<-EOH
    pkill -u cyclecloud && usermod -m -d /opt/cycle/cyclecloud cyclecloud
    EOH
    not_if '$(getent passwd cyclecloud | cut -d: -f6) == "/opt/cycle/cyclecloud"'
  end

  # bash "link home to shared" do
  #   code <<-EOH
  #   mv /home /home.local
  #   ln -s /shared/home /home
  #   EOH
  #   not_if "test -h /home"
  # end
end


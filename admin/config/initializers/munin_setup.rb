require 'rbconfig'

host_os = RbConfig::CONFIG['host_os']

case host_os 
when /openbsd/
  MUNIN_GRAPH_DIRECTORY = "/var/www/htdocs/munin/localhost/localhost"
when /linux-gnu/
  MUNIN_GRAPH_DIRECTORY = "/var/www/munin/localdomain/localhost.localdomain"
else 
  raise StandardError, "Not supported on this OS"
end

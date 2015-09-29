# run with:  god -c /etc/god/sqlgrey.god
#

God.watch do |w|
  w.name = "sqlgrey"
  w.interval = 30.seconds # default
  w.start = "/usr/sbin/rcctl start sqlgrey"
  w.stop = "/usr/sbin/rcctl stop sqlgrey"
  w.restart = "/usr/sbin/rcctl restart sqlgrey"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/var/run/sqlgrey.pid"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end

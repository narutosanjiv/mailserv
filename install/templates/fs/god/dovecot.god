# run with:  god -c /etc/god/dovecot.god
#

God.watch do |w|
  w.name = "dovecot"
  w.group = "mailserv"
  w.interval = 30.seconds # default
  w.start = "/usr/sbin/rcctl start dovecot"
  w.stop = "/usr/sbin/rcctl stop dovecot"
  w.restart = "/usr/sbin/rcctl restart dovecot"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/var/dovecot/master.pid"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end

end

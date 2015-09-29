God.watch do |w|
  w.name = "clamav-milter"
  w.interval = 30.seconds # default
  w.start = "/usr/sbin/rcctl start clamav-milter"
  w.stop = "/usr/sbin/rcctl stop clamav-milter"
  w.restart = "/usr/sbin/rcctl restart clamav-milter"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/var/run/clamav-milter.pid"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end

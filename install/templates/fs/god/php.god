God.watch do |w|
  w.name = "php"
  w.interval = 30.seconds 
  w.pid_file = "/var/run/php-fpm.pid"
  w.start = "/usr/sbin/rcctl start php_fpm"
  w.stop = "/usr/sbin/rcctl stop php_fpm"
  w.restart = "/usr/sbin/rcctl restart php_fpm"
  w.start_grace = 20.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/var/run/php-fpm.pid" 

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end

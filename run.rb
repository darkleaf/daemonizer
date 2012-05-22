load 'classes.rb'

s = Supervisor.new
s.daemons << Daemon.new
s.daemons << Daemon.new
s.daemons << Daemon.new

s.run

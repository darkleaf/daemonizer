load 'classes.rb'

s = Supervisor.new
s.daemons << Daemon.new(:name => 'First')
s.daemons << Daemon.new(:name => 'Second')
s.daemons << Daemon.new(:name => 'Kamikadze')

s.run

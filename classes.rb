class BaseDaemon
  attr_accessor :pid, :options

  def initialize(options = {})
    @options = options   
  end
  
  def started?
    return false unless @pid

    Process.getpgid @pid
    true
  rescue Errno::ESRCH
    false
  end

  def action
    raise 'Not Implemented'
  end

  def perform
    while true do
      action
    end
  end
  
  def run
    return if started?
    @started = true
    @pid = fork do
      @pid = Process.pid

      STDOUT.reopen File.open("#{@pid}.stout", 'a')
      STDERR.reopen File.open("#{@pid}.stderr", 'a')

      perform
    end
    puts "#{@pid} start"
    Process.detach(@pid)
  end

  def stop
    return unless started?
    @started = false
    Process.kill 'QUIT', pid
  end
end

class Supervisor < BaseDaemon
  attr_accessor :daemons
  LOG_FILE = "supervisor.log"

  def initialize(options = {})
    super options
    @daemons = []
  end

  def action
    @daemons.each do |daemon|
      unless daemon.started?
        old_pid = daemon.pid
        File.open LOG_FILE, 'a' do |f|
          daemon.run
          f.write "damon name: #{daemon.options[:name] || 'Dmn'}\n"
          f.write "daemon died! pid: #{old_pid}\n"
          f.write "daemon started! pid: #{daemon.pid}\n\n"
        end
      end
    end
    sleep 2
  end
end


class Daemon < BaseDaemon
  def action
    exit! 1 if rand(5) == 0
    sleep 3
  end
end

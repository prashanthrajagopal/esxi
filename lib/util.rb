require 'net/ssh'

class Util

  def self.start_ssh_session config
    session = nil
    params = {:username => config['user'], 
              :password => config['password'], 
              :port => config['port']
            }
    retryable(:tries => config['retries'] || 10) do
      Timeout::timeout(config['timeout'] || 10 ) do
        session = Net::SSH.start(config['host'], params)
      end
    end
    session
  end

  def self.close_ssh_session session
    session.close
  end

  def self.run session, cmd
    result = "NA"
    begin
      Timeout::timeout(30) do
        Logger.info("Running #{cmd}", @terminal)
        result = session.exec!(cmd)
      end
    rescue SocketError => e
      connection_failed = true
      Logger.color("SOCKET ERROR: #{e.message} at def _run()", RED, @terminal)
    rescue Net::SSH::AuthenticationFailed
      connection_failed = true
      Logger.color("AUTH ERROR: #{e.message} at def _run()", RED, @terminal)
    rescue Exception => e
      Logger.color("EXCEPTION: #{e.message} at def _run()", RED, @terminal)
      Logger.color("#{e.backtrace}", RED, @terminal)
    end
    Logger.info("ssh command result \n#{result}", @terminal)
    result
  end

  def self.retryable options = {}
    opts = { :tries => 1, :on => Exception }.merge(options)
    retry_exception, retries = opts[:on], opts[:tries]
    begin
      return yield
    rescue retry_exception
      if (retries -= 1) > 0
        Logger.color("Retrying", RED)
        sleep 2
        retry 
      else
        raise
      end
    end
  end  
end

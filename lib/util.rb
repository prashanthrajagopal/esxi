require 'net/ssh'

class Util

  def self.start_ssh_session config
    session = nil
    host = config[:host]
    user = config[:user]
    params = {
              :password => config[:password], 
              :port => config[:port]
            }
    retryable(:tries => config[:retries] || 10) do
      Timeout::timeout(config[:timeout] || 10 ) do
        session = Net::SSH.start(host, user, params)
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
        result = session.exec!(cmd)
      end
    rescue Exception => e
      raise e.message
    end
    result
  end

  def self.retryable options = {}
    opts = { :tries => 1, :on => Exception }.merge(options)
    retry_exception, retries = opts[:on], opts[:tries]
    begin
      return yield
    rescue retry_exception
      if (retries -= 1) > 0
        sleep 2
        retry 
      else
        raise
      end
    end
  end  
end

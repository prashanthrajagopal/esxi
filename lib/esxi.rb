require "esxi/version"
require "util"

class VM
  def initialize config
    unless config['host'] then raise ArgumentError, "Must provide a hostname" end
    unless config['user'] then raise ArgumentError, "Must provide a username" end
    
    @host = config["host"]
    @user = config["user"]
    @password = config["password"] if config["password"]
    @port = config["port"] ? config["port"] : 22

    @session = Util.start_ssh_session({:host => @host, :port => @port, :user => @user, :password => @password, :retries => 5, :timeout => 75})
  end

  def start vmid
    Util.run(@session, "vim-cmd vmsvc/power.on #{vmid}")
  end

  def stop vmid
    Util.run(@session, "vim-cmd vmsvc/power.off #{vmid}")
  end

  def suspend vmid
    Util.run(@session, "vim-cmd vmsvc/power.suspend #{vmid}")
  end

  def pause vmid
    Util.run(@session, "vim-cmd vmsvc/power.suspend #{vmid}")
  end

  def resume vmid
    Util.run(@session, "vim-cmd vmsvc/power.suspendResume #{vmid}")
  end

  def reset vmid
    Util.run(@session, "vim-cmd vmsvc/power.reset #{vmid}")
  end

  def create_snapshot vmid, name, description
    description ||= "Snapshot created by https://github.com/prashanthrajagopal/esxi"
    Util.run(@session, "nohup vim-cmd vmsvc/snapshot.create #{vmid} #{name} #{description} 1 0 > nohup.log < /dev/null &")
  end

  def revert_snapshot vmid, snapshot_name
    snapshots = get_snapshots(vmid)
    snapshots.each do |snap|
      #puts "DEBUG: checking #{snapshot}"
      if snap["name"].downcase == snapshot_name.strip.downcase
        snap_id = snap["id"]
        #puts "DEBUG: I would revert to #{snapshot}"
        Util.run(@session, "nohup vim-cmd vmsvc/snapshot.revert #{vmid} #{snap_id} 0 > nohup.log < /dev/null &")
        return true
      end
    end
    raise "Snapshot not found"
  end

  def delete_snapshot vmid, snapshot
    snapshots = get_snapshots(vmid)
    snapshots.each do |snap|
      #puts "DEBUG: checking #{snapshot}"
      if snap["name"].downcase == snapshot_name.strip.downcase
        snap_id = snap["id"]
        #puts "DEBUG: I would remove #{snapshot}"
        Util.run(@session, "nohup vim-cmd vmsvc/snapshot.remove #{vmid} #{snap_id} > nohup.log < /dev/null &")
        return true
      end
    end
    raise "Invalid Snapshot Name"
  end

  def get_snapshots vmid
    snapshots = Util.run(@session, "vim-cmd vmsvc/snapshot.get #{vmid}").split('|')
    snapshots.shift
    snapshot_list = []
    snapshots.each do |snapshot|
      info = {}
      snap = snapshot.gsub('--','').split("\n")
      snap.shift
      snap.each do |x| 
        info[x.split(':')[0].strip.downcase.gsub("snapshot ", '')] = x.split(':')[1].strip
      end
      snapshot_list << info unless info == {}
    end
    snapshot_list
  end

  def delete_all_snapshots vmid
    Util.run(@session, "nohup vim-cmd vmsvc/snapshot.removeall #{vmid} > nohup.log < /dev/null &")
  end

  def running? vmid
    if Util.run(@session, "vim-cmd vmsvc/power.getstate #{vmid}").match /Powered on/
      return true
    else
      return false
    end
  end 

  def shutdown
    puts "Use With Caution. This will shutdown your ESXI." 
    puts "You have 5 seconds to abort"
    sleep 5
    Util.run(@session, "for id in `vim-cmd vmsvc/getallvms | grep -v Vmid |awk '{print (}'`; do vim-cmd /vmsvc/power.off $id ; done")
    Util.run(@session, "vim-cmd hostsvc/maintenance_mode_enter")
    Util.run(@session, 'esxcli system shutdown poweroff -d 10 -r "Shell initiated system shutdown"')
  end

  def run_command command
    Util.run(@session, command)
  end
end

require "esxi/version"
require "util"

module Esxi
  def initializer config
    unless config['host'] then raise ArgumentError, "Must provide a hostname" end
    unless config['user'] then raise ArgumentError, "Must provide a username" end
    
    @host = config['host']
    @user = config['user']
    @password = config['password'] if config['password']
    @port = config['port'] ? config['port'] : 22

    @session = Util.start_ssh_session({:host => @host, :port => @port, :user => @user, :password => password, :retries => 5, :timeout => 15})
  end

  def start vmid
    unless @vmid then raise ArgumentError, "I need a VMID." end
    Util.run(@session, "vim-cmd vmsvc/power.on #{vmid}")
  end

  def stop vmid
    unless vmid then raise ArgumentError, "I need a VMID." end
    Util.run(@session, "vim-cmd vmsvc/power.off #{vmid}")
  end

  def suspend vmid
    unless vmid then raise ArgumentError, "I need a VMID." end
    Util.run(@session, "vim-cmd vmsvc/power.suspend #{vmid}")
  end

  def pause vmid
    unless vmid then raise ArgumentError, "I need a VMID." end
    Util.run(@session, "vim-cmd vmsvc/power.suspend #{vmid}")
  end

  def resume vmid
    unless vmid then raise ArgumentError, "I need a VMID." end
    Util.run(@session, "vim-cmd vmsvc/power.suspendResume #{vmid}")
  end

  def reset vmid
    unless vmid then raise ArgumentError, "I need a VMID." end
    Util.run(@session, "vim-cmd vmsvc/power.reset #{vmid}")
  end

  def create_snapshot vmid, name, description
    unless vmid then raise ArgumentError, "I need a VMID." end
    description ||= "Snapshot created by https://github.com/prashanthrajagopal/esxi"
    Util.run(@session, "vim-cmd vmsvc/snapshot.create #{vmid} #{name} #{description} 1 0")
  end

  def revert_snapshot vmid, snapshot_name
    snapshots = get_snapshots(vmid)
    snapshots.each do |snap|
      #puts "DEBUG: checking #{snapshot}"
      if snap["name"].downcase == snapshot_name.strip.downcase
        snap_id = snap["id"]
        #puts "DEBUG: I would revert to #{snapshot}"
        Util.run(@session, "vim-cmd vmsvc/snapshot.revert #{vmid} #{snap_id} 0")
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
        Util.run(@session, "vim-cmd vmsvc/snapshot.remove #{vmid} #{snap_id}")
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

  end

  def delete_all_snapshots vmid
    Util.run(@session, "vim-cmd vmsvc/snapshot.removeall #{vmid}")
  end

  def running?
    if Util.run(@session, "vim-cmd vmsvc/power.getstate #{@vmid}").match /Powered on/
      return true
    else
      return false
    end
  end 
end

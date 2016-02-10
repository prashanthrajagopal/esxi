require 'base_unit_test'

class VMInfoTest < BaseUnitTest
  include VMInfo
  include TestHelper
  def setup
    @raw_summary = fixture('vm_summary', 'txt')
    @raw_guest_info = fixture('guest_info', 'txt')
  end

  def test_parsing_errors
    error = """(vim.fault.NotFound) {
      faultCause = (vmodl.MethodFault) null, 
      msg = \"Unable to find a VM corresponding to \"5\"\"
    }"""
    vm_summary = vm_info_to_hash(error)
    expected_response = { "faultCause" => nil, "msg" => "Unable to find a VM corresponding to '5'" }
    assert_equal expected_response, vm_summary
  end

  def test_hash_vm_info
    vm_summary = vm_info_to_hash(@raw_summary)

    # make sure single quotes are correctly converted to double quotes
    assert_equal("vim.VirtualMachine:2", vm_summary["vm"])

    # make sure arrays are converted properly
    assert_equal(27, vm_summary["runtime"]["featureRequirement"].length)

    # make sure false doesn't become "false" for example and integers and
    # strings are still parsed correctly as well
    assert_equal(false, vm_summary["runtime"]["paused"])
    assert_equal("poweredOn", vm_summary["runtime"]["powerState"])
    assert_equal(4589, vm_summary["runtime"]["maxCpuUsage"])

    # make sure <unset> becomes null
    assert_nil vm_summary["runtime"]["memoryOverhead"]

    # the guest info output should be supported as well
    guest_info = vm_info_to_hash(@raw_guest_info)

    # make sure IPv6 addresses are parsed correctly
    assert_equal("f27e::2fc:49fe:fd9f:9300", guest_info["net"][0]["ipAddress"][1])

    # make sure that mac addresses work as well
    assert_equal("00:1c:06:e3:93:22", guest_info["net"][0]["macAddress"])
  end
end

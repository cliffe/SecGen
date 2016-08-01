Facter.add(:vmid) do
  setcode do
    # Original Command: echo $(sudo dmidecode -t 4 | grep ID | sed 's/.*ID://;s/ //g') $(sudo ifconfig | grep eth1 | awk '{print $NF}' | sed 's/://g')
    Facter::Core::Execution.exec("echo -n $(dmidecode | grep ID | sed 's/.*ID://;s/ //g' | sed 's/-//g')$(cat /sys/class/net/eth0/address | sed 's/://g') | md5sum | sed 's/ //g' | sed 's/-//g'")
  end
end

def get_mysql_id
  Facter.value(:macaddress).split(':').inject(0) { |total,value| (total << 6) + value.hex }
end

Facter.add("mysql_server_id") do
  setcode do
    get_mysql_id rescue nil
  end
end

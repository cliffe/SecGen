def mysql_id_get
  Facter.value(:macaddress).split(':')[2..-1].reduce(0) { |total, value| (total << 6) + value.hex }
end

Facter.add('mysql_server_id') do
  setcode do
    begin
      mysql_id_get
    rescue
      nil
    end
  end
end

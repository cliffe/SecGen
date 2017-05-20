Facter.add(:phpversion) do
  setcode do
    output = Facter::Util::Resolution.exec('php -v')

    unless output.nil?
      output.split("\n").first.split(' ').
        select { |x| x =~ /^(?:(\d+)\.)(?:(\d+)\.)?(\*|\d+)/ }.first
    end
  end
end

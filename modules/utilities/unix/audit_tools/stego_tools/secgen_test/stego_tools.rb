require_relative '../../../../../lib/post_provision_test'

class StegoToolsTest < PostProvisionTest
  def initialize
    self.module_name = 'stego_tools'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('steghide installed?', 'which steghide', 'steghide')
      test_local_command('exif installed?', 'which exif', 'exif')
      test_local_command('exiftool installed?', 'which exiftool', 'exiftool')
    end
    tier(2) do
      test_command_succeeds('steghide reports version', 'steghide --version')
      test_local_command('exiftool available', 'exiftool -ver', '.')
      # `exif --version` prints only the bare version number (e.g. 0.6.22), not the tool name
      test_command_succeeds('exif reports version', "exif --version 2>&1 | grep -E '^[0-9]+\\.[0-9]+'")
    end
  end
end

StegoToolsTest.new.run

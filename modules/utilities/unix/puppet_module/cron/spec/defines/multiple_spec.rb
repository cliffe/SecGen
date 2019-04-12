require 'spec_helper'

describe 'cron::job::multiple' do
  let(:title) { 'mysql_backup' }

  context 'multiple job with custom and default values' do
    let(:params) do
      {
        environment: ['MAILTO="root"', 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"'],
        jobs: [
          {
            'minute'     => '45',
            'hour'       => '7',
            'date'       => '12',
            'month'      => '7',
            'weekday'    => '*',
            'user'       => 'admin',
            'command'    => 'mysqldump -u root test_db >some_file'
          },
          {
            'command' => '/bin/true'
          }
        ],
        mode: '0640'
      }
    end
    let(:cron_timestamp) { get_timestamp(params) }

    it do
      is_expected.to contain_file("job_#{title}").with(
        'owner'   => 'root',
        'mode'    => params[:mode]
      ).with_content(
        %r{\n#{params[:environment].join('\n')}\n}
      ).with_content(
        %r{\n#{cron_timestamp}\s+}
      ).with_content(
        %r{\s+45 7 12 7 \*  admin  mysqldump -u root test_db >some_file\n}
      ).with_content(
        # /\s+\* \* \* \* \*  root  \/bin\/true\n/
        %r{\* \* \* \* \*  root  /bin/true}
      )
    end
  end

  context 'multiple job with ensure set to absent' do
    let(:params) do
      {
        ensure: 'absent',
        jobs: [
          {
            'command' => '/bin/true'
          }, {
            'command' => '/bin/false'
          }
        ]
      }
    end

    it do
      is_expected.to contain_file("job_#{title}").with('ensure' => 'absent')
    end
  end
end

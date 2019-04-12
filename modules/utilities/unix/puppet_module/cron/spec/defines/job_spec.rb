require 'spec_helper'

describe 'cron::job' do
  let(:title) { 'mysql_backup' }

  context 'job with default values' do
    let(:params) { { command: 'mysqldump -u root test_db >some_file' } }
    let(:cron_timestamp) { get_timestamp(params) }

    it do
      is_expected.to contain_file("job_#{title}").with(
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'path'    => "/etc/cron.d/#{title}"
      ).with_content(
        %r{\n#{cron_timestamp}\s+}
      ).with_content(
        %r{\s+#{params[:command]}\n}
      )
    end
  end

  context 'job with custom values' do
    let(:params) do
      {
        minute: '45',
        hour: '7',
        date: '12',
        month: '7',
        weekday: '*',
        environment: ['MAILTO="root"', 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"'],
        user: 'admin',
        mode: '0644',
        description: 'Mysql backup',
        command: 'mysqldump -u root test_db >some_file'
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
        %r{\s+#{params[:user]}\s+}
      ).with_content(
        %r{\s+#{params[:command]}\n}
      ).with_content(
        %r{\n# #{params[:description]}\n}
      )
    end
  end

  context 'job with ensure set to absent' do
    let(:params) do
      {
        ensure: 'absent'
      }
    end

    it do
      is_expected.to contain_file("job_#{title}").with('ensure' => 'absent')
    end
  end
end

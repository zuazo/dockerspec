# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2016 Xabier de Zuazo
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'
require 'infrataster-plugin-mysql'

describe 'Docker Compose' do
  file = DockerspecTests.fixture_file('docker-compose.yml')
  describe docker_compose(file, wait: ENV['CI'] ? 90 : 15) do
    its_container(:db, mysql: { user: 'root', password: 'example' }) do
      its(:stdout) { should include 'MySQL init process done.' }
      its(:stderr, retry: 10) do
        should include 'mysqld: ready for connections.'
      end

      serverspec_tests do
        # Issue #2: https://github.com/zuazo/dockerspec/issues/2
        case os[:family]
        when 'debian'
          it 'is Debian' do
            expect(file('/etc/debian_version')).to exist
          end
        else
          it 'Wrong OS' do
            raise "Wrong OS: #{os[:family]}"
          end
        end

        it 'detects the OS family' do
          expect(command('uname -a').stdout).to match(/Debian|Ubuntu/i)
          expect(file('/etc/alpine-release').exists?).to be false
          expect(property[:os][:family]).to eq 'debian'
        end

        describe command('mysqld -V') do
          its(:stdout) { should match(/^mysqld .*MariaDB/i) }
        end

        describe file('/etc/mysql') do
          it { should exist }
          it { should be_directory }
          it { should be_mode 755 }
        end

        describe file('/usr/sbin/mysqld') do
          it { should exist }
          it { should be_file }
          it { should be_mode 755 }
          it { should be_executable }
          it { should be_executable.by_user 'root' }
        end

        describe file('/etc/mysql/my.cnf') do
          it { should exist }
          it { should be_file }
          it { should contain('[mysqld]') }
          it { should be_mode 644 }
          it { should be_owned_by 'root' }
          it { should be_grouped_into 'root' }
          it { should be_readable }
          it { should be_readable.by_user 'root' }
          it { should be_writable }
          it { should be_writable.by_user 'root' }
          its(:size) { should < 641_021 }
        end

        describe group('root') do
          it { should exist }
          it { should have_gid 0 }
        end

        describe interface('eth0') do
          it { should exist }
        end

        describe package('mariadb-server') do
          it { should be_installed }
        end

        describe process('mysqld') do
          it { should be_running }
          its(:user) { should eq 'mysql' }
        end

        describe service('mysqld') do
          it { should be_running }
        end

        describe user('root') do
          it { should exist }
          it { should belong_to_group 'root' }
          it { should have_uid 0 }
          it { should have_home_directory '/root' }
          it { should have_login_shell '/bin/bash' }
        end
      end

      infrataster_tests do
        describe server(described_container) do
          describe mysql_query('SHOW STATUS') do
            it 'returns positive uptime' do
              row = results.find { |r| r['Variable_name'] == 'Uptime' }
              expect(row['Value'].to_i).to be > 0
            end
          end
        end
      end
    end

    its_container(:wordpress) do
      its(:stdout) { should include '' }
      its(:stderr) { should include 'WordPress has been successfully copied' }

      serverspec_tests do
        it 'detects the OS family' do
          expect(command('uname -a').stdout).to match(/Debian|Ubuntu/i)
          expect(file('/etc/alpine-release').exists?).to be false
          expect(property[:os][:family]).to eq 'debian'
        end

        describe command('ls -al /') do
          its(:stdout) { should match(/bin/) }
          its(:exit_status) { should eq 0 }
        end

        describe command('apache2 -v') do
          its(:stdout) { should match(/Server +version: +Apache/) }
        end

        describe file('/etc/apache2') do
          it { should exist }
          it { should be_directory }
          it { should be_mode 755 }
        end

        describe file('/usr/sbin/apache2') do
          it { should exist }
          it { should be_file }
          it { should be_mode 755 }
          it { should be_executable }
          it { should be_executable.by_user('root') }
        end

        describe file('/etc/apache2/conf-available/docker-php.conf') do
          it { should exist }
          it { should be_file }
          it { should contain 'DirectoryIndex index.php' }
          it do
            should contain('AllowOverride All')
              .from(%r{^<Directory /var/www/>}).to(%r{^</Directory>})
          end
          it { should be_mode 644 }
          it { should be_owned_by 'root' }
          it { should be_grouped_into 'root' }
          it { should be_readable }
          it { should be_readable.by_user 'root' }
          it { should be_writable }
          it { should be_writable.by_user 'root' }
          its(:size) { should < 641_021 }
        end

        describe group('root') do
          it { should exist }
          it { should have_gid 0 }
        end

        describe interface('eth0') do
          it { should exist }
        end

        describe package('apache2') do
          it { should be_installed }
        end

        describe process('apache2'), retry: 10 do
          it { should be_running }
          its(:user) { should eq 'root' }
          its(:args) { should match(/-DFOREGROUND/) }
        end

        describe service('apache2') do
          it { should be_enabled }
          it { should be_running }
        end

        describe user('root') do
          it { should exist }
          it { should belong_to_group 'root' }
          it { should have_uid 0 }
          it { should have_home_directory '/root' }
          it { should have_login_shell '/bin/bash' }
        end
      end

      infrataster_tests do
        describe server(described_container), retry: 30 do
          describe http('/wp-admin/install.php') do
            it 'responds content including "Wordpress Installation"' do
              expect(response.body).to match(/WordPress .* Installation/i)
            end

            it 'responds as "text/html"' do
              expect(response.headers['content-type']).to include 'text/html'
            end
          end
        end
      end
    end

    its_container(:alpine) do
      serverspec_tests do
        # Issue #2: https://github.com/zuazo/dockerspec/issues/2
        case os[:family]
        when 'alpine'
          it 'is Alpine' do
            expect(file('/etc/alpine-release')).to exist
          end
        else
          it 'Wrong OS' do
            raise "Wrong OS: #{os[:family]}"
          end
        end

        it 'detects the OS family' do
          expect(file('/etc/alpine-release').exists?).to be true
          expect(property[:os][:family]).to eq 'alpine'
        end
      end
    end
  end
end

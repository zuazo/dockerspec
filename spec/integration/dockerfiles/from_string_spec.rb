# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015 Xabier de Zuazo
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

serverspec_tests do
  describe 'Build a Dockerfile from a string' do
    describe docker_build(string: 'FROM nginx:1.9', tag: 'from_string_spec') do
      describe docker_run('from_string_spec') do
        describe command('ls -al /') do
          its(:stdout) { should match(/bin/) }
          its(:exit_status) { should eq 0 }
        end

        describe command('nginx -v') do
          its(:stderr) { should match(/nginx version:/) }
        end

        describe file('/etc/nginx') do
          it { should exist }
          it { should be_directory }
          it { should be_mode 755 }
        end

        describe file('/usr/sbin/nginx') do
          it { should exist }
          it { should be_file }
          it { should be_mode 755 }
          it { should be_executable }
          it { should be_executable.by_user('root') }
        end

        describe file('/etc/nginx/nginx.conf') do
          it { should exist }
          it { should be_file }
          it { should contain 'access.log' }
          it { should contain('include').from(/^http {/).to(/^}/) }
          it { should be_mode 644 }
          it { should be_owned_by 'root' }
          it { should be_grouped_into 'root' }
          it { should be_readable }
          it { should be_readable.by_user('root') }
          it { should be_writable }
          it { should be_writable.by_user('root') }
          its(:size) { should < 641_021 }
        end

        describe group('root') do
          it { should exist }
          it { should have_gid 0 }
        end

        describe interface('eth0') do
          it { should exist }
        end

        describe package('nginx') do
          it { should be_installed }
        end

        describe process('nginx') do
          it { should be_running }
          its(:user) { should eq 'root' }
          its(:args) { should match(/-g daemon/) }
        end

        describe service('nginx') do
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
    end
    context 'With string_build_path' do
      Dir.mktmpdir do |dir|
        File.write("#{dir}/test", 'rspec integration tests')
        dockerfile_string = "FROM nginx:1.9\nADD test /test"
        describe docker_build(
          string: dockerfile_string,
          string_build_path: dir) do
          describe docker_run(described_image) do
            describe command('cat /test') do
              its(:stdout) { should match(/rspec integration tests/) }
              its(:exit_status) { should eq 0 }
            end
          end
        end
      end
    end
  end
end

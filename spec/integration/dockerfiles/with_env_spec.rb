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

describe 'Build a Docker container with specific environment' do
  password = 'B3xuQpGW6wbL6UGzqs5c'

  describe docker_run(
    'mariadb@sha256:'\
    '68b616083f131ac3e7c850242d2725ebdd70899ce29733e69432c27195d87e50',
    env: { MYSQL_ROOT_PASSWORD: password },
    mysql: { user: 'root', password: password }
  ) do
    serverspec_tests do
      describe command('mysqld -V') do
        its(:stdout) { should match(/^mysqld .*MariaDB/i) }
      end

      describe process('mysqld') do
        it { should be_running }
      end

      describe service('mysqld') do
        it { should be_running }
      end
    end

    infrataster_tests do
      describe server(described_container) do
        before(:all) { sleep(20) } # Wait until MySQL server is ready

        describe mysql_query('SHOW STATUS') do
          it 'returns positive uptime' do
            row = results.find { |r| r['Variable_name'] == 'Uptime' }
            expect(row['Value'].to_i).to be > 0
          end
        end
      end
    end
  end
end

# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015-2016 Xabier de Zuazo
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

describe 'Build a Dockerfile from a tag' do
  id =
    'nginx@sha256:'\
    '54313b5c376892d55205f13d620bc3dcccc8e70e596d083953f95e94f071f6db'
  describe docker_build(id: id, tag: 'from_tag_spec') do
    describe docker_run('from_tag_spec') do
      serverspec_tests do
        describe package('nginx') do
          it { should be_installed }
        end

        it 'is a Linux distro' do
          expect(command('uname').stdout).to include 'Linux'
        end
      end

      infrataster_tests do
        describe server(described_container) do
          describe http('/') do
            it 'responds content including "Welcome to nginx!"' do
              expect(response.body).to include 'Welcome to nginx!'
            end

            it 'responds as "nginx" server' do
              expect(response.headers['server']).to match(/nginx/i)
            end
          end
        end
      end
    end
  end
end

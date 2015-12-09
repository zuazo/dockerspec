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

describe Dockerspec::RSpecAssertions do
  context '.assert_docker_run!' do
    it 'raises a DockerRunArgumentError exception' do
      expect { described_class.assert_docker_run!('opts') }
        .to raise_error(Dockerspec::DockerRunArgumentError)
    end

    context 'the error message' do
      it "include `require 'dockerspec'" do
        expect { described_class.assert_docker_run!('opts') }
          .to raise_error(
            Dockerspec::DockerRunArgumentError, /^\s*require 'dockerspec'/
          )
      end

      it "include `require 'dockerspec/serverspec'" do
        expect { described_class.assert_docker_run!('opts') }
          .to raise_error(
            Dockerspec::DockerRunArgumentError,
            %r{^\s*require 'dockerspec/serverspec'}
          )
      end
    end
  end
end

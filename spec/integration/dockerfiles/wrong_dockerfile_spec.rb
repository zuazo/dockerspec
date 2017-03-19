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

describe 'With a wrong Dockerfile' do
  describe 'with build errors' do
    let(:file) { DockerspecTests.fixture_file('WrongDockerfile') }
    let(:build) { docker_build(path: file, tag: 'wrong_dockerfile_spec') }
    # Until https://github.com/swipely/docker-api/pull/472 fixed:
    before { Docker::Image.create('fromImage' => 'alpine:3.2') }

    it 'raises docker error' do
      expect { build }.to raise_error Dockerspec::DockerError
    end

    it 'parses the build output' do
      expect { build }.to raise_error(
        Dockerspec::DockerError, /OUTPUT: .*Step [0-9]/m
      )
    end

    it 'parses the build error' do
      expect { build }.to raise_error(
        Dockerspec::DockerError,
        /ERROR: +The command .* returned a non-zero code:/
      )
    end
  end
end

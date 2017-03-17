# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2017 Xabier de Zuazo
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

class TestDockerspecRunnerHelpers
  include Dockerspec::Runner::ConfigHelpers
end

describe Dockerspec::Runner::ConfigHelpers do
  let(:container) { double('Docker::Container') }
  subject { TestDockerspecRunnerHelpers.new }
  before do
    allow(container).to receive(:logs).with(stdout: true).once
      .and_return('STDOUT')
    allow(container).to receive(:logs).with(stderr: true).once
      .and_return('STDERR')
  end

  context '#stdout' do
    before do
      expect(subject).to receive(:container).and_return(container)
    end

    it 'returns the stdout string' do
      expect(subject.stdout).to eq('STDOUT')
    end

    it 'filters until the first "\a"' do
      allow(container).to receive(:logs).with(stdout: true).once
        .and_return("\x01\x00\x00\x00\x00\x00\x00\aSTDOUT2")
      expect(subject.stdout).to eq('STDOUT2')
    end

    it 'does not filter the second "\a"' do
      allow(container).to receive(:logs).with(stdout: true).once
        .and_return("\x01\x00\x00\x00\x00\x00\x00\aSTDOUT\a2")
      expect(subject.stdout).to eq("STDOUT\a2")
    end
  end

  context '#stderr' do
    before do
      expect(subject).to receive(:container).and_return(container)
    end

    it 'returns the stderr string' do
      expect(subject.stderr).to eq('STDERR')
    end

    it 'filters until the first "\a"' do
      allow(container).to receive(:logs).with(stderr: true).once
        .and_return("\x02\x00\x00\x00\x00\x00\x00\aSTDERR2")
      expect(subject.stderr).to eq('STDERR2')
    end

    it 'does not filter the second "\a"' do
      allow(container).to receive(:logs).with(stderr: true).once
        .and_return("\x02\x00\x00\x00\x00\x00\x00\aSTDERR\a2")
      expect(subject.stderr).to eq("STDERR\a2")
    end
  end
end

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

class TestDockerspecRSpecResources
  include Dockerspec::RSpecResources
end

describe Dockerspec::RSpecResources do
  subject { TestDockerspecRSpecResources.new }
  let(:builder) { double('Dockerspec::Builder') }
  let(:opts) { { opt1: 'val1' } }
  before do
    allow(Dockerspec::Builder).to receive(:new).and_return(builder)
    allow(builder).to receive(:build)
  end

  context '#docker_build' do
    it 'creates a new Builder' do
      expect(Dockerspec::Builder).to receive(:new).once.with(opts)
        .and_return(builder)
      subject.docker_build(opts)
    end

    it 'builds the Builder' do
      expect(builder).to receive(:build).once.with(no_args)
      subject.docker_build(opts)
    end

    it 'returns the build result' do
      allow(builder).to receive(:build).and_return('built')
      expect(subject.docker_build(opts)).to eq 'built'
    end
  end

  context '#docker_run' do
    it 'asserts docker run' do
      expect(Dockerspec::RSpecAssertions).to receive(:assert_docker_run!).once
        .with(%w(example opts))
      subject.docker_run('example', 'opts')
    end
  end
end

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

class TestDockerspecServerspecRSpecResources
  include Dockerspec::Serverspec::RSpecResources
end

describe Dockerspec::Serverspec::RSpecResources do
  subject { TestDockerspecServerspecRSpecResources.new }
  let(:example) { 'example' }
  let(:example_metadata) { 'example_metadata' }
  let(:opts) { {} }
  let(:runner) { double('Dockerspec::Serverspec::Runner') }
  let(:runner_backend) { 'runner_backend' }
  let(:specinfra_backend) { double('Dockerspec::Serversec::SpecinfraBackend') }
  before do
    allow(Dockerspec::Serverspec::Runner).to receive(:new).and_return(runner)
    allow(runner).to receive(:backend).and_return(runner_backend)
    allow(Dockerspec::Serverspec::SpecinfraBackend)
      .to receive(:new).and_return(specinfra_backend)
    allow(specinfra_backend).to receive(:reset)
    allow(runner).to receive(:run).and_return(runner)
    allow(example).to receive(:metadata).and_return(example_metadata)
    allow(specinfra_backend).to receive(:save)
  end

  context '#docker_run' do
    it 'creates Serverspec Runner' do
      allow(Dockerspec::Serverspec::Runner)
        .to receive(:new).and_return(runner).once.with(example, opts)
      subject.docker_run(example, opts)
    end

    it 'runs the Serverspec Runner' do
      expect(runner).to receive(:run).once
      subject.docker_run(example, opts)
    end

    it 'returns runner' do
      expect(subject.docker_run(example, opts)).to eq runner
    end
  end
end

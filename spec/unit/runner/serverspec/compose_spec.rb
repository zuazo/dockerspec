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

describe Dockerspec::Runner::Serverspec::Compose do
  let(:file) { 'compose-file.yml' }
  let(:opts) { { file: file } }
  subject { described_class.new(opts) }
  let(:engines) { double('Dockerspec::EngineList') }
  let(:container_name) { 'webapp' }
  let(:container) { double('Docker::Container') }
  let(:compose_container) { double('ComposeContainer', container: container) }
  let(:containers) { { container_name => compose_container } }
  let(:compose) { double('DockerCompose', containers: containers) }
  let(:configuration) { double('Specinfra::Configuration') }
  let(:specinfra_backend) { double('Dockerspec::Engine::Specinfra::Backend') }
  before do
    stub_runner_compose(file, compose, engines)

    allow(Specinfra).to receive(:configuration).and_return(configuration)
    allow(Dockerspec::Helper::Docker).to receive(:lxc_execution_driver?)
      .and_return(false)
    allow(configuration).to receive(:backend)
    allow(configuration).to receive(:os)
    allow(configuration).to receive(:docker_wait)
    allow(configuration).to receive(:docker_compose_file)

    allow(Dockerspec::Engine::Specinfra::Backend)
      .to receive(:new).and_return(specinfra_backend)
    allow(specinfra_backend).to receive(:reset)
    allow(specinfra_backend).to receive(:save)
  end

  context '.new' do
    it 'runs without errors' do
      subject
    end
  end

  context '#compose' do
    let(:compose) { double('DockerCompose') }

    it 'returns backend compose attribute' do
      expect(specinfra_backend).to receive(:backend_instance_attribute).once
        .with(:compose).and_return(compose)
      expect(subject.send(:compose)).to eq(compose)
    end
  end

  context '#run' do
    it 'runs without errors' do
      subject.run
    end

    it 'sets docker compose file' do
      expect(configuration).to receive(:docker_compose_file).once.with(file)
      subject.run
    end
  end
end

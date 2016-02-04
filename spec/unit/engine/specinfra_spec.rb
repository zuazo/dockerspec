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

describe Dockerspec::Engine::Specinfra do
  let(:runner) do
    double(
      'Dockerspec::Runner::Base', backend_name: backend_name, options: opts
    )
  end
  subject { described_class.new(runner) }
  let(:backend) { double('Dockerspec::Engine::Specinfra::Backend') }
  let(:backend_name) { 'docker_lxc' }
  let(:container_name) { 'webapp' }
  let(:family) { 'alpine' }
  let(:opts) { { container: container_name, family: family } }
  let(:specinfra_config) { double('Specinfra::Configuration') }
  before do
    allow(Dockerspec::Engine::Specinfra::Backend).to receive(:new)
      .and_return(backend)
    allow(backend).to receive(:reset)
    allow(backend).to receive(:restore_container)
    allow(Specinfra).to receive(:configuration).and_return(specinfra_config)
    allow(specinfra_config).to receive(:os)
  end

  context '.new' do
    it 'creates a new instance' do
      expect(subject).to be_a described_class
    end
  end

  context '#setup' do
    it 'creates the backend' do
      expect(Dockerspec::Engine::Specinfra::Backend).to receive(:new).once
        .with(backend_name).and_return(backend)
      subject.setup
    end

    it 'resets the backend' do
      expect(backend).to receive(:reset).once.with(no_args)
      subject.setup
    end

    it 'sets up the container name' do
      expect(backend).to receive(:restore_container).once.with(container_name)
      subject.setup
    end

    it 'sets up the family' do
      expect(specinfra_config).to receive(:os).once.with(family: family)
      subject.setup
    end
  end

  context '#save' do
    it 'saves the backend' do
      subject.setup
      expect(backend).to receive(:save).once.with(no_args)
      subject.save
    end
  end

  context '#restore' do
    before do
      allow(backend).to receive(:restore)
      allow(backend).to receive(:restore_container)
    end

    it 'restores the backend' do
      subject.setup
      expect(backend).to receive(:restore).once.with(no_args)
      subject.restore
    end

    it 'sets up the container name' do
      subject.setup
      expect(backend).to receive(:restore_container).once.with(container_name)
      subject.restore
    end

    it 'sets up the family' do
      subject.setup
      expect(specinfra_config).to receive(:os).once.with(family: family)
      subject.restore
    end
  end
end

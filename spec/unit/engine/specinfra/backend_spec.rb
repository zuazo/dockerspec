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

# A dummy Specinfra Backend for unit tests.
class MockSpecinfraBackend
  attr_reader :instance

  def self.instance_set(i)
    @instance = i
  end
end

describe Dockerspec::Engine::Specinfra::Backend do
  shared_examples 'specinfra backend test' do
    let(:instance) { MockSpecinfraBackend.new }
    subject { described_class.new(backend) }

    context '#save' do
      let(:instance) { double('instance') }
      before { allow(backend_class).to receive(:instance).and_return(instance) }

      it 'saves the backend' do
        subject.save
        expect(subject.instance_variable_get(:@saved_backend_instance))
          .to eq instance
      end
    end

    context '#restore' do
      let(:saved_instance) { double('instance') }
      before do
        subject.instance_variable_set(:@saved_backend_instance, saved_instance)
      end

      it 'restores the backend' do
        expect(backend_class).to receive(:instance_set).with(saved_instance)
        subject.restore
      end
    end

    context '#restore_container' do
      let(:config) { double('Specinfra::Configuration') }
      let(:current_name) { 'current' }
      before do
        allow(Specinfra).to receive(:configuration).and_return(config)
        allow(config).to receive(:docker_compose_container)
          .with(no_args).and_return(current_name)
        allow(backend_class).to receive(:host_reset)
      end

      it 'updates the container name' do
        new_name = 'new'
        expect(config).to receive(:docker_compose_container).with(new_name)
          .once
        subject.restore_container(new_name)
      end

      it 'does not update if not required' do
        expect(config).to_not receive(:docker_compose_container)
          .with(current_name)
        expect(backend_class).to_not receive(:host_reset)
        subject.restore_container(current_name)
      end

      it 'resets the host information' do
        new_name = 'new'
        allow(config).to receive(:docker_compose_container).with(new_name)
        expect(backend_class).to receive(:host_reset).once
        subject.restore_container(new_name)
      end
    end

    context '#reset' do
      it 'sets the instance to nil' do
        expect(backend_class).to receive(:instance_set).with(nil)
        subject.reset
      end
    end
  end # shared example

  context 'with a string as backend' do
    let(:backend) { 'base' }
    let(:backend_class) { 'backend_class' }
    before do
      allow(Specinfra::Backend).to receive(:const_get).with('Base')
        .and_return(backend_class)
    end

    include_examples 'specinfra backend test'
  end

  context 'with a class as backend' do
    let(:backend) { Specinfra::Backend::Base }
    let(:backend_class) { backend }

    include_examples 'specinfra backend test'
  end

  context 'with a class instance as backend' do
    let(:backend_class) { Specinfra::Backend::Base }
    let(:backend) { backend_class.new }

    include_examples 'specinfra backend test'
  end
end

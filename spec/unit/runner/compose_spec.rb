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

describe Dockerspec::Runner::Compose do
  let(:file) { 'compose-file.yml' }
  let(:opts) { { file: file } }
  subject { described_class.new(opts) }
  let(:engines) { double('Dockerspec::EngineList') }
  let(:container_name) { 'webapp' }
  let(:container) { double('Docker::Container') }
  let(:compose_container) { double('ComposeContainer', container: container) }
  let(:containers) { { container_name => compose_container } }
  let(:compose) { double('DockerCompose', containers: containers) }
  before { stub_runner_compose(file, compose, engines) }

  context '.new' do
    it 'sets the .current_instance variable' do
      expect(Dockerspec::Runner::Compose).to receive(:current_instance=).once
      subject
    end

    it 'reads the configuration file' do
      expect(DockerCompose).to receive(:load).once.with(file)
        .and_return(compose)
      subject
    end

    it 'raises an error without file' do
      opts.delete(:file)
      expect { subject }.to raise_error(/`:file`/)
    end

    context 'when passing a directory' do
      before do
        allow(File).to receive(:directory?).with(file).and_return(true)
      end

      it 'reads the `docker-compose.yml` file' do
        real_file = File.join(file, 'docker-compose.yml')
        expect(DockerCompose).to receive(:load).once.with(real_file)
          .and_return(compose)
        subject
      end
    end
  end

  context '#select_container' do
    it 'selects the container' do
      subject.select_container(container_name)
    end

    it 'accepts options' do
      subject.select_container(container_name, opt1: 'val1')
    end

    it 'sets the engines as ready' do
      expect(engines).to receive(:when_container_ready).once
      subject.select_container(container_name)
    end
  end

  context '#options' do
    it 'returns options' do
      expect(subject.options).to be_a Hash
    end

    it 'returns container options if set' do
      opts = { opt1: 'val1' }
      subject.select_container(container_name, opts)
      expect(subject.options).to include opts
    end

    it 'can read docker compose wait from RSpec configuration' do
      wait = 30
      RSpec.configuration.docker_wait = wait
      expect(subject.options[:wait]).to eq wait
      RSpec.configuration.docker_wait = false
    end
  end

  context '#to_s' do
    it 'contains a description' do
      expect(subject.to_s).to include 'Docker Compose'
    end

    it 'contains the file path' do
      expect(subject.to_s).to include file
    end
  end

  context '#run' do
    context 'with docker wait set' do
      let(:docker_wait) { 10 }
      let(:time) { Time.new.utc }
      before do
        allow(Time).to receive(:new).and_return(time)
        opts[:wait] = docker_wait
      end

      it 'sleeps' do
        expect(subject).to receive(:sleep).once
        subject.run
      end

      context 'when compose start takes longer than wait' do
        before do
          allow(Time).to receive(:new).and_return(time, time + docker_wait + 1)
        end

        it 'does not sleep by default' do
          expect(subject).to_not receive(:sleep)
          subject
        end
      end
    end
  end

  context '#id' do
    let(:id) { 'b98ffa2251d3' }
    before { allow(container).to receive(:id).and_return(id) }

    it 'returns the id' do
      subject.select_container(container_name)
      expect(subject.id).to eq(id)
    end

    it 'raises an error when there is no container selected' do
      expect { subject.id }
        .to raise_error Dockerspec::RunnerError, /`its_container`/
    end

    it 'raises an error when the container is not found' do
      allow(compose).to receive(:containers).and_return({})
      subject.select_container(container_name)
      expect { subject.id }
        .to raise_error Dockerspec::RunnerError, /Container not found/
    end
  end

  context '#finalize' do
    context 'with rm disabled' do
      before { opts[:rm] = false }

      it 'does nothing if :rm disabled' do
        expect(compose).to_not receive(:stop)
        expect(compose).to_not receive(:delete)
        subject.finalize
      end
    end

    context 'with rm enabled' do
      before { opts[:rm] = true }

      it 'stops compose' do
        expect(compose).to receive(:stop).once
        subject.finalize
      end

      it 'deletes compose' do
        expect(compose).to receive(:delete).once
        subject.finalize
      end
    end
  end
end

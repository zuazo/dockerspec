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

describe Dockerspec::Runner::Docker do
  let(:image_id) { '8d5e6665a7a6' }
  let(:build_json) { {} }
  let(:builder) do
    double(
      'Dockerspec::Builder',
      id: image_id,
      image_config: build_json,
      json: build_json,
      cmd: %w(/bin/sh)
    )
  end
  let(:opts) { { tag: image_id, rm: true } }
  subject { described_class.new(opts) }
  let(:container_id) { '198a73cfd686' }
  let(:container_json) { { 'Image' => image_id } }
  let(:container) do
    double('Docker::Container', json: container_json, id: container_id)
  end
  let(:engines) { double('Dockerspec::EngineList') }
  let(:metadata) { {} }
  before do
    allow(Dockerspec::EngineList).to receive(:new).and_return(engines)
    allow(engines).to receive(:before_running)
    allow(engines).to receive(:when_running)
    allow(engines).to receive(:when_container_ready)
    allow(ObjectSpace).to receive(:define_finalizer)
    allow(Docker::Container).to receive(:create).and_return(container)
    allow(Docker::Container).to receive(:get).and_return(container)
    allow(container).to receive(:start)
    allow(container).to receive(:stop)
    allow(container).to receive(:delete)

    allow(Dockerspec::Builder).to receive(:new).and_return(builder)
    allow(builder).to receive(:build).and_return(builder)
  end

  context '.new' do
    it 'accepts an image tag' do
      described_class.new('debian')
    end

    it 'accepts an image tag in hash format' do
      described_class.new(tag: 'debian')
    end

    it 'accepts a container ID' do
      described_class.new(id: '8a648f689ddb')
    end

    it 'defines a finalizer' do
      expect(ObjectSpace).to receive(:define_finalizer).once
      subject
    end

    it 'raises an error if no tag or id is passed' do
      expect { described_class.new(bad: '8a648f689ddb') }
        .to raise_error(Dockerspec::DockerRunArgumentError, /:tag.*:id/)
    end

    context 'with constructor errors' do
      let(:error_msg) { DockerspecTests.error_example }

      context 'from an image ID' do
        subject { described_class.new(id: 'id') }
        before do
          expect(Docker::Container).to receive(:get)
            .and_raise Docker::Error::DockerError.new(error_msg)
        end

        it 'raises a docker error' do
          expect { subject }.to raise_error Dockerspec::DockerError
        end
      end
    end
  end

  context '#run' do
    it 'runs without errors' do
      subject.run
    end

    it 'returns the Runner object' do
      expect(subject.run).to be_a described_class
      expect(container).to receive(:start).once
      subject.run
    end

    it 'setups engines before running' do
      expect(engines).to receive(:before_running).with(no_args).ordered
      expect(Docker::Container).to receive(:create).ordered
      expect(container).to receive(:start).ordered
      subject.run
    end

    it 'creates the container' do
      expect(Docker::Container).to receive(:create).ordered
      expect(container).to receive(:start).ordered
      subject.run
    end

    it 'starts the container' do
      expect(container).to receive(:start).once
      subject.run
    end

    context 'with run errors' do
      let(:error_msg) { DockerspecTests.error_example }

      before do
        expect(Docker::Container).to receive(:create)
          .and_raise Docker::Error::DockerError.new(error_msg)
      end

      it 'raises a docker error' do
        expect { subject.run }.to raise_error Dockerspec::DockerError
      end
    end

    it 'saves engines after running' do
      expect(container).to receive(:start).ordered
      expect(engines).to receive(:when_running).with(no_args).ordered
      subject.run
    end

    it 'sets the engines ready after saving' do
      expect(engines).to receive(:when_running).with(no_args).ordered
      expect(engines).to receive(:when_container_ready).with(no_args).ordered
      subject.run
    end
  end

  context '#id' do
    it 'returns `nil` before run' do
      expect(subject.id).to eq nil
    end

    it 'returns container ID after run' do
      subject.run
      expect(subject.id).to eq container_id
    end
  end

  context '#image_id' do
    it 'returns image ID for image tags' do
      expect(builder).to receive(:id).once.and_return('tag')
      subject = described_class.new(tag: 'tag')
      expect(subject.image_id).to eq 'tag'
    end

    it 'returns image ID for container IDs' do
      expect(Docker::Container)
        .to receive(:get).once.with('id').and_return(container)
      subject = described_class.new(id: 'id')
      expect(subject.image_id).to eq image_id
    end
  end

  context '#finalize' do
    it 'does nothing if :rm disabled' do
      expect(container).to_not receive(:stop)
      expect(container).to_not receive(:delete)
      subject = described_class.new(opts.merge(rm: false))
      subject.run
      subject.finalize
    end

    it 'does nothing before running the container' do
      expect(container).to_not receive(:stop)
      expect(container).to_not receive(:delete)
      subject.finalize
    end

    it 'stops the container' do
      expect(container).to receive(:stop).once
      subject.run
      subject.finalize
    end

    it 'deletes the container' do
      expect(container).to receive(:delete).once
      subject.run
      subject.finalize
    end
  end

  context '#to_s' do
    it 'returns a description' do
      expect(subject.to_s).to match(/^Docker Run from /)
    end
  end
end

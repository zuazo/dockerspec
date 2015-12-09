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

describe Dockerspec::Runner do
  let(:builder) { double('Dockerspec::Builder') }
  let(:image_id) { '8d5e6665a7a6' }
  let(:opts) { { tag: image_id, rm: true } }
  subject { described_class.new(opts) }
  let(:build_json) { {} }
  let(:container_id) { '198a73cfd686' }
  let(:container) { double('Docker::Container') }
  let(:container_json) { { 'Image' => image_id } }
  let(:metadata) { {} }
  before do
    allow(ObjectSpace).to receive(:define_finalizer)
    allow(Docker::Container).to receive(:create).and_return(container)
    allow(Docker::Container).to receive(:get).and_return(container)
    allow(container).to receive(:json).and_return(container_json)
    allow(container).to receive(:start)
    allow(container).to receive(:id).and_return(container_id)
    allow(container).to receive(:stop)
    allow(container).to receive(:delete)

    allow(Dockerspec::Builder).to receive(:new).and_return(builder)
    allow(builder).to receive(:build).and_return(builder)
    allow(builder).to receive(:image_id).and_return(image_id)
    allow(builder).to receive(:image_config).and_return(build_json)
    allow(builder).to receive(:json).and_return(build_json)
    allow(builder).to receive(:id).and_return(image_id)
    allow(builder).to receive(:cmd).and_return(%w(/bin/sh))
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
  end

  context '#run' do
    it 'runs without errors' do
      subject.run
    end

    it 'returns the Runner object' do
      expect(subject.run).to be_a described_class
    end

    it 'starts the container' do
      expect(container).to receive(:start).once
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

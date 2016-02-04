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

describe Dockerspec::RSpec::Resources::ItsContainer do
  let(:container) { 'webapp' }
  subject { described_class.new(container) }
  context '.new' do
    it 'creates an instance without errors' do
      expect(subject).to be_a(described_class)
    end
  end

  context '#restore_rspec_context' do
    let(:example) { 'example' }
    let(:metadata) { 'metadata' }
    let(:compose) { double('Dockerspec::Runner::Compose') }
    before do
      allow(RSpec).to receive(:current_example).and_return(example)
      allow(example).to receive(:metadata).and_return(metadata)
      allow(Dockerspec::Helper::RSpecExampleHelpers)
        .to receive(:search_object).and_return(compose)
      allow(compose).to receive(:restore_rspec_context)
      allow(compose).to receive(:select_container)
    end

    it 'reads RSpec current metadata' do
      expect(example).to receive(:metadata).once
      subject.restore_rspec_context
    end

    it 'searches RSpec metadata' do
      expect(Dockerspec::Helper::RSpecExampleHelpers)
        .to receive(:search_object).once
        .with(metadata, Dockerspec::Runner::Compose).and_return(compose)
      subject.restore_rspec_context
    end

    it 'raises an error if not found in RSpec metadata' do
      allow(Dockerspec::Helper::RSpecExampleHelpers)
        .to receive(:search_object).and_return(nil)
      expect { subject.restore_rspec_context }.to raise_error(
        Dockerspec::ItsContainerError, /used with.*`docker_compose`/
      )
    end

    it 'restores rspec context' do
      expect(compose).to receive(:restore_rspec_context).once.with(no_args)
      subject.restore_rspec_context
    end

    it 'selects the container' do
      allow(compose).to receive(:select_container).once.with(container)
      subject.restore_rspec_context
    end
  end

  context '#to_s' do
    it 'returns a description' do
      expect(subject.to_s).to include(container)
    end
  end
end

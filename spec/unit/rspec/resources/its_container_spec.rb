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
  let(:container_name) { 'webapp' }
  let(:container) { double('Docker::Container') }
  let(:compose) { double('Dockerspec::Runner::Compose', container: container) }
  subject { described_class.new(container_name, compose) }

  context '.new' do
    it 'creates an instance without errors' do
      expect(subject).to be_a(described_class)
    end
  end

  context '#restore_rspec_context' do
    let(:compose) { double('Dockerspec::Runner::Compose') }
    before do
      allow(compose).to receive(:restore_rspec_context)
      allow(compose).to receive(:select_container)
    end

    it 'restores rspec context' do
      expect(compose).to receive(:restore_rspec_context).once.with(no_args)
      subject.restore_rspec_context
    end

    it 'selects the container' do
      allow(compose).to receive(:select_container).once.with(container_name)
      subject.restore_rspec_context
    end
  end

  context '#container' do
    it 'returns the selected container' do
      expect(subject.container).to eq(container)
    end
  end

  context '#to_s' do
    it 'returns a description' do
      expect(subject.to_s).to include(container_name)
    end
  end
end

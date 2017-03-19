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

describe Dockerspec::Helper::RSpecExampleHelpers do
  context '.search_objects_with' do
    let(:obj1) { 'dony' }
    let(:obj2) { 'leo' }
    let(:bad_obj1) { 'krang'.to_sym }
    let(:metadata) do
      {
        described_class: obj1,
        example_group: {
          described_class: bad_obj1,
          example_group: {
            described_class: obj2
          }
        }
      }
    end

    it 'returns found objects in reverse order' do
      expect(
        described_class.search_objects_with(metadata, :strip, 0)
      ).to eq([obj1, obj2].reverse)
    end

    it 'returns no objects when not found' do
      expect(
        described_class.search_objects_with(metadata, :nonexistent, 0)
      ).to eq([])
    end
  end

  context '.restore_rspec_context' do
    let(:runner) { double('Dockerspec::Runner::Base') }
    let(:metadata) { { metadata: 'ok' } }
    before do
      allow(Dockerspec::Helper::RSpecExampleHelpers)
        .to receive(:search_objects_with)
        .with(metadata, :restore_rspec_context, 0)
        .and_return([runner])
    end

    it 'restores the runner' do
      expect(runner).to receive(:restore_rspec_context).once
      described_class.restore_rspec_context(metadata)
    end
  end
end

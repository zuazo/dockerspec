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
  let(:docker_info) { {} }
  before { allow(::Docker).to receive(:info).and_return(docker_info) }

  context '.search_object' do
    context 'when the object exists inside the described_class' do
      let(:klass) { String }
      let(:object) { klass.new }
      let(:metadata) do
        { described_class: object }
      end

      it 'founds the object' do
        expect(described_class.search_object(metadata, klass)).to eq(object)
      end
    end

    context 'when the object exists inside an example group' do
      let(:klass) { String }
      let(:object) { klass.new }
      let(:metadata) do
        { example_group: { described_class: object } }
      end

      it 'founds the object' do
        expect(described_class.search_object(metadata, klass)).to eq(object)
      end
    end

    context 'when the object exists inside parent example group' do
      let(:klass) { String }
      let(:object) { klass.new }
      let(:metadata) do
        {
          example_group: { parent_example_group: { described_class: object } }
        }
      end

      it 'founds the object' do
        expect(described_class.search_object(metadata, klass)).to eq(object)
      end
    end

    context 'when the object does not exist' do
      let(:klass) { String }
      let(:object) { klass.new }
      let(:metadata) { { random: :stuff } }

      it 'founds the object' do
        expect(described_class.search_object(metadata, Fixnum)).to eq(nil)
      end
    end

    context 'when the class does not match' do
      let(:klass) { String }
      let(:object) { klass.new }
      let(:metadata) do
        {
          example_group: { parent_example_group: { described_class: object } }
        }
      end

      it 'founds the object' do
        expect(described_class.search_object(metadata, Fixnum)).to eq(nil)
      end
    end
  end
end

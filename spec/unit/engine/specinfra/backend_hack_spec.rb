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

describe Specinfra::Backend::Base do
  let(:instance) { double('Specinfra::Backend::Base') }

  context '.instance_set!' do
    let(:property) { {} }
    before do
      allow(described_class).to receive(:property).and_return(property)
      described_class.instance_variable_set(:@instance, nil)
    end
    after { described_class.instance_variable_set(:@instance, nil) }

    it 'sets internal @instance value' do
      described_class.instance_set(instance)
      expect(described_class.instance_variable_get(:@instance))
        .to eq instance
    end

    it 'resets the detected OS' do
      expect(property).to receive(:[]=).with(:os, nil)
      expect(property).to receive(:[]=).with(:host_inventory, nil)
      described_class.instance_set(instance)
    end

    context 'setting the same @instance' do
      before { described_class.instance_variable_set(:@instance, instance) }

      it 'does not set @instance value' do
        expect(described_class.instance_set(instance)).to be_nil
      end

      it 'does not reset detected OS' do
        expect(property).to_not receive(:[]=)
        described_class.instance_set(instance)
      end
    end
  end
end

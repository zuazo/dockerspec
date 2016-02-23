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

describe Dockerspec::Engine::Infrataster do
  let(:container_name) { 'purple_orange' }
  let(:ipaddress) { '11.22.33.44' }
  let(:options) { { 'opt1' => 'val1' } }
  let(:runner) do
    double(
      'Dockerspec::Runner::Base',
      container_name: container_name, ipaddress: ipaddress, options: options
    )
  end
  subject { described_class.new(runner) }

  context '.new' do
    it 'creates a new instance' do
      expect(subject).to be_a described_class
    end
  end

  context '#ready' do
    it 'defines infrataster server' do
      expect(Infrataster::Server).to receive(:define).with(
        container_name.to_sym,
        ipaddress,
        options
      )
      subject.ready
    end

    it 'defines infrataster server only once' do
      expect(Infrataster::Server).to receive(:define).once.with(
        container_name.to_sym,
        ipaddress,
        options
      )
      subject.ready
      subject.ready
      subject.ready
    end
  end
end

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

describe Dockerspec::Runner::Base do
  let(:engines) { double('Dockerspec::EngineList') }
  let(:container_name) { 'purple_orange' }
  let(:ipaddress) { '11.22.33.44' }
  let(:container_json) do
    {
      'Name' => container_name,
      'NetworkSettings' => {
        'IPAddress' => ipaddress
      }
    }
  end
  before do
    stub_runner_base(engines)
    allow(ObjectSpace).to receive(:define_finalizer)
  end

  context '.container' do
    it 'raises an error' do
      expect { subject.run }
        .to raise_error Dockerspec::RunnerError, /#container method must/
    end
  end

  context '#container_name' do
    let(:container) { double('Docker::Container', json: container_json) }
    before { allow(subject).to receive(:container).and_return(container) }

    it 'returns the container name' do
      expect(subject.container_name).to eq(container_name)
    end
  end

  context '#ipaddress' do
    let(:container) { double('Docker::Container', json: container_json) }
    before { allow(subject).to receive(:container).and_return(container) }

    it 'returns the container IP address' do
      expect(subject.ipaddress).to eq(ipaddress)
    end
  end
end

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

describe Dockerspec::Engine::Base do
  let(:runner) { double('Dockerspec::Runner::Base') }
  let(:ipaddress) { '11.22.33.44' }
  let(:container_name) { 'purple_orange' }
  subject { described_class.new(runner) }

  context '#container_name' do
    it 'gets the runner container name' do
      expect(runner).to receive(:container_name).with(no_args).once
        .and_return(container_name)
      expect(subject.send(:container_name)).to eq container_name
    end
  end

  context '#ipaddress' do
    it 'gets the runner IP address' do
      expect(runner).to receive(:ipaddress).with(no_args).once
        .and_return(ipaddress)
      expect(subject.send(:ipaddress)).to eq ipaddress
    end
  end
end

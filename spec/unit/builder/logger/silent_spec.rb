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
require 'stringio'

describe Dockerspec::Builder::Logger::Silent do
  let(:output) { StringIO.new }
  subject { described_class.new(output) }

  context '.new' do
    it 'creates an object' do
      expect(described_class.new).to be_a described_class
    end
  end

  context '#print_chunk' do
    it 'parses a valid JSON' do
      expect { subject.print_chunk('{"id": "0" }') }.not_to raise_error
    end

    it 'parses an invalid JSON' do
      expect { subject.print_chunk('{"wrong"}') }.not_to raise_error
    end

    it 'parses a ruby hash' do
      expect { subject.print_chunk('id' => '0') }.not_to raise_error
    end

    it 'does not output status' do
      subject.print_chunk('{"status": "downloading"}')
      expect(output.string).to eq ''
    end

    it 'does not output any stream' do
      subject.print_chunk('{"stream": "my stream"}')
      expect(output.string).to eq ''
    end
  end
end

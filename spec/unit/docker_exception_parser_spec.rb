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

describe Dockerspec::DockerExceptionParser do
  let(:error_msg) { DockerspecTests.error_example }
  let(:exception) { Exception.new(error_msg) }
  subject { described_class.new(exception) }

  context '.new' do
    it 'raises docker error' do
      expect { subject }.to raise_error Dockerspec::DockerError
    end

    it 'parses the build output' do
      expect { subject }.to raise_error(
        Dockerspec::DockerError, /OUTPUT: .*Step [0-9]/m
      )
    end

    it 'parses the build error' do
      expect { subject }.to raise_error(
        Dockerspec::DockerError,
        /ERROR: +The command .* returned a non-zero code:/
      )
    end

    context 'for unknown message format' do
      let(:error_msg) { { 'unknown' => 'format' }.to_json }

      it 'raises the same exception' do
        expect { subject }.to raise_error(exception)
      end
    end

    context 'for bad errorDetail message format' do
      let(:error_msg) { { 'errorDetail' => 'format' }.to_json }

      it 'raises the same exception' do
        expect { subject }.to raise_error(exception)
      end
    end

    context 'when there are json errors' do
      before do
        expect(JSON).to receive(:parse).and_raise(JSON::ParserError)
      end

      it 'raises the same exception' do
        expect { subject }.to raise_error(exception)
      end
    end
  end
end

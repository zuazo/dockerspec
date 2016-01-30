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

describe Dockerspec::Configuration do
  let(:engine) { Dockerspec::Engine::Base }
  let(:runner) { Dockerspec::Runner::Base }
  before do
    @instance_orig = Dockerspec::Configuration.instance_variable_get(:@instance)
    described_class.reset
  end
  after do
    Dockerspec::Configuration.instance_variable_set(:@instance, @instance_orig)
  end

  context '.add_engine & .engines' do
    it 'adds a engine' do
      described_class.add_engine(engine)
      expect(described_class.engines).to eq([engine])
    end

    it 'ignores duplicated engines' do
      described_class.add_engine(engine)
      described_class.add_engine(engine)
      expect(described_class.engines).to eq([engine])
    end
  end

  context '.docker_runner= & .docker_runner' do
    it 'returns Docker Runner by default' do
      described_class.reset
      expect(described_class.docker_runner).to eq(Dockerspec::Runner::Docker)
    end

    it 'sets the runner' do
      described_class.docker_runner = runner
      expect(described_class.docker_runner).to eq(runner)
    end
  end
end

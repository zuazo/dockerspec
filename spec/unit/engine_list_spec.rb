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

describe Dockerspec::EngineList do
  let(:runner) { double('Dockerspec::Runner::Base') }
  subject { described_class.new(runner) }
  let(:engine_class) { class_double('Dockerspec::Engine::Base') }
  let(:engine_classes) { [engine_class] }
  let(:engine) { double('Dockerspec::Engine::Base') }
  before do
    @instance_orig = Dockerspec::Configuration.instance_variable_get(:@instance)
    Dockerspec::Configuration.reset
    allow(Dockerspec::Configuration).to receive(:engines)
      .and_return(engine_classes)
    allow(engine_class).to receive(:new).and_return(engine)
  end
  after do
    Dockerspec::Configuration.instance_variable_set(:@instance, @instance_orig)
  end

  context '.new' do
    it 'reads engines from configuration' do
      expect(Dockerspec::Configuration).to receive(:engines).once
        .and_return(engine_classes)
      subject
    end

    it 'creates the engines' do
      expect(engine_class).to receive(:new).with(runner).once
        .and_return(engine)
      subject
    end

    context 'with no engines' do
      let(:engine_classes) { [] }

      it 'raises an error' do
        expect { subject }.to raise_error(/include the Test Engine/)
      end
    end
  end

  %w(setup save restore).each do |meth|
    context ".#{meth}" do
      let(:opts) { { key1: 'val1' } }

      it "calls engine .#{meth} method" do
        expect(engine).to receive(meth).once.with(no_args)
        subject.send(meth)
      end

      it 'passes the options' do
        expect(engine).to receive(meth).once.with(opts)
        subject.send(meth, opts)
      end
    end
  end
end

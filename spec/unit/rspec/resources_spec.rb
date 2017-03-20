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

# A class that includes the Dockerspec::RSpec::Resources module.
class TestDockerspecRSpecResources
  include Dockerspec::RSpec::Resources
end

describe Dockerspec::RSpec::Resources do
  subject { TestDockerspecRSpecResources.new }
  let(:image_id) { 'ade0b83dcb0b' }
  let(:container_name) { 'container_name1' }
  let(:builder) { double('Dockerspec::Builder', id: image_id) }
  let(:opts) { { opt1: 'val1' } }
  before do
    allow(Dockerspec::Builder).to receive(:new).and_return(builder)
    allow(builder).to receive(:build)
  end

  context '#docker_build' do
    it 'creates a new Builder' do
      expect(Dockerspec::Builder).to receive(:new).once.with(opts)
        .and_return(builder)
      allow(builder).to receive(:build).and_return(builder)
      subject.docker_build(opts)
    end

    it 'builds the Builder' do
      expect(builder).to receive(:build).once.with(no_args)
      subject.docker_build(opts)
    end

    it 'returns the build result' do
      expect(subject.docker_build(opts)).to eq builder
    end

    it 'sets `described_image`' do
      subject.docker_build(opts)
      expect(subject.described_image).to eq image_id
    end
  end

  context '#docker_run' do
    let(:runner_class) { Dockerspec::Runner::Docker }
    let(:runner) { double(runner_class.to_s, container_name: container_name) }
    let(:example) { 'example' }
    before do
      allow(Dockerspec::Configuration).to receive(:docker_runner)
        .and_return(runner_class)
      allow(runner_class).to receive(:new).and_return(runner)
      allow(runner).to receive(:run).and_return(runner)
      allow(runner).to receive(:restore_rspec_context)
    end

    it 'creates a Runner' do
      allow(runner_class)
        .to receive(:new).and_return(runner).once.with(example, opts)
      subject.docker_run(example, opts)
    end

    it 'runs the Runner' do
      expect(runner).to receive(:run).once
      subject.docker_run(example, opts)
    end

    it 'restores rspec context' do
      expect(runner).to receive(:restore_rspec_context).once
        .with(no_args)
      subject.docker_run(example, opts)
    end

    it 'returns the runner' do
      expect(subject.docker_run(example, opts)).to eq runner
    end

    it 'sets `described_image`' do
      subject.docker_run(example, opts)
      expect(subject.described_container).to eq container_name.to_sym
    end
  end

  context '#docker_compose' do
    let(:runner_class) { Dockerspec::Runner::Compose }
    let(:runner_desc) { 'my runner' }
    let(:runner) do
      double(
        runner_class.to_s, container_name: container_name, to_s: runner_desc
      )
    end
    let(:example) { 'example' }
    before do
      allow(Dockerspec::Configuration).to receive(:compose_runner)
        .and_return(runner_class)
      allow(runner_class).to receive(:new).and_return(runner)
      allow(runner).to receive(:run).and_return(runner)
    end

    it 'creates a Runner' do
      allow(runner_class)
        .to receive(:new).and_return(runner).once.with(example, opts)
      subject.docker_compose(example, opts)
    end

    it 'runs the Runner' do
      expect(runner).to receive(:run).once
      subject.docker_compose(example, opts)
    end

    it 'returns the runner description' do
      expect(subject.docker_compose(example, opts)).to eq runner_desc
    end
  end

  context '#its_container' do
    let(:container) { 'webapp' }
    let(:compose) do
      double('Dockerspec::Runner::Compose', container_name: container_name)
    end
    let(:its_container) { double('Dockerspec::RSpec::Resource::ItsContainer') }
    before do
      allow(Dockerspec::Runner::Compose).to receive(:current_instance)
        .and_return(compose)
      allow(Dockerspec::RSpec::Resources::ItsContainer).to receive(:new)
        .and_return(its_container)
      allow(its_container).to receive(:restore_rspec_context)
      allow(subject).to receive(:describe)
    end

    it 'reads the current Compose instance' do
      expect(Dockerspec::Runner::Compose).to receive(:current_instance).once
        .and_return(compose)
      subject.its_container(container)
    end

    it 'creates Its Container object' do
      expect(Dockerspec::RSpec::Resources::ItsContainer).to receive(:new)
        .with(container, compose).and_return(its_container)
      subject.its_container(container, opts)
    end

    it 'restores rspec context' do
      expect(its_container).to receive(:restore_rspec_context).once
        .with(opts)
      subject.its_container(container, opts)
    end

    it 'creates a RSpec example group' do
      expect(subject).to receive(:describe).once.with(its_container)
      subject.its_container(container)
    end

    it 'raises an error if no docker_compose instance is found' do
      allow(Dockerspec::Runner::Compose).to receive(:current_instance)
        .and_return(nil)
      expect { subject.its_container(container) }
        .to raise_error(
          Dockerspec::ItsContainerError, /used with.*`docker_compose`/
        )
    end

    it 'sets `described_image`' do
      subject.its_container(container)
      expect(subject.described_container).to eq container_name.to_sym
    end
  end
end

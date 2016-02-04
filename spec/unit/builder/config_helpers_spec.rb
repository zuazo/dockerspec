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

class TestDockerspecBuilderHelpers
  include Dockerspec::Builder::ConfigHelpers

  def initialize(image)
    @image = image
  end
end

describe Dockerspec::Builder::ConfigHelpers do
  let(:json_config) { {} }
  let(:json) { { 'Config' => json_config } }
  let(:image) { double('Docker::Image', json: json) }
  subject { TestDockerspecBuilderHelpers.new(image) }

  context '#image_config' do
    it 'returns JSON configuration' do
      expect(subject.image_config).to equal(json_config)
    end
  end

  context '#size' do
    it 'returns image size' do
      json['VirtualSize'] = 999
      expect(subject.size).to eq 999
    end
  end

  context '#architecture' do
    it 'returns architecture' do
      json['Architecture'] = 'amd64'
      expect(subject.architecture).to eq 'amd64'
    end
  end

  context '#arch' do
    it 'returns architecture' do
      json['Architecture'] = 'amd64'
      expect(subject.arch).to eq 'amd64'
    end
  end

  context '#os' do
    it 'returns OS' do
      json['Os'] = 'linux'
      expect(subject.os).to eq 'linux'
    end
  end

  context '#maintainer' do
    it 'returns author' do
      json['Author'] = 'John Doe'
      expect(subject.maintainer).to eq 'John Doe'
    end
  end

  context '#cmd' do
    it 'returns CMD' do
      json_config['Cmd'] = ['/bin/sh']
      expect(subject.cmd).to eq ['/bin/sh']
    end
  end

  context '#labels' do
    it 'returns LABELs' do
      json_config['Labels'] = { 'testing' => 'docker' }
      expect(subject.labels).to eq('testing' => 'docker')
    end
  end

  context '#label' do
    it 'returns the first LABEL' do
      json_config['Labels'] = { 'testing' => 'docker', 'serverspec' => 'true' }
      expect(subject.label).to eq 'testing=docker'
    end
  end

  context '#exposes' do
    it 'returns EXPOSEs' do
      json_config['ExposedPorts'] = { '80/tcp' => {}, '443/tcp' => {} }
      expect(subject.exposes).to eq %w(80 443)
    end
  end

  context '#expose' do
    it 'returns the first EXPOSE' do
      json_config['ExposedPorts'] = { '80/tcp' => {}, '443/tcp' => {} }
      expect(subject.expose).to eq '80'
    end
  end

  context '#envs' do
    it 'returns ENVs' do
      json_config['Env'] = %w(
        PATH=/usr/sbin:/usr/bin:/sbin:/bin
        container=docker
      )
      expect(subject.envs).to eq(
        'PATH' => '/usr/sbin:/usr/bin:/sbin:/bin',
        'container' => 'docker'
      )
    end
  end

  context '#env' do
    it 'returns ENVs' do
      json_config['Env'] = %w(
        PATH=/usr/sbin:/usr/bin:/sbin:/bin
        container=docker
      )
      expect(subject.env).to eq(
        'PATH' => '/usr/sbin:/usr/bin:/sbin:/bin',
        'container' => 'docker'
      )
    end
  end

  context '#entrypoing' do
    it 'returns ENTRYPOINT' do
      json_config['Entrypoint'] = ['sleep']
      expect(subject.entrypoint).to eq ['sleep']
    end
  end

  context '#volumes' do
    it 'returns VOLUMEs' do
      json_config['Volumes'] = { '/var/tmp' => {}, '/tmp' => {} }
      expect(subject.volumes).to eq %w(/var/tmp /tmp)
    end
  end

  context '#volume' do
    it 'returns the first VOLUME' do
      json_config['Volumes'] = { '/var/tmp' => {}, '/tmp' => {} }
      expect(subject.volume).to eq '/var/tmp'
    end
  end

  context '#user' do
    it 'returns USER' do
      json_config['User'] = 'nobody'
      expect(subject.user).to eq 'nobody'
    end
  end

  context '#workdir' do
    it 'returns WORKDIR' do
      json_config['WorkingDir'] = '/tmp'
      expect(subject.workdir).to eq '/tmp'
    end
  end

  context '#onbuilds' do
    it 'returns ONBUILDs' do
      json_config['OnBuild'] = ['RUN echo onbuild']
      expect(subject.onbuilds).to eq ['RUN echo onbuild']
    end
  end

  context '#onbuild' do
    it 'returns the first ONBUILD' do
      json_config['OnBuild'] = ['RUN echo onbuild', 'RUN sleep 2']
      expect(subject.onbuild).to eq 'RUN echo onbuild'
    end
  end

  context '#stopsignal' do
    it 'returns STOPSIGNAL' do
      json_config['StopSignal'] = 'SIGTERM'
      expect(subject.stopsignal).to eq 'SIGTERM'
    end
  end
end

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

module DockerspecTests
  def self.serverspec_engine
    Dockerspec::Configuration.docker_runner =
      Dockerspec::Runner::Serverspec::Docker
    Dockerspec::Configuration.compose_runner =
      Dockerspec::Runner::Serverspec::Compose
    Dockerspec::Configuration.engines.replace([Dockerspec::Engine::Specinfra])
  end

  def self.infrataster_engine
    Dockerspec::Configuration.docker_runner = Dockerspec::Runner::Docker
    Dockerspec::Configuration.compose_runner = Dockerspec::Runner::Compose
    Dockerspec::Configuration.engines.replace([Dockerspec::Engine::Infrataster])
  end

  def self.default_engines
    serverspec_engine
    Dockerspec::Configuration.engines.push(Dockerspec::Engine::Infrataster)
  end

  def self.engine(name)
    send("#{name}_engine")
  end

  def self.all_engines_list
    %i(serverspec infrataster)
  end

  def self.init_engines
    unless all_engines_list.any? { |x| ENV.key?(x.to_s.upcase) }
      default_engines
      return
    end
    all_engines_list.each do |name|
      next if ENV[name.to_s.upcase].to_s != 'true'
      engine(name)
    end
  end

  def self.data_dir
    File.join(File.dirname(__FILE__), '..', 'data')
  end

  def self.data_file(file)
    File.join(DockerspecTests.data_dir, file)
  end

  def self.error_example
    file = File.join(DockerspecTests.data_dir, 'error_example.log')
    IO.read(file)
  end

  def stub_runner_base(engines)
    allow(Dockerspec::EngineList).to receive(:new).and_return(engines)
    %i(before_running when_running when_container_ready).each do |m|
      allow(engines).to receive(m)
    end
    allow_any_instance_of(Dockerspec::Runner::Base).to receive(:sleep)
    allow(ObjectSpace).to receive(:define_finalizer)
  end

  def stub_engines(engines)
    allow(engines).to receive(:before_running)
  end

  def stub_dockercompose(compose)
    allow(DockerCompose).to receive(:load).and_return(compose)
    allow(compose).to receive(:start)
    allow(compose).to receive(:stop)
    allow(compose).to receive(:delete)
  end

  def stub_runner_compose(file, compose, engines)
    stub_runner_base(engines)
    stub_dockercompose(compose)
    stub_engines(engines)
    allow(Dockerspec::Runner::Compose).to receive(:current_instance=)
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with(file).and_return(false)
  end
end

def serverspec_tests
  unless Dockerspec::Configuration.engines
                                  .include?(Dockerspec::Engine::Specinfra)
    return
  end
  yield
end

def infrataster_tests
  unless Dockerspec::Configuration.engines
                                  .include?(Dockerspec::Engine::Infrataster)
    return
  end
  yield
end

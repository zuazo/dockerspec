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
    allow(engines).to receive(:setup)
    allow(engines).to receive(:save)
    allow(ObjectSpace).to receive(:define_finalizer)
  end

  def stub_engines(engines)
    allow(engines).to receive(:setup)
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

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

path = File.join(File.dirname(__FILE__), '..', '..', 'data')

context docker_build(path: path, tag: 'from_dir_spec') do
  it { should have_maintainer 'John Doe "john.doe@example.com"' }
  it { should have_maintainer(/John Doe/) }
  it { should have_cmd %w(2 2000) }
  it { should have_label 'description' }
  it { should have_label 'description' => 'My Container' }
  it { should have_expose '80' }
  it { should have_expose(/80$/) }
  it { should have_env 'container' }
  it { should have_env 'container' => 'docker' }
  it { should have_env 'CRACKER' => 'RANDOM;PATH=/tmp/bin:/sbin:/bin' }
  it { should have_entrypoint ['sleep'] }
  it { should have_volume '/volume1' }
  it { should have_volume %r{/vol.*2} }
  it { should have_user 'nobody' }
  it { should have_workdir '/opt' }
  it { should have_workdir %r{^/op} }
  it { should have_onbuild 'RUN echo onbuild' }

  its(:maintainer) { should eq 'John Doe "john.doe@example.com"' }
  its(:cmd) { should eq %w(2 2000) }
  its(:labels) { should include 'description' }
  its(:labels) { should include 'description' => 'My Container' }
  its(:exposes) { should include '80' }
  its(:env) { should include 'container' }
  its(:env) { should include 'container' => 'docker' }
  its(:env) { should include 'CRACKER' => 'RANDOM;PATH=/tmp/bin:/sbin:/bin' }
  its(:entrypoint) { should eq ['sleep'] }
  its(:volumes) { should include '/volume1' }
  its(:user) { should eq 'nobody' }
  its(:workdir) { should eq '/opt' }
  its(:onbuilds) { should include 'RUN echo onbuild' }

  its(:size) { should be < 20 * 2**20 } # 20M
  its(:arch) { should eq 'amd64' }
  its(:os) { should eq 'linux' }

  context docker_run('from_dir_spec') do
    context file('/tmp/file_example1') do
      it { should be_file }
    end

    context file('/tmp/file_example2') do
      it { should be_file }
    end

    describe package('alpine-base') do
      it { should be_installed }
    end

    describe process('sleep ') do
      it { should be_running }
      its(:args) { should match(/2000/) }
    end

    it 'is a Linux distro' do
      expect(command('uname').stdout).to include 'Linux'
    end
  end
end

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

describe Dockerspec::Helper::Docker do
  let(:docker_info) { {} }
  before { allow(::Docker).to receive(:info).and_return(docker_info) }

  context '.lxc_execution_driver?' do
    subject { described_class.lxc_execution_driver? }

    context 'with native driver' do
      before { docker_info['ExecutionDriver'] = 'native-0.2' }
      it { should be false }
    end

    context 'with LXC driver' do
      before { docker_info['ExecutionDriver'] = 'lxc-1.0.6' }
      it { should be true }
    end
  end
end

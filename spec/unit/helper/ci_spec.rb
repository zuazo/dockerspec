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

class TestDockerHelperCI
  include Dockerspec::Helper::CI
end

describe Dockerspec::Helper::CI do
  let(:env_vars) { %w(CI TRAVIS CIRCLECI) }
  before { @env_orig = env_vars.each_with_object({}) { |k, m| m[k] = ENV[k] } }
  after { @env_orig.each { |k, v| ENV[k] = v } }

  context '#ci?' do
    subject { TestDockerHelperCI.new.ci? }

    context 'on a CI' do
      before { ENV['CI'] = 'true' }
      it { should be true }
    end

    context 'outside a CI' do
      before { ENV.delete('CI') }
      it { should be false }
    end
  end

  context '#travis_ci?' do
    subject { TestDockerHelperCI.new.travis_ci? }

    context 'on Travis CI' do
      before { ENV['TRAVIS'] = 'true' }
      it { should be true }
    end

    context 'outside Travis CI' do
      before { ENV.delete('TRAVIS') }
      it { should be false }
    end
  end

  context '#circle_ci?' do
    subject { TestDockerHelperCI.new.circle_ci? }

    context 'on Circle CI' do
      before { ENV['CIRCLECI'] = 'true' }
      it { should be true }
    end

    context 'outside Cicle CI' do
      before { ENV.delete('CIRCLECI') }
      it { should be false }
    end
  end
end

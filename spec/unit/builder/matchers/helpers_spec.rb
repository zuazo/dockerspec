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

class TestDockerspecBuilderMatcherHelpers
  include Dockerspec::Builder::Matchers::MatcherHelpers
end

describe Dockerspec::Builder::Matchers::MatcherHelpers do
  subject { TestDockerspecBuilderMatcherHelpers.new }

  context '#sub_hash?' do
    it 'returns true when passing a subhash with a single key' do
      expect(subject.sub_hash?(
               { a: 1, b: 2, c: 3 },
               a: 1
      )).to eq true
    end

    it 'returns true when passing a subhash with a multiple keys' do
      expect(subject.sub_hash?(
               { a: 1, b: 2, c: 3 },
               b: 2, c: 3
      )).to eq true
    end

    it 'returns false for different hashes' do
      expect(subject.sub_hash?(
               { a: 1, b: 2, c: 3 },
               a: 2, b: 2
      )).to eq false
    end

    it 'returns true when passing regexps' do
      expect(subject.sub_hash?(
               { a: 'Hello', b: 'World' },
               a: /H/, b: /Wor/
      )).to eq true
    end

    it 'returns false when the regexps does not match' do
      expect(subject.sub_hash?(
               { a: 'Hello', b: 'World' },
               b: /Bye/
      )).to eq false
    end
  end # context #sub_hash?

  context '#maybe_json?' do
    it 'returns true for the same arrays' do
      expect(subject.maybe_json?(
               [0, 1, 3, 4],
               [0, 1, 3, 4]
      )).to eq true
    end

    it 'returns true for the same arrays' do
      expect(subject.maybe_json?(
               [0, 1, 3, 4],
               [0, 1, 3, 5]
      )).to eq false
    end

    it 'returns true when passing the correct string' do
      expect(subject.maybe_json?(
               %w(hello world),
               'hello world'
      )).to eq true
    end

    it 'returns false when passing wrong strings' do
      expect(subject.maybe_json?(
               %w(hello world),
               'bye'
      )).to eq false
    end

    it 'returns true when passing regexps' do
      expect(subject.maybe_json?(
               %w(hello world),
               /llo wor/
      )).to eq true
    end

    it 'returns false when passing wrong regexps' do
      expect(subject.maybe_json?(
               %w(hello world),
               /bye/
      )).to eq false
    end
  end
end

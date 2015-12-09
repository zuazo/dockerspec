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

require 'rspec/expectations'

module Dockerspec
  class Builder
    module Matchers
      #
      # Some helpers methods for the Docker build RSpec matchers.
      #
      module MatcherHelpers
        #
        # Checks whether a hash is a subhash of another.
        #
        # @example
        #   self.sub_hash?({ a: 1, b: 2, c: 3 }, { a: 1 }) #=> true
        #   self.sub_hash?({ a: 1, b: 2, c: 3 }, { b: 2, c: 3 }) #=> true
        #   self.sub_hash?({ a: 1, b: 2, c: 3 }, { a: 2, b: 2 }) #=> false
        #   self.sub_hash?({ a: 'Hello', b: 'World' }, { a: /H/, b: /Wor/ }
        #     #=> true
        #   self.sub_hash?({ a: 'Hello', b: 'World' }, { a: /Bye/ } #=> false
        #
        # @param hash [Hash] The hash in which to search.
        # @param sub_hash [Hash] The subhash.
        #
        # @return [Boolean] Whether it's a subhash.
        #
        # @api public
        #
        def sub_hash?(hash, sub_hash)
          sub_hash.all? do |sub_hash_key, sub_hash_value|
            next false unless hash.key?(sub_hash_key)
            if sub_hash_value.respond_to?(:match)
              !sub_hash_value.match(hash[sub_hash_key]).nil?
            else
              sub_hash_value == hash[sub_hash_key]
            end
          end
        end

        #
        # A matcher to check JSON values like `CMD` and `ENTRYPOINT`.
        #
        # The expected value can be in JSON (a Ruby array) or in String format
        # just like in the *Dockerfile*.
        #
        # The real (*got*) value will always be in array format.
        #
        # @example
        #   self.maybe_json?([0, 1, 3, 4], [0, 1, 3, 4]) #=> true
        #   self.maybe_json?([0, 1, 3, 4], [0, 1, 3, 5]) #=> false
        #   self.maybe_json?(%w(hello world), 'hello world') #=> true
        #   self.maybe_json?(%w(hello world), 'bye') #=> false
        #   self.maybe_json?(%w(hello world), /llo wor/) #=> true
        #   self.maybe_json?(%w(hello world), /bye/) #=> false
        #
        # @param got [Array] The received value.
        # @param expected [Array, String, Regexp] The expected value.
        #
        # @return [Boolean] Whether the expected value matches the real value.
        #
        # @api public
        #
        def maybe_json?(got, expected)
          return expected == got if expected.is_a?(Array)
          !expected.match(got.join(' ')).nil?
        end
      end
    end
  end
end

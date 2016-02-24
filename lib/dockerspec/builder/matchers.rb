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
require 'dockerspec/builder/matchers/helpers'

module Dockerspec
  class Builder
    #
    # Creates some RSpec *have_* matchers for Docker builds.
    #
    module Matchers
      extend RSpec::Matchers::DSL

      #
      # The matcher list with the type it belongs to.
      #
      # This is based on [the official *Dockerfile* parser code]
      # (https://github.com/docker/docker/tree/master/builder/dockerfile/parser)
      # .
      #
      # The possible types are:
      #
      # - `:string`: A simple string. For example the `MAINTAINER` instruction.
      # - `:json`: Can in JSON (a Ruby array) or in string format. For example
      #     the `CMD` or the `ENTRYPOINT` instructions.
      # - `:hash`: A hash. For example the `ENV` or the `LABEL` instructions.
      # - `:array`: A array of values. For example the `EXPOSE` instruction.
      #
      PREDICATE_TYPES = {
        maintainer: :string,
        cmd: :json,
        label: :hash,
        expose: :array,
        env: :hash,
        entrypoint: :json,
        volume: :array,
        user: :string,
        workdir: :string,
        onbuild: :array,
        stopsignal: :string
      }

      PREDICATE_TYPES.each do |name, type|
        matcher_name = "have_#{name}".to_sym

        case type
        when :string
          matcher matcher_name do |expected|
            match { |actual| !expected.match(actual.send(name)).nil? }

            failure_message do |actual|
              "expected `#{name.upcase}` to match `#{expected.inspect}`, "\
                "got `#{actual.send(name)}`"
            end

            failure_message_when_negated do |actual|
              "expected `#{name.upcase}` not to match `#{expected.inspect}`, "\
                "got `#{actual.send(name)}`"
            end
          end
        when :json
          matcher matcher_name do |expected|
            include MatcherHelpers

            match { |actual| maybe_json?(actual.send(name), expected) }

            failure_message do |actual|
              "expected `#{name.upcase}` to be `#{expected.inspect}`, "\
                "got `#{actual.send(name)}`"
            end

            failure_message_when_negated do |actual|
              "expected `#{name.upcase}` not to be `#{expected.inspect}`, "\
                "got `#{actual.send(name)}`"
            end
          end
        when :array
          matcher matcher_name do |expected|
            # Allow ports to be passed as integer:
            if matcher_name == :have_expose && expected.is_a?(Numeric)
              expected = expected.to_s
            end

            match { |actual| !actual.send("#{name}s").grep(expected).empty? }

            failure_message do |actual|
              "expected `#{name.upcase}` to include `#{expected.inspect}`, "\
                "got `#{actual.send("#{name}s").inspect}`"
            end

            failure_message_when_negated do |actual|
              "expected `#{name.upcase}` not to include "\
              "`#{expected.inspect}`, got `#{actual.send("#{name}s").inspect}`"
            end
          end
        when :hash
          matcher matcher_name do |expected|
            include MatcherHelpers

            match do |actual|
              actual = actual.send("#{name}s")
              break sub_hash?(actual, expected) if expected.is_a?(Hash)
              !actual.keys.grep(expected).empty?
            end

            failure_message do |actual|
              "expected `#{name.upcase}` to contain `#{expected.inspect}`, "\
                "got `#{actual.send("#{name}s")}`"
            end

            failure_message_when_negated do |actual|
              "expected `#{name.upcase}` not to contain "\
              "`#{expected.inspect}`, got `#{actual.send("#{name}s")}`"
            end
          end
        end
      end
    end
  end
end

RSpec.configure { |c| c.include(Dockerspec::Builder::Matchers) }

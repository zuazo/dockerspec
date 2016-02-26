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
      }.freeze

      PREDICATE_TYPES.each do |name, type|
        matcher_name = "have_#{name}".to_sym

        value_method = name
        verb = 'be'
        matcher matcher_name do |expected|
          case type
          when :string
            verb = 'match'

            match { |actual| !expected.match(actual.send(value_method)).nil? }
          when :json
            verb = 'be'

            include MatcherHelpers

            match { |actual| maybe_json?(actual.send(value_method), expected) }
          when :array
            value_method = "#{name}s"
            verb = 'include'

            # Allow ports to be passed as integer:
            if matcher_name == :have_expose && expected.is_a?(Numeric)
              expected = expected.to_s
            end

            match { |actual| !actual.send(value_method).grep(expected).empty? }
          when :hash
            value_method = "#{name}s"
            verb = 'contain'

            include MatcherHelpers

            match do |actual|
              actual = actual.send(value_method)
              break sub_hash?(actual, expected) if expected.is_a?(Hash)
              !actual.keys.grep(expected).empty?
            end
          end # case type

          failure_message do |actual|
            "expected `#{name.upcase}` to #{verb} `#{expected.inspect}`, "\
              "got `#{actual.send(value_method).inspect}`"
          end

          failure_message_when_negated do |actual|
            "expected `#{name.upcase}` not to #{verb} "\
            "`#{expected.inspect}`, got `#{actual.send(value_method).inspect}`"
          end
        end # matcher
      end # PREDICATE_TYPES each
    end
  end
end

RSpec.configure { |c| c.include(Dockerspec::Builder::Matchers) }

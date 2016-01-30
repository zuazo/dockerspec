# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2016 Xabier de Zuazo
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

require 'dockerspec/engine/base'
require 'dockerspec/engine/specinfra/backend'

module Dockerspec
  module Engine
    #
    # The Specinfra (Serverspec) testing engine implementation.
    #
    class Specinfra < Base
      #
      # Constructs a testing engine to use Specinfra (used by Serverspec).
      #
      # @param runner [Dockerspec::Runner::Base] The class that is being used
      #   to run the Docker Containers.
      #
      # @param opts [Hash] Configuration options used by the engine.
      #
      # @return [Dockerspec::Engine::Specinfra] The engine.
      #
      # @api public
      #
      def initialize(runner, opts)
        super
        @backend = nil
      end

      #
      # Restores the Specinfra backend instance to point to this object's
      # container.
      #
      # This is used to avoid Serverspec running against the last started
      # container if you are testing multiple containers at the same time.
      #
      # @return void
      #
      def restore
        @backend.restore
      end

      #
      # Sets the Specinfra configuration.
      #
      # - Resets the internal Specinfra backend reference.
      # - Sets the `:family`.
      #
      # @return void
      #
      # @api private
      #
      def setup
        @backend = Backend.new(@runner.backend_name)
        @backend.reset
        return unless @options.key?(:family)
        ::Specinfra.configuration.os(family: @options[:family])
      end

      #
      # Saves the Specinfra backend internal reference internally to restore
      # it later.
      #
      # @return void
      #
      # @api private
      #
      def save
        @backend.save
      end
    end
  end
end

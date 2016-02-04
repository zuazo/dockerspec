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
      # @return [Dockerspec::Engine::Specinfra] The engine.
      #
      # @api public
      #
      def initialize(runner)
        super
        @backend = nil
      end

      #
      # Sets the Specinfra configuration.
      #
      # - Resets the internal Specinfra backend reference.
      # - Sets the chosen container name with Docker Compose.
      # - Sets the `:family`.
      #
      # @return void
      #
      # @api private
      #
      def setup
        if @backend.nil?
          @backend = Backend.new(backend_name)
          @backend.reset
        end
        setup_container_name
        setup_family
      end

      #
      # Saves the Specinfra backend reference internally to restore it later.
      #
      # @return void
      #
      # @api private
      #
      def save
        @backend.save
      end

      #
      # Restores the Specinfra backend instance to point to this object's
      # container.
      #
      # This is used to avoid Serverspec running against the previous started
      # container if you are testing multiple containers at the same time.
      #
      # @return void
      #
      # @api private
      #
      def restore
        @backend.restore
        setup_container_name
        setup_family
      end

      protected

      #
      # Gets the Specinfra backend name from the runner.
      #
      # @return [String] The backend name.
      #
      # @api private
      #
      def backend_name
        @runner.backend_name
      end

      #
      # Sets up the OS family.
      #
      # @return void
      #
      # @api private
      #
      def setup_family
        return unless options.key?(:family)
        ::Specinfra.configuration.os(family: options[:family])
      end

      #
      # Selects the container to test.
      #
      # @return void
      #
      # @api private
      #
      def setup_container_name
        return unless options.key?(:container)
        @backend.restore_container(options[:container])
      end
    end
  end
end

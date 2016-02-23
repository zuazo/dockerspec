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

require 'infrataster/rspec'
require 'dockerspec/engine/base'
require 'securerandom'

module Dockerspec
  module Engine
    #
    # The Infrataster testing engine implementation.
    #
    class Infrataster < Base
      include ::Infrataster::Helpers::ResourceHelper

      #
      # Constructs a testing engine to use Infrataster.
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
        @definitions = {}
      end

      #
      # Sets up Infrataster.
      #
      # @return void
      #
      # @raise [Dockerspec::RunnerError] When the `#container` method is no
      #   implemented in the subclass or cannot select the container to test.
      #
      # @api public
      #
      def ready
        define_server
      end

      protected

      #
      # Defines the Infrataster server to test.
      #
      # It calls {Infrataster::Server.define} reading the internal IP address
      # from the Docker metadata.
      #
      # @return void
      #
      # @raise [Dockerspec::RunnerError] When the `#container` method is no
      #   implemented in the subclass or cannot select the container to test.
      #
      # @api private
      #
      def define_server
        return if @definitions.key?(container_name)
        ::Infrataster::Server.define(
          container_name.to_sym,
          ipaddress,
          options
        )
        @definitions[container_name] = ipaddress
      end
    end
  end
end

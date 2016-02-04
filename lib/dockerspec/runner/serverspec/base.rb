# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015-2016 Xabier de Zuazo
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

require 'serverspec'
require 'dockerspec/runner/docker'
require 'dockerspec/helper/docker'
require 'dockerspec/docker_exception_parser'
require 'dockerspec/runner/serverspec/rspec'

#
# Silence error: No backend type is specified. Fall back to :exec type.
#
Specinfra.configuration.backend(:base)

module Dockerspec
  module Runner
    #
    # Contains the classes used to start docker containers using Serverspec.
    #
    module Serverspec
      #
      # Base class to be included by Serverspec runners.
      #
      # @example
      #   module Dockerspec
      #     module Runner
      #       module Serverspec
      #         class MyRunner
      #           include Base
      #         end
      #       end
      #     end
      #   end
      #
      module Base
        #
        # The Specinfra backend name to use.
        #
        # @return [Symbol] The backend name.
        #
        attr_reader :backend_name

        #
        # Stops and deletes the Docker Container.
        #
        # Actually does nothing. Do no delete anything, lets Specinfra do that.
        #
        # @return void
        #
        # @api public
        #
        def finalize
          # Do not stop the container
        end

        #
        # Generates a description of the object.
        #
        # @example Running Against a Container Image Tag
        #   self.description #=> "Serverspec on tag: \"debian\""
        #
        # @example Running Against a Running Container ID
        #   self.description #=> "Serverspec on id: \"92cc98ab560a\""
        #
        # @return [String] The object description.
        #
        # @api private
        #
        def to_s
          description('Serverspec on')
        end

        protected

        #
        # Gets the default options configured using `RSpec.configuration`.
        #
        # @example
        #   self.rspec_options #=> { :family => :debian }
        #
        # @return [Hash] The configuration options.
        #
        # @api private
        #
        def rspec_options
          config = ::RSpec.configuration
          super.tap do |opts|
            opts[:family] = config.family if config.family?
          end
        end

        #
        # Generates the correct Specinfra backend name to use from a name.
        #
        # @example
        #   self.generate_docker_backend_name(:docker, :docker) #=> :docker
        #   self.generate_docker_backend_name(:lxc, :docker) #=> :docker_lxc
        #   self.generate_docker_backend_name(:docker_lxc, :docker)
        #     #=> :docker_lxc
        #   self.generate_docker_backend_name(:native, :docker) #=> :docker
        #
        # @param name [String, Symbol] The backend short (without the `docker`
        #   prefix) or long name.
        # @param prefix [Symbol, String] The prefix to use: `:docker` or
        #   `:docker_compose`.
        #
        # @return [Symbol] The backend name.
        #
        # @api private
        #
        def generate_docker_backend_name(name, prefix)
          return name.to_s.to_sym if name.to_s.start_with?(prefix)
          return prefix.to_sym if name.to_s.to_sym == :native
          "#{prefix}_#{name}".to_sym
        end

        #
        # Calculates and saves the correct docker Specinfra backend to use on
        # the system.
        #
        # Returns the LXC driver instead of the native driver when required.
        #
        # Reads the driver from the configuration options if set.
        #
        # @example Docker with Native Execution Driver
        #   self.calculate_docker_backend_name(:docker) #=> :docker
        #
        # @example Docker with LXC Execution Driver
        #   self.calculate_docker_backend_name(:docker) #=> :docker_lxc
        #
        # @example Compose with LXC Execution Driver
        #   self.calculate_docker_backend_name(:compose) #=> :docker_compose_lxc
        #
        # @param prefix [Symbol, String] The prefix to use: `:docker` or
        #   `:docker_compose`.
        #
        # @return [Symbol] The backend name.
        #
        # @api private
        #
        def calculate_docker_backend_name(prefix)
          @backend_name =
            if options.key?(:backend)
              generate_docker_backend_name(options[:backend], prefix)
            elsif Helper::Docker.lxc_execution_driver?
              "#{prefix}_lxc".to_sym
            else
              prefix.to_sym
            end
        end

        #
        # Starts the Docker container.
        #
        # @return void
        #
        # @raise [Dockerspec::DockerError] For underlaying docker errors.
        #
        # @api private
        #
        def run_container
          Specinfra.configuration.backend(@backend_name)
        rescue ::Docker::Error::DockerError => e
          DockerExceptionParser.new(e)
        end
      end
    end
  end
end

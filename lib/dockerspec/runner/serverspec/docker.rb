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
require 'specinfra/backend/docker_lxc'
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
      # Runs a Docker container using [Serverspec](http://serverspec.org/).
      #
      class Docker < Dockerspec::Runner::Docker
        attr_reader :backend_name

        #
        # Constructs a Docker Serverspec runner class to run Docker images.
        #
        # @example From a Docker Container Image Tag
        #   Dockerspec::Runner::Serverspec::Docker.new('myapp')
        #     #=> #<Dockerspec::Runner::Serverspec::Docker:0x0124>
        #
        # @example From a Docker Container Image Tag Using Hash Format
        #   Dockerspec::Runner::Serverspec::Docker.new(tag: 'myapp')
        #     #=> #<Dockerspec::Runner::Serverspec::Docker:0x0124>
        #
        # @example From a Running Docker Container ID
        #   Dockerspec::Runner::Serverspec::Docker.new(id: 'c51f86c28340')
        #     #=> #<Dockerspec::Runner::Serverspec::Docker:0x0125>
        #
        # @param opts [String, Hash] The `:tag` or a list of options.
        #
        # @option opts [String] :tag The Docker image tag name to run.
        # @option opts [String] :id The Docker container ID to use instead of
        #   starting a new container.
        # @option opts [Boolean] :rm (calculated) Whether to remove the Docker
        #   container afterwards.
        # @option opts [String] :path The environment `PATH` value of the
        #   container.
        # @option opts [Hash, Array] :env Some `ENV` instructions to add to the
        #   container.
        # @option opts [Symbol] :family (calculated) The OS family.
        #   It's automatically detected by default, but can be used to
        #   **speed up the tests**. Some possible values:
        #   `:alpine`, `:arch`, `:coreos`, `:debian`, `:gentoo`, `:nixos`,
        #   `:plamo`, `:poky`, `:redhat`, `:suse`.
        # @option opts [Symbol] :backend (calculated) Docker backend to use:
        #   `:docker`, `:lxc`.
        #
        # @return [Dockerspec::Runner::Serverspec::Docker] Runner object.
        #
        # @api public
        #
        def initialize(*opts)
          super
          @backend_name = calculate_docker_backend_name
        end

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
        # Sets the Specinfra configuration.
        #
        # It only sets the `:docker_image` or `:docker_container`.
        #
        # @return void
        #
        # @api private
        #
        def setup
          if id.nil?
            Specinfra.configuration.docker_image(image_id)
          else
            Specinfra.configuration.docker_container(id)
          end
        end

        #
        # Generates the correct Specinfra backend name to use from a name.
        #
        # @example
        #   self.generate_docker_backend_name(:docker) #=> :docker
        #   self.generate_docker_backend_name(:lxc) #=> :docker_lxc
        #   self.generate_docker_backend_name(:docker_lxc) #=> :docker_lxc
        #   self.generate_docker_backend_name(:native) #=> :docker
        #
        # @param name [String, Symbol] The backend short (without the `docker`
        #   prefix) or long name.
        #
        # @return [Symbol] The backend name.
        #
        # @api private
        #
        def generate_docker_backend_name(name)
          return name.to_s.to_sym unless name.to_s.match(/^docker/).nil?
          return :docker if name.to_s.to_sym == :native
          "docker_#{name}".to_sym
        end

        #
        # Calculates the correct docker Specinfra backend to use on the system.
        #
        # Returns the LXC driver instead of the native driver when required.
        #
        # Reads the driver from the configuration options if set.
        #
        # @example Docker with Native Execution Driver
        #   self.calculate_docker_backend_name #=> :docker
        #
        # @example Docker with LXC Execution Driver
        #   self.calculate_docker_backend_name #=> :docker_lxc
        #
        # @return [Symbol] The backend name.
        #
        # @api private
        #
        def calculate_docker_backend_name
          if @options.key?(:backend)
            generate_docker_backend_name(@options[:backend])
          elsif Helper::Docker.lxc_execution_driver?
            :docker_lxc
          else
            :docker
          end
        end

        #
        # Starts the Docker container.
        #
        # @return void
        #
        # @api private
        #
        def run_container
          setup
          Specinfra.configuration.backend(@backend_name)
        rescue ::Docker::Error::DockerError => e
          DockerExceptionParser.new(e)
        end
      end
    end
  end
end

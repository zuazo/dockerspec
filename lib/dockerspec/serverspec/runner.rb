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

require 'serverspec'
require 'specinfra/backend/docker_lxc'
require 'dockerspec/runner'
require 'dockerspec/serverspec/specinfra_backend'
require 'dockerspec/helper/rspec_example_helpers'
require 'dockerspec/helper/docker'

#
# Silence error: No backend type is specified. Fall back to :exec type.
#
Specinfra.configuration.backend(:base)

module Dockerspec
  #
  # Contains the classes related to running Serverspec in docker containers.
  #
  module Serverspec
    #
    # Runs a Docker container using [Serverspec](http://serverspec.org/).
    #
    class Runner < Dockerspec::Runner
      #
      # Constructs a Docker Serverspec runner class to run Docker images.
      #
      # @example From a Docker Container Image Tag
      #   Dockerspec::Serverspec::Runner.new('myapp')
      #     #=> #<Dockerspec::Serverspec::Runner:0x0124>
      #
      # @example From a Docker Container Image Tag Using Hash Format
      #   Dockerspec::Serverspec::Runner.new(tag: 'myapp')
      #     #=> #<Dockerspec::Serverspec::Runner:0x0124>
      #
      # @example From a Running Docker Container ID
      #   Dockerspec::Serverspec::Runner.new(id: 'c51f86c28340')
      #     #=> #<Dockerspec::Serverspec::Runner:0x0125>
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
      # @return [Dockerspec::Serverspec::Runner] Runner object.
      #
      # @api public
      #
      def initialize(*opts)
        super
        @specinfra_backend = nil
        @backend = calculate_docker_backend_name
      end

      #
      # Runs the Docker Container and sets the Specinfra configuration.
      #
      # @example
      #   builder = Dockerspec::Builder.new('.', tag: 'myapp')
      #   builder.build
      #   runner = Dockerspec::Serverspec::Runner.new('myapp')
      #   runner.run #=> #<Dockerspec::Serverspec::Runner:0x0123>
      #
      # @return [Dockerspec::Serverspec::Runner] Runner object.
      #
      # @api public
      #
      def run
        specinfra_setup
        run_container
        specinfra_save
        self
      end

      #
      # Stops and deletes the Docker Container.
      #
      # Actually does nothing. Do no delete anything, let Specinfra do that.
      #
      # @return void
      #
      # @api public
      #
      def finalize
        # Do not stop the container
      end

      #
      # Restores the Docker running container instance in the Specinfra
      # internal reference.
      #
      # Gets the correct {Runner} reference from the RSpec metadata.
      #
      # @example Restore Specinfra Backend
      #   RSpec.configure do |c|
      #     c.before(:each) do
      #       metadata = RSpec.current_example.metadata
      #       Dockerspec::Serverspec::Runner.restore(metadata)
      #     end
      #   end
      #
      # @param metadata [Hash] RSpec metadata.
      #
      # @return void
      #
      # @api public
      #
      # @see restore
      #
      def self.restore(metadata)
        runner = Helper::RSpecExampleHelpers.search_object(metadata, self)
        return if runner.nil?
        runner.restore
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
        @specinfra_backend.restore
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
        config = RSpec.configuration
        super.tap do |opts|
          opts[:family] = config.family if config.family?
        end
      end

      #
      # Sets the Specinfra configuration.
      #
      # - Resets the internal Specinfra backend reference.
      # - Sets the `:family`.
      # - Sets the `:docker_image` or `:docker_container`.
      #
      # @return void
      #
      # @api private
      #
      def specinfra_setup
        @specinfra_backend = SpecinfraBackend.new(@backend)
        @specinfra_backend.reset
        if @options.key?(:family)
          Specinfra.configuration.os(family: @options[:family])
        end
        if id.nil?
          Specinfra.configuration.docker_image(image_id)
        else
          Specinfra.configuration.docker_container(id)
        end
      end

      #
      # Saves the Specinfra backend internal reference internally to restore
      # it later.
      #
      # @return void
      #
      # @api private
      #
      def specinfra_save
        @specinfra_backend.save
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
        Specinfra.configuration.backend(@backend)
      end
    end
  end
end

#
# Restore Specinfra backend:
#
RSpec.configure do |c|
  c.before(:each) do
    metadata = RSpec.current_example.metadata
    Dockerspec::Serverspec::Runner.restore(metadata)
  end
end

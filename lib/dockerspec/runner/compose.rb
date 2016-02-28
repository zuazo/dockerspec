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

require 'docker-compose'
require 'dockerspec/exceptions'
require 'dockerspec/helper/multiple_sources_description'
require 'dockerspec/runner/base'

module Dockerspec
  module Runner
    #
    # This class runs Docker Compose (without using Serverspec for that).
    #
    # This class is used mainly when you are not using Serverspec to run the
    # tests.
    #
    class Compose < Base
      class << self
        #
        # Saves the latest created {Dockerspec::Runner::Compose} object.
        #
        # @return [Docker::Runner::Compose::Base] The saved instance.
        #
        # @api public
        #
        attr_accessor :current_instance
      end

      include Dockerspec::Helper::MultipleSourcesDescription

      #
      # @return [Symbol] The option key to set when you pass a string instead
      #   of a hash of options.
      #
      OPTIONS_DEFAULT_KEY = :file

      #
      # The internal {DockerCompose} object.
      #
      # @return [DockerCompose] The compose object.
      #
      attr_reader :compose

      #
      # Constructs a runner class to run Docker Compose.
      #
      # @example From a Directory
      #   Dockerspec::Runner::Compose.new('directory1')
      #     #=> #<Dockerspec::Runner::Compose:0x0124>
      #
      # @example From a YAML File
      #   Dockerspec::Runner::Compose.new('data/docker-compose.yml')
      #     #=> #<Dockerspec::Runner::Compose:0x0124>
      #
      # @example From a Directory or File Using Hash Format
      #   Dockerspec::Runner::Compose.new(file: 'file.yml')
      #     #=> #<Dockerspec::Runner::Compose:0x0124>
      #
      # @param opts [String, Hash] The `:file` or a list of options.
      #
      # @option opts [String] :file The compose YAML file or a directory
      #   containing the `'docker-compose.yml'` file.
      # @option opts [Boolean] :rm (calculated) Whether to remove the Docker
      # @option opts [Integer] :wait Time to wait before running the tests.
      #
      # @return [Dockerspec::Runner::Compose] Runner object.
      #
      # @raise [Dockerspec::DockerRunArgumentError] Raises this exception when
      #   some required options are missing.
      #
      # @api public
      #
      def initialize(*opts)
        Compose.current_instance = self
        @container_options = {}
        super
        setup_from_file(file)
      end

      # Does not call ready because container is still not ready.
      #
      # Runs the Docker Container.
      #
      # 1. Sets up the test context.
      # 2. Runs the container (or Compose).
      # 3. Saves the created underlaying test context.
      #
      # @return [Dockerspec::Runner::Compose] Runner object.
      #
      # @raise [Dockerspec::DockerError] For underlaying docker errors.
      #
      # @see #select_conainer
      #
      # @api public
      #
      def run
        before_running
        start_time = Time.new.utc
        run_container
        when_running
        do_wait((Time.new.utc - start_time).to_i)
        self
      end

      #
      # Selects the container to test and sets its configuration options.
      #
      # Also sets the selected container as ready in the underlaying test
      # engines.
      #
      # @param name [Symbol, String] The container name.
      #
      # @param opts [Hash] Container configuration options.
      #
      # @return void
      #
      # @api public
      #
      def select_container(name, opts = nil)
        @options[:container] = name
        @container_options[name] = @options.merge(opts) if opts.is_a?(Hash)
        when_container_ready
      end

      #
      # Returns general and container specific options merged.
      #
      # @return void
      #
      # @api private
      #
      def options
        container_name = @options[:container]
        @container_options[container_name] || @options
      end

      #
      # Gets the selected container name.
      #
      # @return [String, nil] The container name.
      #
      # @api private
      #
      def container_name
        return nil if @options[:container].nil?
        @options[:container].to_s
      end

      #
      # Gets the selected container object.
      #
      # This method is used in {Dockerspec::Runner::Base} to get information
      # from the container: ID, image ID, ...
      #
      # @return [Docker::Container] The container object.
      #
      # @raise [Dockerspec::RunnerError] When cannot select the container to
      #  test.
      #
      # @api public
      #
      def container
        if container_name.nil?
          raise RunnerError,
                'Use `its_container` to select a container to test.'
        end
        compose_container = compose.containers[container_name]
        if compose_container.nil?
          raise RunnerError, "Container not found: #{compose_container.inspect}"
        end
        compose_container.container
      end

      #
      # Gets a descriptions of the object.
      #
      # @example Running from a Compose File
      #   r = Dockerspec::Runner::Compose.new('docker-compose.yml')
      #   r.to_s #=> "Docker Compose Run from file: \"docker-compose.yml\""
      #
      # @example Running from a Compose Directory
      #   r = Dockerspec::Runner::Compose.new('docker_images')
      #   r.to_s #=> "Docker Compose Run from file: "\
      #          #   "\"docker_images/docker-compose.yml\""
      #
      # @return [String] The object description.
      #
      # @api public
      #
      def to_s
        description('Docker Compose Run from')
      end

      #
      # Stops and deletes the Docker Compose containers.
      #
      # Automatically called when `:rm` option is enabled.
      #
      # @return void
      #
      # @api public
      #
      def finalize
        return if options[:rm] == false || compose.nil?
        compose.stop
        compose.delete
      end

      protected

      #
      # Gets the full path of the Docker Compose YAML file.
      #
      # It adds `'docker-compose.yml'` if you pass a directory.
      #
      # @return [String] The file path.
      #
      # @api private
      #
      def file
        @file ||=
          if File.directory?(options[source])
            File.join(options[source], 'docker-compose.yml')
          else
            options[source]
          end
      end

      #
      # Gets the source to start the container from.
      #
      # Possible values: `:file`.
      #
      # @example Start the Container from a YAML Configuration File
      #   self.source #=> :file
      #
      # @return [Symbol] The source.
      #
      # @api private
      #
      def source
        return @source unless @source.nil?
        @source = %i(file).find { |from| options.key?(from) }
      end

      #
      # Gets the default options configured using `RSpec.configuration`.
      #
      # @example
      #   self.rspec_options #=> {:container => "webapp", :docker_wait => 30}
      #
      # @return [Hash] The configuration options.
      #
      # @api private
      #
      def rspec_options
        config = ::RSpec.configuration
        super.tap do |opts|
          opts[:container] = config.container_name if config.container_name?
        end
      end

      #
      # Ensures that the passed options are correct.
      #
      # Currently this only checks that you passed the `:file` argument.
      #
      # @return void
      #
      # @raise [Dockerspec::DockerRunArgumentError] Raises this exception when
      #   the required fields are missing.
      #
      # @api private
      #
      def assert_options!(opts)
        return if opts[:file].is_a?(String)
        raise DockerRunArgumentError, 'You need to pass the `:file` option '\
          'to the #docker_compose method.'
      end

      #
      # Saves the build internally.
      #
      # @param file [String] The configuration file.
      #
      # @return void
      #
      # @api private
      #
      def setup_from_file(file)
        @compose = ::DockerCompose.load(file)
      end

      #
      # Runs Docker Compose.
      #
      # @return void
      #
      # @api private
      #
      def run_container
        Dir.chdir(::File.dirname(file)) { compose.start }
      end
    end
  end
end

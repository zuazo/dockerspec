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

require 'dockerspec/exceptions'
require 'dockerspec/engine_list'
require 'dockerspec/runner/config_helpers'
require 'dockerspec/helper/rspec_example_helpers'

module Dockerspec
  module Runner
    #
    # A basic class with the minimal skeleton to create a Runner: Classes to
    # start docker containers.
    #
    class Base
      include Dockerspec::Runner::ConfigHelpers

      #
      # The option key to set when you pass a string instead of a hash of
      # options.
      #
      OPTIONS_DEFAULT_KEY = :ignored

      #
      # Gets the configuration options.
      #
      # @return [Hash] The options.
      #
      # @api private
      #
      attr_reader :options

      #
      # Constructs a runner class to run Docker images.
      #
      # @param opts [String, Hash] The id/name/file or a list of options.
      #
      # @option opts [Boolean] :rm (calculated) Whether to remove the Docker
      #   container afterwards.
      # @option opts [Integer] :wait Time to wait before running the tests.
      #
      # @return [Dockerspec::Runner::Base] Runner object.
      #
      # @raise [Dockerspec::EngineError] Raises this exception when the engine
      #   list is empty.
      #
      # @api public
      #
      def initialize(*opts)
        @options = parse_options(opts)
        @engines = EngineList.new(self)
        ObjectSpace.define_finalizer(self, proc { finalize })
      end

      #
      # Runs the Docker Container.
      #
      # 1. Sets up the test context.
      # 2. Runs the container (or Compose).
      # 3. Saves the created underlaying test context.
      # 4. Sets the container as ready.
      # 5. Waits the required (configured) time after container has been
      #    started.
      #
      # @example
      #   builder = Dockerspec::Builder.new('.')
      #   builder.build
      #   runner = Dockerspec::Runner::Base.new(builder)
      #   runner.run #=> #<Dockerspec::Runner::Base:0x0123>
      #
      # @return [Dockerspec::Runner::Base] Runner object.
      #
      # @raise [Dockerspec::DockerError] For underlaying docker errors.
      #
      # @api public
      #
      def run
        before_running
        start_time = Time.new.utc
        run_container
        when_running
        when_container_ready
        do_wait((Time.new.utc - start_time).to_i)
        self
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
      def restore_rspec_context
        @engines.restore
      end

      #
      # Gets the internal {Docker::Container} object.
      #
      # @return [Docker::Container] The container.
      #
      # @raise [Dockerspec::RunnerError] When the method is no implemented in
      #   the subclass.
      #
      # @api public
      #
      def container
        raise RunnerError, "#{self.class}#container method must be implemented"
      end

      #
      # Gets the container name.
      #
      # @return [String] Container name.
      #
      # @raise [Dockerspec::RunnerError] When the `#container` method is no
      #   implemented in the subclass or cannot select the container to test.
      #
      # @api public
      #
      def container_name
        container.json['Name']
      end

      #
      # Gets the Docker container ID.
      #
      # @example
      #   builder = Dockerspec::Builder.new('.').build
      #   runner = Dockerspec::Runner::Base.new(builder).run
      #   runner.id #=> "b8ba0befc716[...]"
      #
      # @return [String] Container ID.
      #
      # @raise [Dockerspec::RunnerError] When the `#container` method is no
      #   implemented in the subclass or cannot select the container to test.
      #
      # @api public
      #
      def id
        return nil unless container.respond_to?(:id)
        container.id
      end

      #
      # Gets the Docker image ID.
      #
      # @return [String] Image ID.
      #
      # @raise [Dockerspec::RunnerError] When the `#container` method is no
      #   implemented in the subclass or cannot select the container to test.
      #
      # @api public
      #
      def image_id
        container.json['Image']
      end

      #
      # Gets the Docker Container IP address.
      #
      # This is used by {Dockerspec::Engine::Infrataster}.
      #
      # @return [String] IP address.
      #
      # @raise [Dockerspec::RunnerError] When the `#container` method is no
      #   implemented in the subclass or cannot select the container to test.
      #
      # @api public
      #
      def ipaddress
        container.json['NetworkSettings']['IPAddress']
      end

      #
      # Stops and deletes the Docker Container.
      #
      # Automatically called when `:rm` option is enabled.
      #
      # @return void
      #
      # @api public
      #
      def finalize
        return if options[:rm] == false || container.nil?
        container.stop
        container.delete
      end

      protected

      #
      # Sets up the context just before starting the docker container.
      #
      # @return void
      #
      # @api public
      #
      def before_running
        @engines.before_running
      end

      #
      # Saves the context after starting the docker container.
      #
      # @return void
      #
      # @api public
      #
      def when_running
        @engines.when_running
      end

      #
      # Notifies the engines that the container to test is selected and ready.
      #
      # @return void
      #
      # @api public
      #
      def when_container_ready
        @engines.when_container_ready
      end

      #
      # Gets the default options configured using `RSpec.configuration`.
      #
      # @example
      #   self.rspec_options #=> {}
      #
      # @return [Hash] The configuration options.
      #
      # @api private
      #
      def rspec_options
        config = ::RSpec.configuration
        {}.tap do |opts|
          opts[:wait] = config.docker_wait if config.docker_wait?
        end
      end

      #
      # The option key to set when you pass a string instead of a hash of
      # options.
      #
      # @return [Symbol] The key name.
      #
      # @api private
      #
      def options_default_key
        self.class::OPTIONS_DEFAULT_KEY
      end

      #
      # Gets the default configuration options after merging them with RSpec
      # configuration options.
      #
      # @example
      #   self.default_options #=> {}
      #
      # @return [Hash] The configuration options.
      #
      # @api private
      #
      def default_options
        {}.merge(rspec_options)
      end

      #
      # Ensures that the passed options are correct.
      #
      # Does nothing. Must be implemented in subclasses.
      #
      # @return void
      #
      # @api private
      #
      def assert_options!(opts); end

      #
      # Parses the configuration options passed to the constructor.
      #
      # @example
      #   self.parse_options #=> {:rm=>true, :file=> "docker-compose.yml"}
      #
      # @param opts [Array<String, Hash>] The list of options. The strings will
      #   be interpreted as `default_opt` key value, others will be merged.
      #
      # @return [Hash] The configuration options.
      #
      # @raise [Dockerspec::DockerRunArgumentError] Raises this exception when
      #   some required fields are missing.
      #
      # @see #initialize
      #
      # @api private
      #
      def parse_options(opts)
        opts_hs_ary = opts.map do |x|
          x.is_a?(Hash) ? x : { options_default_key => x }
        end
        result = opts_hs_ary.reduce(default_options) { |a, e| a.merge(e) }
        assert_options!(result)
        result
      end

      #
      # Starts the Docker container.
      #
      # @return void
      #
      # @raise [Dockerspec::RunnerError] When the `#container` method is no
      #   implemented in the subclass.
      #
      # @api private
      #
      def run_container
        container.start
      end

      #
      # Sleeps for some time if required.
      #
      # Reads the seconds to sleep from the `:docker_wait` or `:wait`
      # configuration option.
      #
      # @param waited [Integer] The time already waited.
      #
      # @return nil
      #
      # @api private
      #
      def do_wait(waited)
        wait = options[:wait]
        return unless wait.is_a?(Integer) || wait.is_a?(Float)
        return if waited >= wait
        sleep(wait - waited)
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
    Dockerspec::Helper::RSpecExampleHelpers.restore_rspec_context(metadata)
  end
end

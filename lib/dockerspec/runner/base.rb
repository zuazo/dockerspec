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
require 'dockerspec/helper/rspec_example_helpers'

module Dockerspec
  module Runner
    #
    # A basic class with the minimal skeleton to create a Runner: Classes to
    # start docker containers.
    #
    class Base
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
        setup
        run_container
        save
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
      # Stops and deletes the Docker Container.
      #
      # Automatically called when `:rm` option is enabled.
      #
      # @return void
      #
      # @api public
      #
      def finalize
        return unless options[:rm] && !container.nil?
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
      def setup
        @engines.setup
      end

      #
      # Saves the context after starting the docker container.
      #
      # @return void
      #
      # @api public
      #
      def save
        @engines.save
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
        {}
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
      # Parses the configuration options passed to the constructor.
      #
      # @example
      #   self.parse_options #=> {:rm=>true}
      #
      # @param opts [Array<String, Hash>] The list of options. The strings will
      #   be interpreted as `:tag`, others will be merged.
      #
      # @return [Hash] The configuration options.
      #
      # @see #initialize
      #
      # @api private
      #
      def parse_options(opts)
        opts.reduce(default_options) { |a, e| a.merge(e) }
      end

      #
      # Gets the internal `Docker::Container` object.
      #
      # @return [Docker::Container] The container.
      #
      # @raise [Dockerspec::RunnerError] When the method is no implemented in
      #   the subclass.
      #
      # @api private
      #
      def container
        fail RunnerError, "#{self.class}#container method must be implemented"
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

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

require 'docker'
require 'dockerspec/exceptions'
require 'dockerspec/engine_list'
require 'dockerspec/helper/rspec_example_helpers'

module Dockerspec
  module Runner
    #
    # A basic class with the minimal skeleton to create a Runner: A class to
    # start the docker containers.
    #
    class Base
      #
      # Constructs a runner class to run Docker images.
      #
      # @param opts [String, Hash] The id/name or a list of options.
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
        @engines = EngineList.new(self, @options)
        ObjectSpace.define_finalizer(self, proc { finalize })
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
      # Runs the Docker Container.
      #
      # @example
      #   builder = Dockerspec::Builder.new('.')
      #   builder.build
      #   runner = Dockerspec::Runner.new(builder)
      #   runner.run #=> #<Dockerspec::Runner::Base:0x0123>
      #
      # @return [Dockerspec::Runner::Base] Runner object.
      #
      # @api public
      #
      def run
        @engines.setup
        run_container
        @engines.save
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
      def restore
        @engines.restore
      end

      #
      # Restores the Docker running container instance in the Specinfra
      # internal reference.
      #
      # Gets the correct {Runner::Base} reference from the RSpec metadata.
      #
      # @example Restore Specinfra Backend
      #   RSpec.configure do |c|
      #     c.before(:each) do
      #       metadata = RSpec.current_example.metadata
      #       Dockerspec::Runner::Base.restore(metadata)
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
      # Gets the Docker container ID.
      #
      # @example
      #   builder = Dockerspec::Builder.new('.').build
      #   runner = Dockerspec::Runner.new(builder).run
      #   runner.id #=> "b8ba0befc716[...]"
      #
      # @return [String] Container ID.
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
      #   implemented in the subclass.
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
        return unless @options[:rm] && !container.nil?
        container.stop
        container.delete
      end

      protected

      #
      # Returns the internal `Docker::Container` object.
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
    Dockerspec::Runner::Base.restore(metadata)
  end
end

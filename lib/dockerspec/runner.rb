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

require 'docker'
require 'dockerspec/docker_gem'
require 'dockerspec/exceptions'
require 'dockerspec/helper/multiple_sources_description'

module Dockerspec
  #
  # This class runs a docker image (without using Serverspec for that).
  #
  # This class is not used much, only inherited by
  # {Dockerspec::Serverspec::Runner}, which uses Serverspec to run the images.
  # Some of the methods here are used there, others not.
  #
  class Runner
    include Dockerspec::Helper::MultipleSourcesDescription

    #
    # Constructs a Docker runner class to run Docker images.
    #
    # @example From a Running Docker Image
    #   Dockerspec::Runner.new('debian:8') #=> #<Dockerspec::Runner:0x0124>
    #
    # @example From a Running Docker Container ID
    #   # This does not start any new container
    #   Dockerspec::Runner.new(id: 'c51f86c28340')
    #     #=> #<Dockerspec::Runner:0x0124>
    #
    # @example From a Running Docker Container Image Name
    #   Dockerspec::Runner.new('my-debian') #=> #<Dockerspec::Runner:0x0125>
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
    #
    # @return [Dockerspec::Runner] Runner object.
    #
    # @api public
    #
    def initialize(*opts)
      @options = parse_options(opts)
      send("setup_from_#{source}", @options[source])
      ObjectSpace.define_finalizer(self, proc { finalize })
    end

    #
    # Runs the Docker Container.
    #
    # @example
    #   builder = Dockerspec::Builder.new('.')
    #   builder.build
    #   runner = Dockerspec::Runner.new(builder)
    #   runner.run #=> #<Dockerspec::Runner:0x0123>
    #
    # @return [Dockerspec::Runner] Runner object.
    #
    # @api public
    #
    def run
      create_container
      run_container
      self
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
      return nil unless @container.respond_to?(:id)
      @container.id
    end

    #
    # Gets the Docker image ID.
    #
    # @example
    #   builder = Dockerspec::Builder.new('.').build
    #   runner = Dockerspec::Runner.new(builder)
    #   runner.image_id #=> "c51f86c28340[...]"
    #
    # @return [String] Image ID.
    #
    # @api public
    #
    def image_id
      return @build.id unless @build.nil?
      @container.json['Image']
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
      return unless @options[:rm] && !@container.nil?
      @container.stop
      @container.delete
    end

    #
    # Gets a descriptions of the object.
    #
    # @example Running from a Container Image ID
    #   r = Dockerspec::Runner.new('debian')
    #   r.to_s #=> "Docker Run from tag: \"debian\""
    #
    # @example Attaching to a Running Container ID
    #   r = Dockerspec::Runner.new(id: '92cc98ab560a')
    #   r.to_s #=> "Docker Run from id: \"92cc98ab560a\""
    #
    # @return [String] The object description.
    #
    # @api public
    #
    def to_s
      description('Docker Run from')
    end

    protected

    #
    # Gets the source to start the container from.
    #
    # Possible values: `:tag`, `:id`.
    #
    # @example Start the Container from an Image Tag
    #   self.source #=> :tag
    #
    # @example Attach to a Running Container ID
    #   self.source #=> :id
    #
    # @return [Symbol] The source.
    #
    # @api private
    #
    def source
      return @source unless @source.nil?
      %i(tag id).any? do |from|
        next false unless @options.key?(from)
        @source = from # Used for description
      end
      @source
    end

    #
    # Generates a description from Docker tag name.
    #
    # @example
    #   self.description_from_tag('debian') #=> "debian"
    #   self.description_from_tag('92cc98ab560a92cc98ab560[...]')
    #     #=> "92cc98ab560a"
    #
    # @return [String] The description, shortened if necessary.
    #
    # @see Dockerspec::Helper::MultipleSourceDescription#description_from_docker
    #
    # @api private
    #
    alias_method :description_from_tag, :description_from_docker

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
    # Ensures that the passed options are correct.
    #
    # Currently this only checks that you passed the `:tag` or the `:id`
    # argument.
    #
    # @return void
    #
    # @raise [Dockerspec::DockerRunArgumentError] Raises this exception when
    #   the required fields are missing.
    #
    # @api private
    #
    def assert_options!(opts)
      return if opts[:tag].is_a?(String) || opts[:id].is_a?(String)
      fail DockerRunArgumentError, 'You need to pass the `:tag` or the `:id` '\
        'option to the #docker_run method.'
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
    # @raise [Dockerspec::DockerRunArgumentError] Raises this exception when
    #   some required fields are missing.
    #
    # @see #initialize
    #
    # @api private
    #
    def parse_options(opts)
      opts_hs_ary = opts.map { |x| x.is_a?(Hash) ? x : { tag: x } }
      result = opts_hs_ary.reduce(default_options) { |a, e| a.merge(e) }
      assert_options!(result)
      result
    end

    #
    # Generates the build object from the Docker image tag.
    #
    # Saves the build internally.
    #
    # @param tag [String] The image name or ID.
    #
    # @return void
    #
    # @api private
    #
    def setup_from_tag(tag)
      @build = Builder.new(id: tag).build
    end

    #
    # Generates the container object from a running Docker container.
    #
    # Saves the container internally.
    #
    # @param id [String] The container ID or name.
    #
    # @return void
    #
    # @api private
    #
    def setup_from_id(id)
      @container = ::Docker::Container.get(id)
    end

    #
    # Ensures that the Docker container has a correct `CMD`.
    #
    # @param opts [Hash] {Docker::Container} options.
    #
    # @return [Hash] {Docker::Container} options.
    #
    # @api private
    #
    def add_container_cmd_option(opts)
      opts['Cmd'] = %w(/bin/sh) if @build.cmd.nil?
      opts
    end

    #
    # Adds some `ENV` options to the Docker container.
    #
    # @param opts [Hash] {Docker::Container} options.
    #
    # @return [Hash] {Docker::Container} options.
    #
    # @api private
    #
    def add_container_env_options(opts)
      opts['Env'] = opts['Env'].to_a << "PATH=#{path}" if @options.key?(:path)
      env = @options[:env].to_a.map { |v| v.join('=') }
      opts['Env'] = opts['Env'].to_a.concat(env)
      opts
    end

    #
    # Generates the Docker container options for {Docker::Container}.
    #
    # @return [Hash] The container options.
    #
    # @api private
    #
    def container_options
      opts = { 'Image' => image_id, 'OpenStdin' => true }

      add_container_cmd_option(opts)
      add_container_env_options(opts)
      opts
    end

    #
    # Creates the Docker container.
    #
    # *Note: Based on Specinfra `:docker` backend code.*
    #
    # @return void
    #
    # @api private
    #
    def create_container
      return @container unless @container.nil?
      @container = ::Docker::Container.create(container_options)
    end

    #
    # Runs the Docker container.
    #
    # @return void
    #
    # @api private
    #
    def run_container
      @container.start
    end
  end
end

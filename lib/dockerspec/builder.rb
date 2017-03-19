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

require 'rspec'
require 'rspec/its'
require 'rspec/retry'
require 'tmpdir'
require 'erubis'
require 'dockerspec/docker_gem'
require 'dockerspec/builder/config_helpers'
require 'dockerspec/builder/matchers'
require 'dockerspec/builder/logger'
require 'dockerspec/builder/image_gc'
require 'dockerspec/helper/ci'
require 'dockerspec/helper/multiple_sources_description'
require 'dockerspec/docker_exception_parser'

module Dockerspec
  #
  # A class to build a container image.
  #
  class Builder
    include Dockerspec::Builder::ConfigHelpers
    include Dockerspec::Helper::CI
    include Dockerspec::Helper::MultipleSourcesDescription

    #
    # Constructs a Docker image builder class.
    #
    # @example Build an Image From CWD or `DOCKERFILE_PATH`
    #   Dockerspec::Builder.new #=> #<Dockerspec::Builder:0x0123>
    #
    # @example Build an Image from a Directory
    #   Dockerspec::Builder.new('imagedir') #=> #<Dockerspec::Builder:0x0124>
    #
    # @example Do Not Remove the Image
    #   Dockerspec::Builder.new('../', rm: false)
    #     #=> #<Dockerspec::Builder:0x0125>
    #
    # @example Passing Multiple Params
    #   Dockerspec::Builder.new(path: '../', tag: 'myapp', rm: false)
    #     #=> #<Dockerspec::Builder:0x0125>
    #
    # @param opts [String, Hash] The `:path` or a list of options.
    #
    # @option opts [String] :path ('.') The directory or file that contains the
    #   *Dockerfile*. By default tries to read it from the `DOCKERFILE_PATH`
    #   environment variable and uses `'.'` if it is not set.
    # @option opts [String] :string Use this string as *Dockerfile* instead of
    #   `:path`. Not set by default.
    # @option opts [String] :template Use this [Erubis]
    #   (http://www.kuwata-lab.com/erubis/users-guide.html) template file as
    #   *Dockerfile*.
    # @option opts [String] :id Use this Docker image ID instead of a
    #   *Dockerfile*.
    # @option opts [Boolean] :rm Whether to remove the generated docker images
    #   after running the tests. By default only removes them if it is running
    #   on a CI machine.
    # @option opts [Hash, Erubis::Context] :context ({}) Template *context*
    #   used when the `:template` source is used.
    # @option opts [String] :tag Repository tag to be applied to the resulting
    #   image.
    # @option opts [Integer, Symbol] :log_level Sets the docker library
    #   verbosity level. Possible values:
    #    `:silent` or `0` (no output),
    #    `:ci` or `1` (enables some outputs recommended for CI environments),
    #    `:info` or `2` (gives information about main build steps),
    #    `:debug` or `3` (outputs all the provided information in its raw
    #      original form).
    #
    # @see Dockerspec::RSpec::Resources#docker_build
    #
    # @api public
    #
    def initialize(*opts)
      @image = nil
      @options = parse_options(opts)
    end

    #
    # Returns Docker image ID.
    #
    # @example Get the Image ID After Building the Image
    #   d = Dockerspec::Builder.new
    #   d.build
    #   d.id #=> "9f8866b49bfb[...]"
    #
    # @return [String] Docker image ID.
    #
    # @api public
    #
    def id
      @image.id
    end

    #
    # Builds the docker image.
    #
    # @example Build an Image From a Path
    #   d = Dockerspec::Builder.new(path: 'dockerfile_dir')
    #   d.build #=> #<Dockerspec::Builder:0x0125>
    #
    # @return [String] Docker image ID.
    #
    # @raise [Dockerspec::DockerError] For underlaying docker errors.
    #
    # @api public
    #
    def build
      send("build_from_#{source}", @options[source])
      self
    end

    #
    # Gets a descriptions of the object.
    #
    # @example
    #   d = Dockerspec::Builder.new('.')
    #   d.to_s #=> "Docker Build from path: ."
    #
    # @return [String] The object description.
    #
    # @api public
    #
    def to_s
      description('Docker Build from')
    end

    protected

    #
    # Gets the source to generate the image from.
    #
    # Possible values: `:string`, `:template`, `:id`, `:path`.
    #
    # @example Building an Image from a Path
    #   self.source #=> :path
    #
    # @example Building an Image from a Template
    #   self.source #=> :template
    #
    # @return [Symbol] The source.
    #
    # @api private
    #
    def source
      return @source unless @source.nil?
      @source = %i(string template id path).find { |from| @options.key?(from) }
    end

    #
    # Generates a description when build from a template.
    #
    # @example
    #   self.description_from_template("file.erb") #=> "file.erb"
    #
    # @return [String] A description.
    #
    # @see Dockerspec::Helper::MultipleSourcesDescription#description_from_file
    #
    # @api private
    #
    alias description_from_template description_from_file

    #
    # Sets or gets the Docker image.
    #
    # @param img [Docker::Image] The Docker image to set.
    #
    # @return [Docker::Image] The Docker image object.
    #
    # @api private
    #
    def image(img = nil)
      return @image if img.nil?
      ImageGC.instance.add(img.id) if @options[:rm]
      @image = img
    end

    #
    # Gets the default options configured using `RSpec.configuration`.
    #
    # @example
    #   self.rspec_options #=> {:path=>".", :rm=>true, :log_level=>:silent}
    #
    # @return [Hash] The configuration options.
    #
    # @api private
    #
    def rspec_options
      config = ::RSpec.configuration
      {}.tap do |opts|
        opts[:path] = config.dockerfile_path if config.dockerfile_path?
        opts[:rm] = config.rm_build if config.rm_build?
        opts[:log_level] = config.log_level if config.log_level?
      end
    end

    #
    # Gets the default configuration options after merging them with RSpec
    # configuration options.
    #
    # @example
    #   self.default_options #=> {:path=>".", :rm=>true, :log_level=>:silent}
    #
    # @return [Hash] The configuration options.
    #
    # @api private
    #
    def default_options
      {
        path: ENV['DOCKERFILE_PATH'] || '.',
        # Autoremove images in all CIs except Travis (not supported):
        rm: ci? && !travis_ci?,
        # Avoid CI timeout errors:
        log_level: ci? ? :ci : :silent
      }.merge(rspec_options)
    end

    #
    # Parses the configuration options passed to the constructor.
    #
    # @example
    #   self.parse_options #=> {:path=>".", :rm=>true, :log_level=>:silent}
    #
    # @param opts [Array<String, Hash>] The list of optitag. The strings will
    #   be interpreted as `:path`, others will be merged.
    #
    # @return [Hash] The configuration options.
    #
    # @see #initialize
    #
    # @api private
    #
    def parse_options(opts)
      opts_hs_ary = opts.map { |x| x.is_a?(Hash) ? x : { path: x } }
      opts_hs_ary.reduce(default_options) { |a, e| a.merge(e) }
    end

    #
    # Generates the Ruby block used to parse the logs during image construction.
    #
    # @return [Proc] The Ruby block.
    #
    # @api private
    #
    def build_block
      proc { |chunk| logger.print_chunk(chunk) }
    end

    #
    # Builds the image from a string. Generates the Docker tag if required.
    #
    # It also saves the generated image in the object internally.
    #
    # This creates a temporary directory where it copies all the files and
    # generates the temporary Dockerfile.
    #
    # @param string [String] The Dockerfile content.
    #
    # @return void
    #
    # @api private
    #
    def build_from_string(string, dir = '.')
      Dir.mktmpdir do |tmpdir|
        FileUtils.cp_r("#{dir}/.", tmpdir)
        dockerfile = File.join(tmpdir, 'Dockerfile')
        File.open(dockerfile, 'w') { |f| f.write(string) }
        build_from_dir(tmpdir)
      end
    end

    #
    # Builds the image from a file that is not called *Dockerfile*.
    #
    # It also saves the generated image in the object internally.
    #
    # This creates a temporary directory where it copies all the files and
    # generates the temporary Dockerfile.
    #
    # @param file [String] The Dockerfile file path.
    #
    # @return void
    #
    # @api private
    #
    def build_from_file(file)
      dir = File.dirname(file)
      string = IO.read(file)
      build_from_string(string, dir)
    end

    #
    # Builds the image from a directory with a Dockerfile.
    #
    # It also saves the generated image in the object internally.
    #
    # @param dir [String] The directory path.
    #
    # @return void
    #
    # @raise [Dockerspec::DockerError] For underlaying docker errors.
    #
    # @api private
    #
    def build_from_dir(dir)
      image(::Docker::Image.build_from_dir(dir, &build_block))
      add_repository_tag
    rescue ::Docker::Error::DockerError => e
      DockerExceptionParser.new(e)
    end

    #
    # Builds the image from a directory or a file.
    #
    # It also saves the generated image in the object internally.
    #
    # @param path [String] The path.
    #
    # @return void
    #
    # @api private
    #
    def build_from_path(path)
      if !File.directory?(path) && File.basename(path) == 'Dockerfile'
        path = File.dirname(path)
      end
      File.directory?(path) ? build_from_dir(path) : build_from_file(path)
    end

    #
    # Builds the image from a template.
    #
    # It also saves the generated image in the object internally.
    #
    # @param file [String] The Dockerfile [Erubis]
    # (http://www.kuwata-lab.com/erubis/users-guide.html) template path.
    #
    # @return void
    #
    # @api private
    #
    def build_from_template(file)
      context = @options[:context] || {}

      template = IO.read(file)
      eruby = Erubis::Eruby.new(template)
      string = eruby.evaluate(context)
      build_from_string(string, File.dirname(file))
    end

    #
    # Gets the image from a Image ID.
    #
    # It also saves the image in the object internally.
    #
    # @param id [String] The Docker image ID.
    #
    # @return void
    #
    # @raise [Dockerspec::DockerError] For underlaying docker errors.
    #
    # @api private
    #
    def build_from_id(id)
      @image = ::Docker::Image.get(id)
      add_repository_tag
    rescue ::Docker::Error::NotFoundError
      @image = ::Docker::Image.create('fromImage' => id)
      add_repository_tag
    rescue ::Docker::Error::DockerError => e
      DockerExceptionParser.new(e)
    end

    #
    # Adds a repository name and a tag to the Docker image.
    #
    # @return void
    #
    # @api private
    #
    def add_repository_tag
      return unless @options.key?(:tag)
      repo, repo_tag = @options[:tag].split(':', 2)
      @image.tag(repo: repo, tag: repo_tag, force: true)
    end

    #
    # Gets the Docker Logger to use during the build process.
    #
    # @return void
    #
    # @api private
    #
    def logger
      @logger ||= Logger.instance(@options[:log_level])
    end
  end
end

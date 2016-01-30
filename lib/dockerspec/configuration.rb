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

require 'dockerspec/runner/docker'

module Dockerspec
  #
  # Saves internal configuration for {Dockerspec}.
  #
  # - The test engines to Run: Specinfra, ...
  # - The internal library used to run Docker.
  #
  class Configuration
    #
    # The {Dockerspec::Runner} class used to run Docker.
    #
    # @return [Class] The {Dockerspec::Runner::Base} class.
    #
    attr_accessor :docker_runner

    #
    # A list of test engines used to run the tests.
    #
    # @return [Array<Class>] A list of {Dockerspec::Engine::Base} classes.
    #
    attr_reader :engines

    #
    # Adds a class to use as engine to run the tests.
    #
    # @example
    #   Dockerspec.Configuration.add_engine Dockerspec::Engine::Specinfra
    #
    # @param engine [Class] A {Dockerspec::Engine::Base} subclass.
    #
    # @return void
    #
    # @api public
    #
    def self.add_engine(engine)
      instance.add_engine(engine)
    end

    #
    # Gets the engine classes used to run the tests.
    #
    # @return [Array<Class>] A list of {Dockerspec::Engine::Base} subclasses.
    #
    # @api public
    #
    def self.engines
      instance.engines
    end

    #
    # Sets the class used to create and start Docker Containers.
    #
    # @example
    #   Dockerspec.Configuration.docker_runner = Dockerspec::Runner::Docker
    #
    # @param runner [Class] A {Dockerspec::Runner::Base} subclass.
    #
    # @return void
    #
    # @api public
    #
    def self.docker_runner=(runner)
      instance.docker_runner = runner
    end

    #
    # Gets the class used to create and start Docker Containers.
    #
    # @return [Class] A {Dockerspec::Runner::Base} subclass.
    #
    # @api public
    #
    def self.docker_runner
      instance.docker_runner
    end

    #
    # Resets the internal Configuration singleton object.
    #
    # @return void
    #
    # @api public
    #
    def self.reset
      @instance = nil
    end

    #
    # Adds a class to use as engine to run the tests.
    #
    # @param engine [Class] A {Dockerspec::Engine::Base} subclass.
    #
    # @return void
    #
    # @api private
    #
    def add_engine(engine)
      @engines << engine
      @engines.uniq!
    end

    protected

    #
    # Constructs a configuration object.
    #
    # @return [Dockerspec::Configuretion] The configuration object.
    #
    # @api private
    #
    def initialize
      @docker_runner = Runner::Docker
      @engines = []
    end

    #
    # Creates the Configuration singleton instance.
    #
    # @return void
    #
    # @api private
    #
    def self.instance
      @instance ||= new
    end
  end
end

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

require 'dockerspec/configuration'
require 'dockerspec/exceptions'

module Dockerspec
  #
  # Manages the list of testing engines to use.
  #
  class EngineList
    #
    # A message with description on how to avoid the error when you forget
    # specifying the testing engine you want to use.
    #
    NO_ENGINES_MESSAGE = <<-EOE

Remember to include the Test Engine you want to use.

For example, to use Serverspec:

    require 'dockerspec'
    require 'dockerspec/serverspec'

     EOE

    #
    # Constructs the list of engines.
    #
    # Initializes all the selected engines.
    #
    # @param runner [Dockerspec::Runner::Base] The class used to run the
    #   docker container.
    #
    # @param opts [Hash] Configuration options to pass to the engines.
    #
    # @return [Dockerspec::EngineList] The list of engines.
    #
    # @api public
    #
    def initialize(runner, opts)
      engine_classes = Configuration.engines
      @engines =
        engine_classes.map { |engine_class| engine_class.new(runner, opts) }
      assert_engines!
    end

    #
    # Setups all the engines one by one.
    #
    # @param args [Mixed] Arguments to pass to the `#setup` methods.
    #
    # @return void
    #
    # @api public
    #
    def setup(*args)
      call_engines_method(:setup, *args)
    end

    #
    # Saves all the engines one by one.
    #
    # @param args [Mixed] Arguments to pass to the `#save` methods.
    #
    # @return void
    #
    # @api public
    #
    def save(*args)
      call_engines_method(:save, *args)
    end

    #
    # Restores all the engines one by one.
    #
    # @param args [Mixed] Arguments to pass to the `#restore` methods.
    #
    # @return void
    #
    # @api public
    #
    def restore(*args)
      call_engines_method(:restore, *args)
    end

    protected

    #
    # Ensures that there has been chosen at least one engine.
    #
    # @return void
    #
    # @raise [Dockerspec::EngineError] Raises this exception when the engine
    #   list is empty.
    #
    # @api private
    #
    def assert_engines!
      return unless @engines.empty?
      fail EngineError, NO_ENGINES_MESSAGE
    end

    #
    # Runs the same method on all the engines.
    #
    # @param method [String, Symbol] The method to run.
    #
    # @param args [Mixed] Arguments to pass to the methods.
    #
    # @return void
    #
    # @api private
    #
    def call_engines_method(method, *args)
      @engines.map { |engine| engine.send(method, *args) }
    end
  end
end

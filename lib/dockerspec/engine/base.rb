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

module Dockerspec
  #
  # The classes behind this namespace are Testing Engines. These are the
  # frameworks used below to run the tests. For example `Specinfra` (used by
  # `Serverspec`).
  #
  module Engine
    #
    # A basic class with the minimal skeleton to create a Testing Engine.
    #
    class Base
      #
      # Constructs the engine.
      #
      # Saves the runner and the options.
      #
      # @param runner [Dockerspec::Runner::Base] The class that is being used
      #   to run the Docker Containers.
      #
      # @return [Dockerspec::Engine::Base] The engine.
      #
      # @api public
      #
      def initialize(runner)
        @runner = runner
      end

      #
      # Runs the engine setup just before running docker.
      #
      # Also run when there is a change in the testing target like changing the
      # container you want to run the tests into with Docker Compose.
      #
      # Usually this is implemented to clean configurations from previous tests.
      #
      # Does nothing by default.
      #
      # @param args [Mixed] The passed arguments.
      #
      # @return void
      #
      # @api public
      #
      def setup(*args); end

      #
      # Saves the engine status internally after starting the docker container.
      #
      # Does nothing by default.
      #
      # @param args [Mixed] The passed arguments.
      #
      # @return void
      #
      # @api public
      #
      def save(*args); end

      #
      # Runs when the container to test is ready.
      #
      # This is mainly used with Docker Compose to know when the container to
      # test is selected.
      #
      # Without Docker Compose this is called just after calling {#save}.
      #
      # Does nothing by default.
      #
      # @param args [Mixed] The passed arguments.
      #
      # @return void
      #
      # @api public
      #
      def ready(*args); end

      #
      # Restores the engine internal status after running tests on other
      # containers.
      #
      # This is used to avoid the engine running against the last started
      # container if you are testing multiple containers at the same time.
      #
      # Does nothing by default.
      #
      # @param args [Mixed] The passed arguments.
      #
      # @return void
      #
      # @api public
      #
      def restore(*args); end

      protected

      #
      # Gets the configuration options from the runner.
      #
      # @return [Hash] Options list.
      #
      # @api private
      #
      def options
        @runner.options
      end

      #
      # Gets the Container Name.
      #
      # @return [String, nil] Container name.
      #
      # @raise [Dockerspec::RunnerError] When the `#container` method is no
      #   implemented in the subclass or cannot select the container to test.
      #
      # @api private
      #
      def container_name
        @runner.container_name
      end

      #
      # Gets the Docker Container IP address.
      #
      # @return [String] IP address.
      #
      # @raise [Dockerspec::RunnerError] When the `#container` method is no
      #   implemented in the subclass or cannot select the container to test.
      #
      # @api private
      #
      def ipaddress
        @runner.ipaddress
      end
    end
  end
end

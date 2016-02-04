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

require 'serverspec'
require 'specinfra/backend/docker_compose_lxc'
require 'dockerspec/runner/compose'
require 'dockerspec/runner/serverspec/base'
require 'dockerspec/runner/serverspec/rspec'

module Dockerspec
  module Runner
    module Serverspec
      #
      # Runs Docker Compose using [Serverspec](http://serverspec.org/).
      #
      class Compose < Dockerspec::Runner::Compose
        include Base
        #
        # Constructs a Serverspec runner class to run Docker Compose.
        #
        # @example From a Directory
        #   Dockerspec::Runner::Serverspec::Compose.new('directory1')
        #     #=> #<Dockerspec::Runner::Serverspec::Compose:0x0124>
        #
        # @example From a YAML File
        #   Dockerspec::Runner::Serverspec::Compose.new('my/docker-compose.yml')
        #     #=> #<Dockerspec::Runner::Serverspec::Compose:0x0124>
        #
        # @example From a Directory or File Using Hash Format
        #   Dockerspec::Runner::Serverspec::Compose.new(file: 'file.yml')
        #     #=> #<Dockerspec::Runner::Serverspec::Compose:0x0124>
        #
        # @param opts [String, Hash] The `:file` or a list of options.
        #
        # @option opts [String] :file The compose YAML file or a directory
        #   containing the `'docker-compose.yml'` file.
        # @option opts [Boolean] :rm (calculated) Whether to remove the Docker
        #   containers afterwards.
        # @option opts [Symbol, String] :family (calculated) The OS family if
        #   is the the same for all the containers.
        #   It's automatically detected by default, but can be used to
        #   **speed up the tests**. Some possible values:
        #   `:alpine`, `:arch`, `:coreos`, `:debian`, `:gentoo`, `:nixos`,
        #   `:plamo`, `:poky`, `:redhat`, `:suse`.
        # @option opts [Symbol] :backend (calculated) Docker backend to use:
        #   `:docker`, `:lxc`.
        #
        # @return [Dockerspec::Runner::Serverspec::Compose] Runner object.
        #
        # @api public
        #
        def initialize(*opts)
          super
          calculate_docker_backend_name('docker_compose')
        end

        protected

        #
        # Sets the Specinfra configuration and the engines.
        #
        # - Sets up the testing engines.
        # - Configures the time to wait after starting docker compose.
        # - Configures the compose file to use.
        #
        # @return void
        #
        # @api private
        #
        def setup
          super
          wait = options[:docker_wait] || options[:wait]
          Specinfra.configuration.docker_wait(wait) unless wait.nil?
          Specinfra.configuration.docker_compose_file(@options[:file])
        end
      end
    end
  end
end

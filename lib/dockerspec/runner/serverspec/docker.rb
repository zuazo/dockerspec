# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015-2016 Xabier de Zuazo
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
require 'specinfra/backend/docker_lxc'
require 'dockerspec/runner/docker'
require 'dockerspec/runner/serverspec/base'
require 'dockerspec/runner/serverspec/rspec'

module Dockerspec
  module Runner
    module Serverspec
      #
      # Runs a Docker container using [Serverspec](http://serverspec.org/).
      #
      class Docker < Dockerspec::Runner::Docker
        include Base

        #
        # Constructs a Docker Serverspec runner class to run Docker images.
        #
        # @example From a Docker Container Image Tag
        #   Dockerspec::Runner::Serverspec::Docker.new('myapp')
        #     #=> #<Dockerspec::Runner::Serverspec::Docker:0x0124>
        #
        # @example From a Docker Container Image Tag Using Hash Format
        #   Dockerspec::Runner::Serverspec::Docker.new(tag: 'myapp')
        #     #=> #<Dockerspec::Runner::Serverspec::Docker:0x0124>
        #
        # @example From a Running Docker Container ID
        #   Dockerspec::Runner::Serverspec::Docker.new(id: 'c51f86c28340')
        #     #=> #<Dockerspec::Runner::Serverspec::Docker:0x0125>
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
        # @option opts [Symbol, String] :family (calculated) The OS family.
        #   It's automatically detected by default, but can be used to
        #   **speed up the tests**. Some possible values:
        #   `:alpine`, `:arch`, `:coreos`, `:debian`, `:gentoo`, `:nixos`,
        #   `:plamo`, `:poky`, `:redhat`, `:suse`.
        # @option opts [Symbol] :backend (calculated) Docker backend to use:
        #   `:docker`, `:lxc`.
        #
        # @return [Dockerspec::Runner::Serverspec::Docker] Runner object.
        #
        # @api public
        #
        def initialize(*opts)
          super
          calculate_docker_backend_name('docker')
        end

        #
        # Gets the internal {Docker::Container} object.
        #
        # @return [Docker::Container] The container.
        #
        # @api public
        #
        def container
          @cached_container ||= begin
            backend = Engine::Specinfra::Backend.new(backend_name)
            backend.backend_instance_attribute(:container)
          end
        end

        protected

        #
        # Sets the engines and the Specinfra configuration.
        #
        # Sets the `:docker_image` or `:docker_container`.
        #
        # @return void
        #
        # @api private
        #
        def setup
          super
          if source == :id
            Specinfra.configuration.docker_container(id)
          else
            Specinfra.configuration.docker_image(image_id)
          end
        end
      end
    end
  end
end

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

require 'dockerspec/runner/compose'
require 'dockerspec/helper/rspec_example_helpers'
require 'dockerspec/exceptions'

module Dockerspec
  module RSpec
    module Resources
      #
      # This generates the object to use within `its_container` calls.
      #
      class ItsContainer
        #
        # A message with description on how to avoid the error when you forget
        # specifying the docker container you want to test with Docker Compose.
        #
        NO_DOCKER_COMPOSE_MESSAGE = <<-EOE

`its_container` can only be used within a `docker_compose` resource.

For example:

  context docker_compose('docker-compose.yml', wait: 30) do
    its_container(:mysql) do
      # [...]
    end
  end

        EOE
                                    .freeze

        #
        # Constructs a `its_container` object.
        #
        # @param container [String] The name of the container.
        #
        # @return [Dockerspec::RSpec::Resource::ItsContainer] The
        #   `its_container` object.
        #
        # @api public
        #
        def initialize(container)
          @container = container
        end

        #
        # Restores the testing context from the RSpec metadata.
        #
        # Searches for {Dockerspec::Runner::Compose} objects in the RSpec
        # metadata and restores their context to run the tests.
        #
        # This is called from the `before` block in the
        # *lib/dockerspec/runner/base.rb* file:
        #
        # ```ruby
        # RSpec.configure do |c|
        #  c.before(:each) do
        #    metadata = RSpec.current_example.metadata
        #    Dockerspec::Helper::RSpecExampleHelpers
        #      .restore_rspec_context(metadata)
        #  end
        # end
        # ```
        #
        # @return void
        #
        # @api public
        #
        def restore_rspec_context
          metadata = ::RSpec.current_example.metadata
          compose =
            Helper::RSpecExampleHelpers
            .search_object(metadata, Dockerspec::Runner::Compose)
          fail ItsContainerError, NO_DOCKER_COMPOSE_MESSAGE if compose.nil?
          compose.restore_rspec_context
          compose.select_container(@container)
        end

        #
        # Gets the description for the `its_container` resource.
        #
        # @return [String] The description.
        #
        # @api public
        #
        def to_s
          "\"#{@container}\" container"
        end
      end
    end
  end
end

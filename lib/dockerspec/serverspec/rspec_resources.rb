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

require 'dockerspec/serverspec/runner'
require 'dockerspec/serverspec/rspec_settings'

module Dockerspec
  module Serverspec
    #
    # Some resources included inside {RSpec::Core::ExampleGroup} to build and
    # run Docker containers with Serverspec.
    #
    # ## RSpec Settings
    #
    # * `family`: The OS family to use
    #
    # All the RSpec settings are optional.
    #
    # @example RSpec Settings
    #   RSpec.configure do |config|
    #     config.family = :debian
    #   end
    #
    module RSpecResources
      #
      # Runs a docker image and the Serverspec tests against it.
      #
      # See the [Serverspec Resource Types documentation]
      # (http://serverspec.org/resource_types.html) to see the available
      # resources.
      #
      # By default tries to detect the most appropriate Docker backend: native
      # or LXC.
      #
      # @example A Basic Example to Test the HTTPd Service
      #   describe docker_build('.', tag: 'myapp') do
      #     describe docker_run('myapp') do
      #       describe service('httpd') do
      #         it { should be_enabled }
      #         it { should be_running }
      #       end
      #       # [...]
      #     end
      #   end
      #
      # @example Avoid Automatic OS Detection to Speed Up the Tests
      #   describe docker_build('.', tag: 'myapp') do
      #     describe docker_run('myapp', family: :debian) do
      #       # [...]
      #     end
      #   end
      #
      # @example Using Hash Format
      #   describe docker_build('.', tag: 'myapp') do
      #     describe docker_run(tag: 'myapp', family: :debian) do
      #       # [...]
      #     end
      #   end
      #
      # @example Force a Specific Docker Backend
      #   describe docker_build('.', tag: 'myapp') do
      #     describe docker_run('myapp', backend: :lxc) do
      #       # [...]
      #     end
      #   end
      #
      # @example Use a Backend Not Included by Default
      #   # specinfra-backend-docker_nsenter gem must be installed by hand
      #   require 'specinfra/backend/docker_nsenter'
      #   describe docker_build('.', tag: 'myapp') do
      #     describe docker_run('myapp', backend: :nsenter) do
      #       # [...]
      #     end
      #   end
      #
      # @example Running a Container Image Tag
      #   describe docker_run('debian:8') do
      #     # [...]
      #   end
      #
      # @example Testing `FROM` Dockerfile Instruction
      #   # FROM debian:8
      #   describe docker_run('myapp') do
      #     describe file('/etc/debian_version') do
      #       it { should be_file }
      #       its(:content) { should match /^8\./ }
      #     end
      #     # Another way to check it:
      #     describe command('lsb_release -ri') do
      #       its(:stdout) { should match /^Distributor ID:\s+Debian/ }
      #       its(:stdout) { should match /^Release:\s+8\./ }
      #     end
      #   end
      #
      # @example Testing `COPY` and `ADD` Dockerfile Instructions
      #   # COPY docker-entrypoint.sh /entrypoint.sh
      #   describe docker_run('myapp') do
      #     describe file('/entrypoint.sh') do
      #       it { should be_file }
      #       its(:content) { should match /^exec java -jar myapp\.jar/ }
      #     end
      #   end
      #
      # @example Testing `RUN` Dockerfile Instructions
      #   describe docker_run('myapp') do
      #     # RUN apt-get install -y wget
      #     describe package('wget') do
      #       it { should be_installed }
      #     end
      #     # RUN useradd -g myapp -d /opt/myapp myapp
      #     describe user('myapp') do
      #       it { should exist }
      #       it { should belong_to_group 'myapp' }
      #       it { should have_home_directory '/opt/myapp' }
      #     end
      #   end
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
      # @option opts [Symbol] :family (calculated) The OS family.
      #   It's automatically detected by default, but can be used to
      #   **speed up the tests**. Some possible values:
      #   `:alpine`, `:arch`, `:coreos`, `:debian`, `:gentoo`, `:nixos`,
      #   `:plamo`, `:poky`, `:redhat`, `:suse`.
      # @option opts [Symbol] :backend (calculated) Docker backend to use:
      #   `:docker`, `:lxc`.
      #
      # @return [Dockerspec::ServerspecRunner] Runner object.
      #
      # @raise [Dockerspec::DockerRunArgumentError] Raises this exception when
      #   some required fields are missing.
      #
      # @api public
      #
      def docker_run(*opts)
        runner = Dockerspec::Serverspec::Runner.new(*opts)
        runner.run
      end
    end
  end
end

#
# Add the Dockerspec::Serverspec resources to RSpec core.
#
RSpec::Core::ExampleGroup.class_eval do
  extend Dockerspec::Serverspec::RSpecResources
  include Dockerspec::Serverspec::RSpecResources
end

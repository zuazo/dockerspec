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

require 'dockerspec/configuration'
require 'dockerspec/rspec/settings'
require 'dockerspec/builder'
require 'dockerspec/rspec/resources/its_container'
require 'dockerspec/exceptions'

module Dockerspec
  #
  # Some classes related to RSpec testing framework.
  #
  module RSpec
    #
    # Some resources included inside {RSpec::Core::ExampleGroup} to build and
    # run Docker containers.
    #
    # ## Load the Test Engine You Want to Use
    #
    # If you want to run [Serverspec](http://serverspec.org/) tests, you need
    # to require the `dockerspec/serverspec` path:
    #
    # ```ruby
    # require 'dockerspec/serverspec'
    # ```
    #
    # If you want to run [Infrataster](https://github.com/ryotarai/infrataster)
    # tests, you need to require the `dockerspec/infrataster` path:
    #
    # ```ruby
    # require 'dockerspec/infrataster'
    # ```
    #
    # Of course, you can load both engines:
    #
    # ```ruby
    # require 'dockerspec/serverspec'
    # require 'dockerspec/infrataster'
    # ```
    #
    # ## RSpec Settings
    #
    # * `dockerfile_path`: The dockerfile path.
    # * `rm_build`: Whether to remove the build after the run.
    # * `log_level`: Log level to use by default.
    # * `docker_wait`: Seconds to wait before running the tests.
    # * `container_name`: Docker container to test with Docker Compose.
    #
    # All the RSpec settings are optional.
    #
    # @example RSpec Settings
    #   RSpec.configure do |config|
    #     config.log_level = :silent
    #   end
    #
    module Resources
      #
      # Builds a Docker image.
      #
      # The image can be build from a path or from a string.
      #
      # See the {Dockerspec::Builder::ConfigHelpers} documentation for more
      # information about the available RSpec resource helpers.
      #
      # @example A Simple Example
      #   describe 'My Dockerfile' do
      #     describe docker_build('.') do
      #       it { should have_maintainer /John Doe/ }
      #       it { should have_cmd ['/bin/dash'] }
      #       it { should have_expose '80' }
      #     end
      #   end
      #
      # @example A Complete Example
      #   describe docker_build(path: '.') do
      #     it { should have_maintainer 'John Doe "john.doe@example.com"' }
      #     it { should have_maintainer(/John Doe/) }
      #     it { should have_cmd %w(2 2000) }
      #     it { should have_label 'description' }
      #     it { should have_label 'description' => 'My Container' }
      #     it { should have_expose '80' }
      #     it { should have_expose(/80$/) }
      #     it { should have_env 'container' }
      #     it { should have_env 'container' => 'docker' }
      #     it { should have_env 'PATH' => '/tmp/bin:/sbin:/bin' }
      #     it { should have_entrypoint ['sleep'] }
      #     it { should have_volume '/volume1' }
      #     it { should have_volume %r{/vol.*2} }
      #     it { should have_user 'nobody' }
      #     it { should have_workdir '/opt' }
      #     it { should have_workdir %r{^/op} }
      #     it { should have_onbuild 'RUN echo onbuild' }
      #     it { should have_stopsignal 'SIGTERM' }
      #   end
      #
      # @example Checking the Attribute Values Using the `its` Method
      #   describe docker_build(path: '.') do
      #     its(:maintainer) { should eq 'John Doe "john.doe@example.com"' }
      #     its(:cmd) { should eq %w(2 2000) }
      #     its(:labels) { should include 'description' }
      #     its(:labels) { should include 'description' => 'My Container' }
      #     its(:exposes) { should include '80' }
      #     its(:env) { should include 'container' }
      #     its(:env) { should include 'container' => 'docker' }
      #     its(:entrypoint) { should eq ['sleep'] }
      #     its(:volumes) { should include '/volume1' }
      #     its(:user) { should eq 'nobody' }
      #     its(:workdir) { should eq '/opt' }
      #     its(:onbuilds) { should include 'RUN echo onbuild' }
      #     its(:stopsignal) { should eq 'SIGTERM' }
      #   end
      #
      # @example Checking Its Size and OS
      #   describe docker_build(path: '.') do
      #     its(:size) { should be < 20 * 2**20 } # 20M
      #     its(:arch) { should eq 'amd64' }
      #     its(:os) { should eq 'linux' }
      #   end
      #
      # @example Building from a File
      #   describe docker_build(path: '../dockerfiles/Dockerfile-nginx') do
      #     # [...]
      #   end
      #
      # @example Building from a Template
      #   describe docker_build(template: 'Dockerfile1.erb') do
      #     # [...]
      #   end
      #
      # @example Building from a Template with a Context
      #   describe docker_build(
      #     template: 'Dockerfile1.erb', context: {version: '8'}
      #   ) do
      #     it { should have_maintainer(/John Doe/) }
      #     it { should have_cmd %w(/bin/sh) }
      #     # [...]
      #   end
      #
      # @example Building from a String
      #   describe docker_build(string: "FROM nginx:1.9\n [...]") do
      #     # [...]
      #   end
      #
      # @example Building from a Docker Image ID
      #   describe docker_build(id: '07d362aea98d') do
      #     # [...]
      #   end
      #
      # @example Building from a Docker Image Name
      #   describe docker_build(id: 'nginx:1.9') do
      #     # [...]
      #   end
      #
      # @param opts [String, Hash] The `:path` or a list of options.
      #
      # @option opts [String] :path ('.') The directory or file that contains
      #   the *Dockerfile*. By default tries to read it from the
      #   `DOCKERFILE_PATH` environment variable and uses `'.'` if it is not
      #   set.
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
      # @return [Dockerspec::Builder] Builder object.
      #
      # @raise [Dockerspec::DockerError] For underlaying docker errors.
      #
      # @see Dockerspec::Builder::ConfigHelpers
      #
      # @api public
      #
      def docker_build(*opts)
        builder = Dockerspec::Builder.new(*opts)
        builder.build
        described_image(builder.id)
        builder
      end

      #
      # Runs a docker image.
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
      #     describe docker_run('myapp', family: 'debian') do
      #       # [...]
      #     end
      #   end
      #
      # @example Using Hash Format
      #   describe docker_build('.', tag: 'myapp') do
      #     describe docker_run(tag: 'myapp', family: 'debian') do
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
      # @example Testing with Infrataster
      #   require 'dockerspec/infrataster'
      #   describe docker_run('nginx') do
      #     describe server(described_container) do
      #       describe http('/') do
      #         it 'responds content including "Welcome to nginx!"' do
      #           expect(response.body).to include 'Welcome to nginx!'
      #         end
      #         it 'responds as "nginx" server' do
      #           expect(response.headers['server']).to match(/nginx/i)
      #         end
      #       end
      #     end
      #   end
      #
      # @param opts [String, Hash] The `:tag` or a list of options. This
      #   configuration options will be passed to the Testing Engines like
      #   Infrataster. So you can include your Infrataster server configuration
      #   here.
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
      # @return [Dockerspec::Runner::Docker] Runner object.
      #
      # @raise [Dockerspec::DockerRunArgumentError] Raises this exception when
      #   some required fields are missing.
      #
      # @raise [Dockerspec::EngineError] Raises this exception when the engine
      #   list is empty.
      #
      # @raise [Dockerspec::DockerError] For underlaying docker errors.
      #
      # @api public
      #
      def docker_run(*opts)
        runner = Dockerspec::Configuration.docker_runner.new(*opts)
        runner.run
        runner.restore_rspec_context
        described_container(runner.container_name)
        runner
      end

      #
      # Runs Docker Compose.
      #
      # By default tries to detect the most appropriate Docker backend: native
      # or LXC.
      #
      # @example Testing Containers from a YAML File
      #   describe docker_compose('docker-compose.yml', wait: 15) do
      #     its_container(:myapp) do
      #       describe process('apache2') do
      #         it { should be_running }
      #       end
      #       # [...]
      #     end
      #     its_container(:db) do
      #       describe process('mysqld') do
      #         it { should be_running }
      #       end
      #       # [...]
      #     end
      #   end
      #
      # @example Testing Only One Container from a Directory
      #   describe docker_compose('data/', container: :myapp, wait: 15) do
      #     describe process('apache2') do
      #       it { should be_running }
      #     end
      #     # [...]
      #   end
      #
      # @example Avoid Automatic OS Detection to Speed Up the Tests
      #   describe docker_compose(
      #     'data/', container: :myapp, family: 'debian', wait: 15
      #   ) do
      #     describe process('apache2') do
      #       it { should be_running }
      #     end
      #     # [...]
      #   end
      #
      # @param opts [String, Hash] The `:file` or a list of options.
      #
      # @option opts [String] :file The compose YAML file or a directory
      #   containing the `'docker-compose.yml'` file.
      # @option opts [Symbol, String] :container The name of the container to
      #   test. It is better to use
      #   {Dockerspec::RSpec::Resources#its_container} if you want to test
      #   multiple containers.
      # @option opts [Boolean] :rm (calculated) Whether to remove the Docker
      #   containers afterwards.
      # @option opts [Symbol, String] :family (calculated) The OS family.
      #   It's automatically detected by default, but can be used to
      #   **speed up the tests**. Some possible values:
      #   `:alpine`, `:arch`, `:coreos`, `:debian`, `:gentoo`, `:nixos`,
      #   `:plamo`, `:poky`, `:redhat`, `:suse`.
      # @option opts [Symbol] :backend (calculated) Docker backend to use:
      #   `:docker_compose`, `:docker_compose_lxc`.
      #
      # @return [String] A description of the object.
      #
      # @raise [Dockerspec::DockerRunArgumentError] Raises this exception when
      #   some required fields are missing.
      #
      # @raise [Dockerspec::EngineError] Raises this exception when the engine
      #   list is empty.
      #
      # @raise [Dockerspec::DockerError] For underlaying docker errors.
      #
      # @api public
      #
      def docker_compose(*opts)
        runner = Dockerspec::Configuration.compose_runner.new(*opts)
        runner.run
        # Disable storing Runner object on RSpec metadata, to avoid calling its
        # {Runner#restore_rspec_context} method that it is also called in
        # {ItsContainer#restore_rspec_context}:
        runner.to_s
      end

      #
      # Selects the container to test inside {#docker_compose}.
      #
      # @example Testing Multiple Containers
      #   describe docker_compose('docker-compose.yml', wait: 15) do
      #     its_container(:myapp) do
      #       describe process('apache2') do
      #         it { should be_running }
      #         its(:args) { should match(/-DFOREGROUND/) }
      #       end
      #       # [...]
      #     end
      #     its_container(:db) do
      #       describe process('mysqld') do
      #         it { should be_running }
      #       end
      #       # [...]
      #     end
      #   end
      #
      # @example Avoid Automatic OS Detection to Speed Up the Tests
      #   describe docker_compose('docker-compose.yml', wait: 15) do
      #     its_container('myapp', family: 'centos') do
      #       describe process('httpd') do
      #         it { should be_running }
      #       end
      #       # [...]
      #     end
      #     its_container('db', family: 'debian') do
      #       describe process('mysqld') do
      #         it { should be_running }
      #       end
      #       # [...]
      #     end
      #   end
      #
      # @example Testing a Database with Infrataster using Docker Compose
      #   require 'dockerspec/infrataster'
      #   # After including `gem 'infrataster-plugin-mysql'` in your Gemfile:
      #   require 'infrataster-plugin-mysql'
      #   describe docker_compose('docker-compose.yml', wait: 60) do
      #     its_container(:db, mysql: { user: 'root', password: 'example' }) do
      #       describe server(described_container) do
      #         describe mysql_query('SHOW STATUS') do
      #           it 'returns positive uptime' do
      #             row = results.find { |r| r['Variable_name'] == 'Uptime' }
      #             expect(row['Value'].to_i).to be > 0
      #           end
      #         end
      #       end
      #     end
      #   end
      #
      # @param container [Symbol, String] The name of the container to test.
      #
      # @param opts [Hash] A list of options. This configuration options will
      #   be passed to the Testing Engines like Infrataster. So you can include
      #   your Infrataster server configuration here.
      #
      # @option opts [Symbol, String] :family (calculated) The OS family.
      #   It's automatically detected by default, but can be used to
      #   **speed up the tests**. Some possible values:
      #   `:alpine`, `:arch`, `:coreos`, `:debian`, `:gentoo`, `:nixos`,
      #   `:plamo`, `:poky`, `:redhat`, `:suse`.
      #
      # @yield [] the block to run with the tests.
      #
      # @return void
      #
      # @raise [Dockerspec::DockerComposeError] Raises this exception when
      #   you call `its_container` without calling `docker_compose`.
      #
      # @api public
      #
      def its_container(container, *opts, &block)
        compose = Runner::Compose.current_instance
        if compose.nil?
          raise ItsContainerError, ItsContainer::NO_DOCKER_COMPOSE_MESSAGE
        end
        container_opts = opts[0].is_a?(Hash) ? opts[0] : {}
        its_container = ItsContainer.new(container, compose)
        its_container.restore_rspec_context(container_opts)
        described_container(compose.container_name)
        describe(its_container, *opts, &block)
      end

      #
      # Sets or gets the latest run container name.
      #
      # This can be used to avoid adding a tag to the build image.
      #
      # @example
      #   describe docker_build('.') do
      #     describe docker_run(described_image, family: 'debian') do
      #       # [...]
      #     end
      #   end
      #
      # @param value [String] The docker image id.
      #
      # @return [String] The docker image id.
      #
      # @api public
      #
      def described_image(value = nil)
        # rubocop:disable Style/ClassVars
        @@described_image = value unless value.nil?
        # rubocop:enable Style/ClassVars
        @@described_image
      end

      #
      # Sets or gets the latest run container name.
      #
      # Used to call the Infrataster {#server} method.
      #
      # @example Testing a Docker Container
      #   describe docker_run('myapp') do
      #     describe server(described_container) do
      #       describe http('/') do
      #         it 'responds content including "My App Homepage"' do
      #           expect(response.body).to match(/My App Homepage/i)
      #         end
      #       end
      #     end
      #   end
      #
      # @example Testing with Docker Compose
      #   describe docker_compose('docker-compose.yml', wait: 60) do
      #     its_container(:wordpress) do
      #       describe server(described_container) do
      #         describe http('/wp-admin/install.php') do
      #           it 'responds content including "Wordpress Installation"' do
      #             expect(response.body).to match(/WordPress .* Installation/i)
      #           end
      #         end
      #       end
      #     end
      #   end
      #
      # @param value [Symbol, String] The container name.
      #
      # @return [Symbol] The container name.
      #
      # @api public
      #
      def described_container(value = nil)
        # rubocop:disable Style/ClassVars
        @@described_container = value unless value.nil?
        # rubocop:enable Style/ClassVars
        @@described_container.to_sym
      end
    end
  end
end

#
# Add the Dockerspec resources to RSpec core.
#
RSpec::Core::ExampleGroup.class_eval do
  extend Dockerspec::RSpec::Resources
  include Dockerspec::RSpec::Resources
end

#
# Allow using #docker_build in the outermost example
#
extend Dockerspec::RSpec::Resources

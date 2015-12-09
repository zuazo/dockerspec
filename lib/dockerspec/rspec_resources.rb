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

require 'dockerspec/builder'
require 'dockerspec/runner' # Not really necessary (currently unused)
require 'dockerspec/rspec_settings'
require 'dockerspec/rspec_assertions'

module Dockerspec
  #
  # Some resources included inside {RSpec::Core::ExampleGroup} to build and run
  # Docker containers.
  #
  # ## RSpec Settings
  #
  # * `dockerfile_path`: The dockerfile path.
  # * `rm_build`: Whether to remove the build after the run.
  # * `log_level`: Log level to use by default.
  #
  # All the RSpec settings are optional.
  #
  # @example RSpec Settings
  #   RSpec.configure do |config|
  #     config.log_level = :silent
  #   end
  #
  module RSpecResources
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
    #     it { should have_env 'CRACKER' => 'RANDOM;PATH=/tmp/bin:/sbin:/bin' }
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
    # @example Building from a Docker Image name
    #   describe docker_build(id: 'nginx:1.9') do
    #     # [...]
    #   end
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
    # @option opts [Fixnum, Symbol] :log_level Sets the docker library
    #   verbosity level. Possible values:
    #    `:silent` or `0` (no output),
    #    `:ci` or `1` (enables some outputs recommended for CI environments),
    #    `:info` or `2` (gives information about main build steps),
    #    `:debug` or `3` (outputs all the provided information in its raw
    #      original form).
    #
    # @return [Dockerspec::Builder] Builder object.
    #
    # @see Dockerspec::Builder::ConfigHelpers
    #
    # @api public
    #
    def docker_build(*opts)
      builder = Dockerspec::Builder.new(*opts)
      builder.build
    end

    #
    # Runs a docker image.
    #
    # @param opts [Hash] List of options.
    #
    # @see Dockerspec::Serverspec::RSpecResources#docker_run
    #
    def docker_run(*opts)
      RSpecAssertions.assert_docker_run!(opts)
    end
  end
end

#
# Add the Dockerspec resources to RSpec core.
#
RSpec::Core::ExampleGroup.class_eval do
  extend Dockerspec::RSpecResources
  include Dockerspec::RSpecResources
end

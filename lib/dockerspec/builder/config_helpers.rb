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

module Dockerspec
  class Builder
    #
    # Some helpers to get container image information from its JSON data.
    #
    # **Note:** Keep in mind that not all the available Dockerfile instructions
    # can be checked in the docker image. You should use
    # {Dockerspec::Serverspec::RSpec::Resources#docker_run} to check some
    # instructions like `FROM`, `RUN`, `ADD` and `COPY` (see the examples
    # there).
    #
    module ConfigHelpers
      #
      # Returns the image configuration.
      #
      # @return [Hash] The image configuration.
      #
      # @api public
      #
      def image_config
        @image.json['Config']
      end

      #
      # Returns the image size in bytes.
      #
      # @example RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:size) { should be < 20 * 2**20 } # 20M
      #   end
      #
      # @return [Integer] The image size in bytes.
      #
      # @api public
      #
      def size
        @image.json['VirtualSize']
      end

      #
      # Returns the image architecture.
      #
      # @example RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:arch) { should eq 'amd64' }
      #   end
      #
      # @return [String] The architecture name.
      #
      # @api public
      #
      def architecture
        @image.json['Architecture']
      end

      alias arch architecture

      #
      # Returns the image Operating System.
      #
      # @example RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:os) { should eq 'linux' }
      #   end
      #
      # @return [String] The OS name.
      #
      # @api public
      #
      def os
        @image.json['Os']
      end

      #
      # Returns the image maintainer or author (`MAINTAINER`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:maintainer) { should eq 'John Doe "john.doe@example.com"' }
      #   end
      #
      # @example RSpec Example Using *Have* Matchers
      #   describe docker_build(path: '.') do
      #     it { should have_maintainer 'John Doe "john.doe@example.com"' }
      #   end
      #
      # @example RSpec Example Using a Regular Expression
      #   describe docker_build(path: '.') do
      #     it { should have_maintainer(/John Doe/) }
      #   end
      #
      # @return [String] The maintainer.
      #
      # @api public
      #
      def maintainer
        @image.json['Author']
      end

      #
      # Returns the image command (`CMD`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:cmd) { should eq ['/usr/bin/supervisord'] }
      #   end
      #
      # @example RSpec Example Using *Have* Matchers
      #   describe docker_build(path: '.') do
      #     it { should have_cmd ['/usr/bin/supervisord'] }
      #     # Or in string format:
      #     it { should have_cmd '/usr/bin/supervisord' }
      #   end
      #
      # @return [Array] The image command.
      #
      # @api public
      #
      def cmd
        image_config['Cmd']
      end

      #
      # Returns the image labels (`LABEL`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:labels) { should include 'description' => 'My Container' }
      #   end
      #
      # @example RSpec Example Using *Have* Matchers
      #   describe docker_build(path: '.') do
      #     it { should have_label 'description' => 'My Container' }
      #   end
      #
      # @example RSpec Example Checking Only the Existence of the Label
      #   describe docker_build(path: '.') do
      #     it { should have_label 'description' }
      #   end
      #
      # @return [Hash] The labels list.
      #
      # @api public
      #
      def labels
        image_config['Labels']
      end

      #
      # Returns **the first** label as a string (`LABEL`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:label) { should eq 'description=My Container' }
      #   end
      #
      # @return [String] The first label.
      #
      # @api public
      #
      def label
        labels.first.join('=')
      end

      #
      # Returns the image exposed ports (`EXPOSE`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:exposes) { should include '80' }
      #   end
      #
      # @example RSpec Example Using *Have* Matchers
      #   describe docker_build(path: '.') do
      #     it { should have_expose '80' }
      #   end
      #
      # @example RSpec Example Using *Have* Matchers with Integer Valuess
      #   describe docker_build(path: '.') do
      #     it { should have_expose 80 }
      #   end
      #
      # @example RSpec Example Using Regular Expressions
      #   describe docker_build(path: '.') do
      #     it { should have_expose(/80$/) }
      #   end
      #
      # @return [Array] The exposed ports list.
      #
      # @api public
      #
      def exposes
        image_config['ExposedPorts'].keys.map { |x| x.delete('/tcp') }
      end

      #
      # Returns **the first** exposed port (`EXPOSE`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:expose) { should eq '80' }
      #   end
      #
      # @return [String] The exposed port.
      #
      # @api public
      #
      def expose
        exposes.first
      end

      #
      # Returns the image environment (`ENV`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:env) { should include 'container' => 'docker' }
      #   end
      #
      # @example RSpec Example Using *Have* Matchers
      #   describe docker_build(path: '.') do
      #     it { should have_env 'container' => 'docker' }
      #   end
      #
      # @example RSpec Example Checking Only the Existence of the Env Variable
      #   describe docker_build(path: '.') do
      #     it { should have_env 'container' }
      #   end
      #
      # @return [Hash] The environment.
      #
      # @api public
      #
      def envs
        @env ||=
          image_config['Env'].each_with_object({}) do |var, memo|
            key, value = var.split('=', 2)
            memo[key] = value
          end
      end

      alias env envs

      #
      # Returns the image entrypoint (`ENTRYPOINT`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:entrypoint) { should eq ['/entrypoint.sh'] }
      #   end
      #
      # @example RSpec Example Using *Have* Matchers
      #   describe docker_build(path: '.') do
      #     it { should have_entrypoint ['/entrypoint.sh'] }
      #     # Or in string format:
      #     it { should have_entrypoint '/entrypoint.sh' }
      #   end
      #
      # @return [Array] The image entrypoint.
      #
      # @api public
      #
      def entrypoint
        image_config['Entrypoint']
      end

      #
      # Returns the image volumes (`VOLUME`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:volumes) { should include '/data1' }
      #   end
      #
      # @example RSpec Example Using *Have* Matchers
      #   describe docker_build(path: '.') do
      #     it { should have_volume '/data1' }
      #   end
      #
      # @example RSpec Example Using Regular Expressions
      #   describe docker_build(path: '.') do
      #     it { should have_volume %r{^/data[0-9]+$} }
      #   end
      #
      # @return [Array] The image volume list.
      #
      # @api public
      #
      def volumes
        image_config['Volumes'].keys
      end

      #
      # Returns **the first** volume (`VOLUME`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:volume) { should eq '/data1' }
      #   end
      #
      # @return [String] The first volume.
      #
      # @api public
      #
      def volume
        volumes.first
      end

      #
      # Returns the image user (`USER`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:user) { should eq 'nobody' }
      #   end
      #
      # @example RSpec Example Using *Have* Matchers
      #   describe docker_build(path: '.') do
      #     it { should have_user 'nobody' }
      #   end
      #
      # @return [String] The username.
      #
      # @api public
      #
      def user
        image_config['User']
      end

      #
      # Returns the image workdir (`WORKDIR`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:workdir) { should eq '/opt/myapp' }
      #   end
      #
      # @example RSpec Example Using *Have* Matchers
      #   describe docker_build(path: '.') do
      #     it { should have_workdir '/opt/myapp' }
      #   end
      #
      # @example RSpec Example Using Regular Expressions
      #   describe docker_build(path: '.') do
      #     it { should have_workdir %r{^/opt/myapp} }
      #   end
      #
      # @return [String] The workdir.
      #
      # @api public
      #
      def workdir
        image_config['WorkingDir']
      end

      #
      # Returns the onbuild instructions (`ONBUILD`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:onbuilds) { should include 'RUN echo onbuild' }
      #   end
      #
      # @example RSpec Example Using *Have* Matchers
      #   describe docker_build(path: '.') do
      #     it { should have_onbuild 'RUN echo onbuild' }
      #   end
      #
      # @return [Array] The onbuild instructions.
      #
      # @api public
      #
      def onbuilds
        image_config['OnBuild']
      end

      #
      # Returns **the first** onbuild instruction (`ONBUILD`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:onbuild) { should eq 'RUN echo onbuild' }
      #   end
      #
      # @return [String] The onbuild instruction.
      #
      # @api public
      #
      def onbuild
        onbuilds.first
      end

      #
      # Returns the stop signal (`STOPSIGNAL`).
      #
      # @example Basic RSpec Example
      #   describe docker_build(path: '.') do
      #     its(:stopsignal) { should eq 'SIGTERM' }
      #   end
      #
      # @example RSpec Example Using *Have* Matchers
      #   describe docker_build(path: '.') do
      #     it { should have_stopsignal 'SIGTERM' }
      #   end
      #
      # @return [String] The stop signal name.
      #
      # @api public
      #
      def stopsignal
        image_config['StopSignal']
      end
    end
  end
end

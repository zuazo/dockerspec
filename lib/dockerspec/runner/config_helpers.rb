# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2017 Xabier de Zuazo
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
  module Runner
    #
    # Some helpers to get information from a running container.
    #
    module ConfigHelpers
      #
      # Parse the stdout/stderr log binary stream.
      #
      # @example
      #   parse_log("String1") #=> "String1"
      #   parse_log("\x02\x00\x00\x00\x00\x00\x00\aSTDERR") #=> "STDERR"
      #
      # @param log [String] log to parse in binary format.
      # @return [String] parsed log.
      #
      # @api private
      #
      def parse_log(log)
        log.sub(/^.*?\a/, '')
      end

      #
      # Returns the container *stdout* logs.
      #
      # @example Docker Run Example
      #   describe docker_run('mysql') do
      #     its(:stdout) { should include 'MySQL init process done.' }
      #   end
      #
      # @example Docker Compose Example
      #   describe docker_compose('.', wait: 30) do
      #     describe its_container(:db) do
      #       its(:stdout) { should include 'MySQL init process done.' }
      #     end
      #   end
      #
      # @return [String] The *stdout* logs.
      #
      # @raise [Dockerspec::RunnerError] When cannot select the container to
      #  test.
      #
      # @api public
      #
      def stdout
        log = container.logs(stdout: true)
        parse_log(log)
      end

      #
      # Returns the container *stderr* logs.
      #
      # @example Docker Run Example
      #   describe docker_run('mysql') do
      #     its(:stderr) { should include 'mysqld: ready for connections.' }
      #   end
      #
      # @example Docker Compose Example
      #   describe docker_compose('.', wait: 30) do
      #     describe its_container(:myapp) do
      #       its(:stderr) { should eq '' }
      #     end
      #   end
      #
      # @return [String] The *stderr* logs.
      #
      # @raise [Dockerspec::RunnerError] When cannot select the container to
      #  test.
      #
      # @api public
      #
      def stderr
        log = container.logs(stderr: true).to_s
        parse_log(log)
      end
    end
  end
end

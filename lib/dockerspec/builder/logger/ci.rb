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

require 'dockerspec/builder/logger/info'

module Dockerspec
  class Builder
    class Logger
      #
      # A {Dockerspec::Builder} logger recommended for CI environments with
      # output timeouts.
      #
      class CI < Info
        #
        # Creates a CI logger instance.
        #
        # @param output [IO] the output stream.
        #
        # @api public
        #
        def initialize(output = STDOUT)
          super
          @buffer = ''
          @skip = false
        end

        protected

        #
        # Print a Docker build stream in the proper format.
        #
        # @param stream [String] The stream in raw.
        #
        # @return void
        #
        # @api private
        #
        def print_stream(stream)
          if stream.match(/^Step /)
            @buffer = stream
            @skip = true
          else
            @buffer += stream
            @skip = false if stream.match(/^ ---> (Running in|\[Warning\]) /)
          end
          return if @skip
          @output.puts @buffer
          @buffer = ''
        end
      end
    end
  end
end

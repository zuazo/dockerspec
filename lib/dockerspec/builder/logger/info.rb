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
    class Logger
      #
      # A {Dockerspec::Builder} logger that gives information about main build
      # steps.
      #
      class Info
        #
        # Creates a Info logger instance.
        #
        # @param output [IO] the output stream.
        #
        # @api public
        #
        def initialize(output = STDOUT)
          @output = output
          @status = nil
        end

        #
        # Prints the Docker build chunk.
        #
        # @param chunk [Hash] The docker build chunk.
        #
        # @return void
        #
        # @api public
        #
        def print_chunk(chunk)
          chunk_json = parse_chunk(chunk)
          print_status(chunk_json['status'])
          return unless chunk_json.key?('stream')
          print_stream(chunk_json['stream'])
        end

        protected

        #
        # Parses the Docker build process chunk.
        #
        # @param chunk [String] The chunk in JSON.
        #
        # @return [Hash] The chunk parsed as a Hash.
        #
        # @api private
        #
        def parse_chunk(chunk)
          return chunk if chunk.is_a?(Hash)
          JSON.parse(chunk)
        rescue JSON::ParserError
          { 'stream' => chunk }
        end

        #
        # Prints progress status in a shorter format.
        #
        # For example: `'Downloading.....\nExtracting..`'.
        #
        # @param status [String] The name of the current status.
        #
        # @return void
        #
        # @api private
        #
        def print_status(status)
          if status != @status
            @output.puts
            @status = status
            @output.print "#{status}." unless status.nil?
          elsif !status.nil?
            @output.print '.'
          end
          @output.flush
        end

        #
        # Prints the stream.
        #
        # @param stream [String] The text to print.
        #
        # @return void
        #
        # @api private
        #
        def print_stream(stream)
          @output.puts stream
        end
      end
    end
  end
end

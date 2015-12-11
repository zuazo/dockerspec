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

require 'json'
require 'dockerspec/exceptions'

module Dockerspec
  #
  # A class to parse `Docker::Error` exceptions.
  #
  class DockerExceptionParser
    #
    # Parses Docker exceptions.
    #
    # Raises the same exception if the format is unknown.
    #
    # @example
    #   rescue ::Docker::Error::DockerError => e
    #     DockerExceptionParser.new(e)
    #   end
    #
    # @param e [Exception] The exception object to parse.
    #
    # @raise [Dockerspec::DockerError] When the exception format is known.
    # @raise [Exception] When the exception format is unknown.
    #
    # @api public
    #
    def initialize(e)
      e_ary = parse_exception(e)
      raise_docker_error_exception(e_ary)
      fail e
    end

    protected

    #
    # Parses the exception JSON message.
    #
    # The message must be a list of JSON messages merged by a new line.
    #
    # A valid exception message example:
    #
    # ```
    # {"stream":"Step 1 : FROM alpine:3.2\n"}
    # {"stream":" ---\u003e d6ead20d5571\n"}
    # {"stream":"Step 2 : RUN apk add --update wrong-package-name\n"}
    # {"stream":" ---\u003e Running in 290a46fa8bf4\n"}
    # {"stream":"fetch http://dl-4.alpinelinux.org/alpine/v3.2/main/...\n"}
    # {"stream":"ERROR: unsatisfiable constraints:\n"}
    # {"stream":"  wrong-package-name (missing):\n    required by: world...\n"}
    # {"errorDetail":{"message":"The command ..."},"error":"The command ..."}
    # ```
    #
    # @example
    #   self.parse_exception(e)
    #   #=> [{ "stream" => "Step 1 : FROM alpine:3.2\n" }, "errorDetail" => ...
    #
    # @param e [Exception] The exception object to parse.
    #
    # @return [Array<Hash>] The list of JSON messages parsed.
    #
    # @return
    #
    # @api private
    #
    def parse_exception(e)
      msg = e.to_s
      json = msg.to_s.sub(/^Couldn't find id: /, '').split("\n").map(&:chomp)
      json.map { |str| JSON.parse(str) }
    rescue JSON::ParserError
      raise e
    end

    #
    # Gets the error message from the *errorDetail* field.
    #
    # @param e_ary [Array<Hash>] The list of JSON messages already parsed.
    #
    # @return [String] The error message string.
    #
    # @api private
    #
    def parse_error_detail(e_ary)
      e_detail = e_ary.select { |x| x.is_a?(Hash) && x.key?('errorDetail') }[0]
      return nil unless e_detail.is_a?(Hash)
      return e_detail['message'] if e_detail.key?('message')
      return e_detail['error'] if e_detail.key?('error')
    end

    #
    # Gets all the console output from the stream logs.
    #
    # @param e_ary [Array<Hash>] The list of JSON messages already parsed.
    #
    # @return [String] The generated stdout output.
    #
    # @api private
    #
    def parse_streams(e_ary)
      e_ary.map { |x| x.is_a?(Hash) && x['stream'] }.compact.join
    end

    #
    # Generates a formated error message.
    #
    # @param error [String] The error message.
    # @param output [String] The generated stdout output.
    #
    # @return [String] The resulting error message.
    #
    # @api private
    #
    def generate_error_message(error, output)
      [
        "#{error}\n",
        "OUTPUT: \n#{output.gsub(/^/, ' ' * 8)}",
        "ERROR:  #{error}\n\n"
      ].join("\n")
    end

    #
    # Raises the right {Dockerspec::DockerError} exception.
    #
    # Nothing is raised if the exception format is unknown.
    #
    # @param e_ary [Array<Hash>] The list of JSON messages already parsed.
    #
    # @return void
    #
    # @raise [Dockerspec::DockerError] When the exception format is known.
    #
    # @api private
    #
    def raise_docker_error_exception(e_ary)
      e_ary.select { |x| x.is_a?(Hash) && x.key?('errorDetail') }[0]
      output = parse_streams(e_ary)
      error_msg = parse_error_detail(e_ary)
      return if error_msg.nil?
      fail DockerError, generate_error_message(error_msg, output)
    end
  end
end

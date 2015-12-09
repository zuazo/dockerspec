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

require 'rspec'
require 'rspec/its'
require 'erubis'
require 'dockerspec/docker_gem'
require 'dockerspec/builder/config_helpers'
require 'dockerspec/builder/matchers'
require 'dockerspec/builder/logger'
require 'dockerspec/builder/image_gc'
require 'dockerspec/helper/ci'

module Dockerspec
  module Helper
    #
    # Methods to generate the correct object description for objects that
    # has a source attribute.
    #
    # Shortens the docker IDs automatically.
    #
    # Requirements:
    #
    # - `source` method: Returns the source you are using to generating your
    #     object.
    # - `:@options` attribute: The options array with the configuration
    #     options, including the source.
    #
    # Used by the {Dockerspec::Builder} and {Dockerspec::Runner} classes.
    #
    module MultipleSourcesDescription
      #
      # Generates a description of the object.
      #
      # @example
      #   self.description('Docker Build from')
      #     #=> "Docker Build from path: \".\""
      #
      # @param prefix [String] The prefix to add to the description.
      #
      # @return [String] The object description.
      #
      # @api private
      #
      def description(prefix)
        value = @options[source]
        desc = send("description_from_#{source}", value)
        "#{prefix} #{source.to_s.tr('_', ' ')}: \"#{desc}\""
      end

      protected

      #
      # Generates an adequate description of a Docker object description.
      #
      # Essentially it shortens the docker identifiers.
      #
      # @example
      #   self.description_from_docker_object('debian') #=> "debian"
      #   self.description_from_docker_object('92cc98ab560a92cc98ab560[...]')
      #     #=> "92cc98ab560a"
      #
      # @param str [String] The description.
      #
      # @return [String] The description, shortened if necessary.
      #
      # @api private
      #
      def description_from_docker(str)
        return str unless str.match(/^[0-9a-f]+$/)
        str[0..11]
      end

      #
      # Generates a description from Docker ID.
      #
      alias_method :description_from_id, :description_from_docker

      #
      # Generates a description from string.
      #
      # shortens the string.
      #
      # @example
      #   self.description_from_string #=> "FROM nginx:1..."
      #
      # @return [String] A description.
      #
      # @api private
      #
      def description_from_string(str)
        len = 12
        return str unless str.length > len
        "#{str[0..len - 1]}..." # Is this length correct?
      end

      #
      # Generates a description of a file.
      #
      # Basically expands the path.
      #
      # @example
      #   self.description_from_file("mydir") #=> "mydir"
      #
      # @return [String] A description.
      #
      # @api private
      #
      def description_from_file(str)
        File.expand_path(str)
      end

      #
      # Generates a description of a file.
      #
      # @example
      #   self.description_from_template("mydir") #=> "mydir"
      #
      # @return [String] A description.
      #
      # @api private
      #
      alias_method :description_from_path, :description_from_file
    end
  end
end

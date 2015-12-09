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
  module Helper
    #
    # Some Helper methods to work with RSpec Examples.
    #
    module RSpecExampleHelpers
      #
      # Searches for an object in the description of the parent RSpec examples.
      #
      # @param metadata [Hash] RSpec metadata.
      # @param klass [Class] Type of object to search.
      #
      # @return [Object] Returns the object if found. `nil` if not found.
      #
      # @api public
      #
      def self.search_object(metadata, klass)
        return metadata if metadata.nil?
        if metadata[:described_class].is_a?(klass)
          metadata[:described_class]
        elsif metadata.key?(:parent_example_group)
          search_object(metadata[:parent_example_group], klass)
        elsif metadata.key?(:example_group)
          search_object(metadata[:example_group], klass)
        end
      end
    end
  end
end

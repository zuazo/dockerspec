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

module Dockerspec
  module Helper
    #
    # Some Helper methods to work with RSpec Examples.
    #
    module RSpecExampleHelpers
      #
      # Checks if the parent RSpec example information exists in the metadata.
      #
      # @param metadata [Hash] RSpec metadata.
      #
      # @return [Boolean] Returns true if the parent metadata is available.
      #
      # @api private
      #
      def self.metadata_has_parent?(metadata)
        metadata.key?(:parent_example_group) || metadata.key?(:example_group)
      end

      #
      # Get the parent RSpec example metadata if available.
      #
      # @param metadata [Hash] RSpec metadata.
      #
      # @return [Hash] RSpec metadata from the parent example.
      #
      # @api private
      #
      def self.metadata_parent(metadata)
        if metadata.key?(:parent_example_group)
          metadata[:parent_example_group]
        elsif metadata.key?(:example_group)
          metadata[:example_group]
        end
      end

      #
      # Searches for an object in the description of the parent RSpec examples
      # that implements a specific method.
      #
      # @param metadata [Hash] RSpec metadata.
      # @param meth [Symbol] The method name.
      # @param arity [Integer] The arity of the method.
      #
      # @return [Array<Object>] Returns the objects list.
      #
      # @api public
      #
      def self.search_objects_with(metadata, meth, arity)
        o_ary = []
        return o_ary if metadata.nil?
        if metadata[:described_class].respond_to?(meth) &&
           metadata[:described_class].method(meth).arity == arity
          o_ary << metadata[:described_class]
        end
        return o_ary unless metadata_has_parent?(metadata)
        search_objects_with(metadata_parent(metadata), meth, arity) + o_ary
      end

      #
      # Restores the Docker running container instance in the Specinfra
      # internal reference.
      #
      # Gets the correct {Runner::Base} reference from the RSpec metadata.
      #
      # @example Restore Specinfra Backend
      #   RSpec.configure do |c|
      #     c.before(:each) do
      #       metadata = RSpec.current_example.metadata
      #       Dockerspec::Runner::Base.restore(metadata)
      #     end
      #   end
      #
      # @param metadata [Hash] RSpec metadata.
      #
      # @return void
      #
      # @api public
      #
      # @see restore
      #
      def self.restore_rspec_context(metadata)
        o_ary =
          Helper::RSpecExampleHelpers
          .search_objects_with(metadata, :restore_rspec_context, 0)
        o_ary.each(&:restore_rspec_context)
      end
    end
  end
end

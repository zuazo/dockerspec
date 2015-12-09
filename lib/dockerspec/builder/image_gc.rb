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

require 'singleton'
require 'dockerspec/docker_gem'

module Dockerspec
  class Builder
    #
    # A class to manage docker image deletion. The class stores the images
    # created by {Dockerspec::Builder} objects and deletes them at the end of
    # the Ruby/RSpec run.
    #
    class ImageGC
      include Singleton

      #
      # The Image Garbage Collector constructor.
      #
      # @api public
      #
      def initialize
        @images = []
        ObjectSpace.define_finalizer(self, proc { finalize })
      end

      #
      # Adds a Docker image to be garbage deleted at the end.
      #
      # @param image [String] Docker image ID.
      #
      # @return void
      #
      # @api public
      #
      def add(image)
        @images << image
      end

      #
      # Removes all the Docker images.
      #
      # Automatically called at the end of the RSpec/Ruby run.
      #
      # @return void
      #
      # @api public
      #
      def finalize
        @images.each { |i| ::Docker::Image.remove(i, force: true) }
        @images = []
      end
    end
  end
end

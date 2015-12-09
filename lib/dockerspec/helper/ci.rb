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
    # Some helper methods for detecting Continuous Integration environments.
    #
    module CI
      #
      # Returns whether we are running on a [Continuous Integration]
      # (https://en.wikipedia.org/wiki/Continuous_integration) machine.
      #
      # @return [Boolean] `true` if we are inside a CI.
      #
      # @api public
      #
      def ci?
        ENV['CI'] == 'true'
      end

      #
      # Returns whether we are running on [Travis CI](https://travis-ci.org/).
      #
      # @return [Boolean] `true` if we are inside Travis CI.
      #
      # @api public
      #
      def travis_ci?
        ENV['TRAVIS_CI'] == 'true'
      end

      #
      # Returns whether we are running on [CircleCI](https://circleci.com/).
      #
      # @return [Boolean] `true` if we are inside CircleCI.
      #
      # @api public
      #
      def circle_ci?
        ENV['CIRCLECI'] == 'true'
      end
    end
  end
end

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

require 'dockerspec/exceptions'

module Dockerspec
  #
  # Some helper methods to check {Dockerspec::RSpecResources#docker_run}`
  # arguments and output understandable error messages.
  #
  module RSpecAssertions
    #
    # A message with description on how to avoid the error in
    # {Dockerspec::Serverspec::Runner#docker_run}
    #
    DOCKER_RUN_ALWAYS_MESSAGE = <<-EOE

Remember to include the Serverspec library:

    require 'dockerspec'
    require 'dockerspec/serverspec'

     EOE

    #
    # Raises and exception with instructions on how to fix it.
    #
    # @raise [Dockerspec::DockerRunArgumentError] Raises this exception always.
    #
    # @return void
    #
    # @api private
    #
    def self.assert_docker_run!(_opts)
      fail DockerRunArgumentError, DOCKER_RUN_ALWAYS_MESSAGE
    end
  end
end

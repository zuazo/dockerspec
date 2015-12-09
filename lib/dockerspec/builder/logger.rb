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

require 'dockerspec/builder/logger/silent'
require 'dockerspec/builder/logger/ci'
require 'dockerspec/builder/logger/info'
require 'dockerspec/builder/logger/debug'

module Dockerspec
  class Builder
    #
    # Creates an output logger for the {Dockerspec::Builder}.
    #
    class Logger
      #
      # Creates a logger object.
      #
      # @param type [Fixnum, Symbol] The logger to create. Possible values:
      #    `:silent` or `0` (no output),
      #    `:ci` or `1` (enables some outputs recommended for CI environments),
      #    `:info` or `2` (gives information about main build steps),
      #    `:debug` or `3` (outputs all the provided information in its raw
      #      original form).
      #
      # @return [Dockerspec::Builder::Logger] The logger.
      #
      # @api public
      #
      def self.instance(type)
        case type.to_s.downcase
        when '0', 'silent' then Silent.new
        when '1', 'ci' then CI.new
        when '2', 'info' then Info.new
        else
          Debug.new
        end
      end
    end
  end
end

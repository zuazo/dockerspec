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

require 'specinfra/backend/base'

#
# Add a method to the {Specinfra::Backend::Base} singleton class to set its
# internal backend.
#
# TODO: This hack makes me want to poke my own eyes out.
#
Specinfra::Backend::Base.class_eval do
  #
  # Sets the internal backend instance.
  #
  # @param instance [Specinfra::Backend::Base] the backend object.
  #
  # @return [Specinfra::Backend::Base]
  #
  # @api public
  #
  def self.instance_set(instance)
    return if @instance == instance
    property[:host_inventory] = property[:os] = nil
    @instance = instance
  end
end

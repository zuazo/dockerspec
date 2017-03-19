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

#
# Some very opinionated RSpec configuration.
#
# This may change in the future.
#
RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation if config.formatters.empty?
  config.tty = $stdout.tty? if config.tty.nil?

  # rspec-retry
  config.verbose_retry = true if ENV['CI'] == 'true'
  config.default_sleep_interval = 1
end

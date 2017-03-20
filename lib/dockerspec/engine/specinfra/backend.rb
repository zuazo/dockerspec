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

require 'specinfra/backend/base'
require 'dockerspec/engine/specinfra/backend_hack'

module Dockerspec
  module Engine
    class Specinfra < Base
      #
      # A class to handle the underlying Specinfra backend.
      #
      # This class saves Specinfra instance in internally and then it is able
      # to recover it from there and setup the running environment accordingly.
      #
      # This class uses a small hack in the Specinfra class to reset its
      # internal singleton instance.
      #
      class Backend
        #
        # The Specinfra backend constructor.
        #
        # @param backend [Symbol, Specinfra::Backend::Base, Class] The backend
        #   can be the backend name as a symbol, a Specinfra backend object or
        #   a Specinfra backend class.
        #
        # @api public
        #
        def initialize(backend)
          @backend = backend
        end

        #
        # Saves the Specinfra backend instance reference internally.
        #
        # @return void
        #
        # @api public
        #
        def save
          @saved_backend_name = ::Specinfra.configuration.backend
          @saved_backend_instance = backend_instance
        end

        #
        # Restores the Specinfra backend instance.
        #
        # @return void
        #
        # @api public
        #
        def restore
          backend_class.instance_set(@saved_backend_instance)
          if ::Specinfra.configuration.backend != @saved_backend_name
            backend_class.host_reset
            ::Specinfra.configuration.backend = @saved_backend_name
          end
        end

        #
        # Restores the testing context for a container.
        #
        # Used with Docker Compose to choose the container to test.
        #
        # @param container_name [String, Symbol] The name of the container.
        #
        # @return void
        #
        # @api public
        #
        def restore_container(container_name)
          current_container_name =
            ::Specinfra.configuration.docker_compose_container
          return if current_container_name == container_name
          ::Specinfra.configuration.docker_compose_container(container_name)
          # TODO: Save the host family instead of always reseting it:
          backend_class.host_reset
        end

        #
        # Resets the Specinfra backend.
        #
        # @return void
        #
        # @api public
        #
        def reset
          backend_class.instance_set(nil)
        end

        #
        # Gets the internal attribute value from the Specinfra backend object.
        #
        # Used mainly to get information from the running containers like their
        # name or their IP address.
        #
        # @return [Mixed] The value of the attribute to read.
        #
        # @api public
        #
        def backend_instance_attribute(name)
          backend_instance.instance_variable_get("@#{name}".to_sym)
        end

        protected

        #
        # Returns the current Specinfra backend object.
        #
        # @return [Specinfra::Backend::Base] The Specinfra backend object.
        #
        # @api private
        #
        def backend_instance
          backend_class.instance
        end

        #
        # Returns the current Specinfra backend class.
        #
        # @return [Class] The Specinfra backend class.
        #
        # @api private
        #
        def backend_class
          @backend_class ||= begin
            return @backend.class if @backend.is_a?(::Specinfra::Backend::Base)
            ::Specinfra::Backend.const_get(@backend.to_s.to_camel_case)
          end
        end
      end
    end
  end
end

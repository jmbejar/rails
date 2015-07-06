require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/indifferent_access'

module ActionDispatch
  module Http
    module Parameters
      PARAMETERS_KEY = 'action_dispatch.request.path_parameters'

      # Returns both GET and POST \parameters in a single hash.
      def parameters
        @env["action_dispatch.request.parameters"] ||= begin
          params = begin
            request_parameters.merge(query_parameters)
          rescue EOFError
            query_parameters.dup
          end
          params.merge!(path_parameters)
        end
      end
      alias :params :parameters

      def path_parameters=(parameters) #:nodoc:
        @env.delete('action_dispatch.request.parameters')
        @env[PARAMETERS_KEY] = parameters
      end

      # Returns a hash with the \parameters used to form the \path of the request.
      # Returned hash keys are strings:
      #
      #   {'action' => 'my_action', 'controller' => 'my_controller', format => 'html'}
      def path_parameters
        @env[PARAMETERS_KEY] ||= default_path_parameters
      end

    private

      # Convert nested Hash to HashWithIndifferentAccess.
      #
      def normalize_encode_params(params)
        ActionDispatch::Request::Utils.normalize_encode_params params
      end

      def default_path_parameters
        if format = format_from_path_extension
          { 'format' => format }
        else
          {}
        end
      end

      def format_from_path_extension
        path = @env['action_dispatch.original_path']
        if match = path.match(/\.(\w+)$/)
          match.captures.first
        end
      end
    end
  end
end

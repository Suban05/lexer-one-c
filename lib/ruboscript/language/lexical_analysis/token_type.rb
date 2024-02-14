# frozen_string_literal: true

module Ruboscript
  module Language
    module LexicalAnalysis
      class TokenType
        attr_reader :type, :regex, :error_message

        def initialize(type, regex, error_message)
          @type = type
          @regex = regex
          @error_message = error_message
        end
      end
    end
  end
end

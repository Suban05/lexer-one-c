# frozen_string_literal: true

module Ruboscript
  module Language
    module LexicalAnalysis
      class Token
        attr_accessor :token_type, :text, :position

        def initialize(token_type, text, position)
          @token_type = token_type
          @text = text
          @position = position
        end
      end
    end
  end
end

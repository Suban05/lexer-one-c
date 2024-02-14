# frozen_string_literal: true

module Ruboscript
  module Language
    module LexicalAnalysis
      class Lexer
        attr_reader :code, :current_column, :current_line, :token_list, :current_token

        include Language::Enums

        # code - String - input programming code
        def initialize(code = '')
          @code = code
          @current_column = OUT_OF_TEXT
          @token_list = []
          @current_line = OUT_OF_TEXT
          default_values_of_line unless @code.empty?
        end

        # Generates token list.
        # returns @token_list
        def lex_analysis
          while next_token
          end
          @token_list = @token_list.filter do |token|
            token.token_type.type != :white_space && token.token_type.type != :new_line
          end
          @token_list
        end

        # Moves to the next token by code
        # returns Bool
        def next_token
          @current_column = 0 if is_out_of_text?(@current_column)
          @current_line = 1 if is_out_of_text?(@current_line)

          return reset if @current_column >= @code.length

          token_types_values = token_type_list
          token_types_values.each do |token_type|
            regex = /^#{token_type.regex}/i
            result = regex.match(code[@current_column..])
            next unless result && result[0]
            text = result[0].to_s
            @current_token = Token.new(token_type, text, @current_column)
            @current_column += text.length
            @token_list << @current_token
            @current_line += 1 if token_type.type == :new_line

            return true
          end
          raise "Ошибка в строке #{@current_line},#{@current_column} / #{@current_token.token_type.error_message}"
        end

        private

        def default_values_of_line
          @current_column = 0 if is_out_of_text?(@current_column)
          @current_line = 1 if is_out_of_text?(@current_line)
        end

        def reset
          @current_column = OUT_OF_TEXT
          @current_line = OUT_OF_TEXT
          @current_token = nil
          false
        end
      end
    end
  end
end

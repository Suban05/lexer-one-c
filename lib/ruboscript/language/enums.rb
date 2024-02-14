# frozen_string_literal: true

module Ruboscript
  module Language
    module Enums
      OUT_OF_TEXT = -1

      def is_out_of_text?(value)
        value == OUT_OF_TEXT
      end

      def token_type_list
        list = []
        keywords.each do |keyword|
          list << token_type(type: :keyword, regex: /\b#{keyword}\b/i, error_message: 'Ошибка в выражении')
        end
        list = list.union(tokens)
      end

      private

      def tokens
        [
          token_type(type: :new_line, regex: /\n/i, error_message: 'Неизвестная операция'),
          token_type(type: :punctuation, regex: /[\[\]:(),;]/i, error_message: 'Неизвестная операция'),
          token_type(type: :annotation, regex: /&.*$/i, error_message: 'Неизвестная операция'),
          token_type(type: :comment, regex: %r{//.*?(\w\b)}i, error_message: 'Неизвестная операция'),
          token_type(type: :preproc, regex: /\#.*$/, error_message: 'Неизвестная операция'),
          token_type(type: :operator, regex: %r{[-+\/=<>.*?&%]+}i, error_message: 'Неизвестная операция'),
          token_type(type: :number, regex: /\b\d+\.?\d*\b/i, error_message: 'Неизвестная операция'),
          token_type(type: :method_name, regex: /[\wа-яё]+(?=(\s?\())/i, error_message: 'Неизвестная операция'),
          token_type(type: :variable_name, regex: /[\wа-яё]+/i, error_message: 'Неизвестная операция'),
          token_type(type: :string, regex: /".*?("|$)/i, error_message: 'Некорректный строковый литерал!'),
          token_type(type: :new_line_string, regex: /\|.*?("|$)/i, error_message: 'Неизвестная операция'),
          token_type(type: :date, regex: /'.*?'/i, error_message: 'Некорректный литерал даты!'),
          token_type(type: :white_space, regex: /[^\S\n]+/i, error_message: 'Неизвестная операция')
        ]
      end

      def keywords
        %w[
          Перем Var
          Неопределено Undefined
          Истина True
          Ложь False
          NULL
          Процедура Procedure Функция Function
          Экспорт Export
          КонецПроцедуры EndProcedure КонецФункции EndFunction
          Прервать Break Продолжить Continue Возврат Return
          Если If Иначе Else ИначеЕсли ElsIf
          Тогда Then КонецЕсли EndIf
          Попытка Try Исключение Except
          КонецПопытки EndTry ВызватьИсключение Raise
          Пока While Для For Каждого Each
          Из In По To Цикл Do КонецЦикла EndDo
          НЕ NOT И AND ИЛИ OR
          Новый New
          Знач Val
          Перейти Goto
          Асинх Async
          Ждать Await
        ]
      end

      def token_type(args)
        LexicalAnalysis::TokenType.new(args[:type], args[:regex], args[:error_message])
      end
    end
  end
end

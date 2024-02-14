# frozen_string_literal: true

require 'test_helper'

class LexerTest < Minitest::Test
  def setup
    @out_of_text = Ruboscript::Language::Enums::OUT_OF_TEXT
    @lexer = Ruboscript::Language::LexicalAnalysis::Lexer
  end

  def test_empty_lexer_position_is_negative
    lexer = @lexer.new
    assert_equal(lexer.current_column, @out_of_text)
    assert_equal(lexer.current_line, @out_of_text)
  end

  def test_basics
    code = 'Б = 1;'
    lexer = @lexer.new(code)
    assert_equal(lexer.current_line, 1)
    assert_nil(lexer.current_token)

    assert(lexer.next_token)
    assert_equal(lexer.current_line, 1)
    assert_equal(lexer.current_token.text, 'Б')
    assert_equal(lexer.current_token.position, 0)

    assert(lexer.next_token)
    assert_equal(lexer.current_line, 1)
    assert_equal(lexer.current_token.text, ' ')
    assert_equal(lexer.current_token.position, 1)

    assert(lexer.next_token)
    assert_equal(lexer.current_line, 1)
    assert_equal(lexer.current_token.text, '=')
    assert_equal(lexer.current_token.position, 2)

    assert(lexer.next_token)
    assert_equal(lexer.current_line, 1)
    assert_equal(lexer.current_token.text, ' ')
    assert_equal(lexer.current_token.position, 3)

    assert(lexer.next_token)
    assert_equal(lexer.current_line, 1)
    assert_equal(lexer.current_token.text, '1')
    assert_equal(lexer.current_token.position, 4)

    assert(lexer.next_token)
    assert_equal(lexer.current_line, 1)
    assert_equal(lexer.current_token.text, ';')
    assert_equal(lexer.current_token.position, 5)

    refute(lexer.next_token)
    assert_nil(lexer.current_token)
    assert_equal(lexer.current_column, @out_of_text)
    assert_equal(lexer.current_line, @out_of_text)
  end

  def test_multiline_string_of_code
    code =
      "А = 1;
      Б = 2;
      // comment
      В = 7-11;
      Г = 8"
    lexer = @lexer.new(code)
    lexer.next_token while lexer.current_line < 4
    assert_equal(lexer.current_line, 4)
    assert_equal(lexer.current_token.token_type.type, :new_line)
    # skipping whitespace
    lexer.next_token
    assert_equal(lexer.current_line, 4)
    lexer.next_token
    assert_equal(lexer.current_line, 4)
    assert_equal(lexer.current_token.text, 'В')

    lexer.next_token
    assert_equal(lexer.current_line, 4)
    assert_equal(lexer.current_token.text, ' ')

    lexer.next_token
    assert_equal(lexer.current_line, 4)
    assert_equal(lexer.current_token.text, '=')

    lexer.next_token
    assert_equal(lexer.current_line, 4)
    assert_equal(lexer.current_token.text, ' ')

    lexer.next_token
    assert_equal(lexer.current_line, 4)
    assert_equal(lexer.current_token.text, '7')
    assert_equal(lexer.current_token.token_type.type, :number)

    lexer.next_token
    assert_equal(lexer.current_line, 4)
    assert_equal(lexer.current_token.text, '-')

    lexer.next_token
    assert_equal(lexer.current_line, 4)
    assert_equal(lexer.current_token.text, '11')
    assert_equal(lexer.current_token.token_type.type, :number)


    lexer.next_token
    assert_equal(lexer.current_line, 4)
    assert_equal(lexer.current_token.text, ';')
  end

  def test_current_column_calculation
    code =
      "А = 1;
      Б = 2;
      В = 7-11;
      Г = 8"
    lexer = @lexer.new(code)
    lexer.next_token while lexer.current_line < 3
    assert_equal(lexer.current_line, 3)
    # skipping whitespace
    lexer.next_token
    assert_equal(lexer.current_line, 3)
    lexer.next_token
    assert_equal(lexer.current_token.text, 'В')
    assert_equal(lexer.current_token.position, 26)
  end

  def test_variable_name_works_fine
    code = "\ndddddd-"
    lexer = @lexer.new(code)
    lexer.next_token
    lexer.next_token
    assert_equal(lexer.current_token.text, 'dddddd')
    assert_equal(lexer.current_token.token_type.type, :variable_name)
  end

  def test_builtin_tokens_as_usual_words
    code = 'Лев СтрДлина Прав'
    lexer = @lexer.new(code)
    lexer.next_token
    assert_equal(lexer.current_token.text, 'Лев')
    assert_equal(lexer.current_token.token_type.type, :variable_name)

    lexer.next_token
    assert_equal(lexer.current_token.text, ' ')
    assert_equal(lexer.current_token.token_type.type, :white_space)

    lexer.next_token
    assert_equal(lexer.current_token.text, 'СтрДлина')
    assert_equal(lexer.current_token.token_type.type, :variable_name)

    lexer.next_token
    assert_equal(lexer.current_token.text, ' ')
    assert_equal(lexer.current_token.token_type.type, :white_space)

    lexer.next_token
    assert_equal(lexer.current_token.text, 'Прав')
    assert_equal(lexer.current_token.token_type.type, :variable_name)
  end

  def test_string_works_fine
    code = '"test string"'
    lexer = @lexer.new(code)
    lexer.next_token
    assert_equal(lexer.current_token.text, '"test string"')
  end

  def test_string_variable_works_fine
    code = 'variable = "-- test string";'
    lexer = @lexer.new(code)
    lexer.next_token

    assert_equal(lexer.current_token.text, 'variable')
    assert_equal(lexer.current_token.token_type.type, :variable_name)

    lexer.next_token
    assert_equal(lexer.current_token.text, ' ')
    assert_equal(lexer.current_token.token_type.type, :white_space)

    lexer.next_token
    assert_equal(lexer.current_token.text, '=')
    assert_equal(lexer.current_token.token_type.type, :operator)

    lexer.next_token
    assert_equal(lexer.current_token.text, ' ')
    assert_equal(lexer.current_token.token_type.type, :white_space)

    lexer.next_token
    assert_equal(lexer.current_token.text, '"-- test string"')
    assert_equal(lexer.current_token.token_type.type, :string)

    lexer.next_token
    assert_equal(lexer.current_token.text, ';')
    assert_equal(lexer.current_token.token_type.type, :punctuation)
  end

  def test_date_works_fine
    code = "'2022-01-10'"
    lexer = @lexer.new(code)
    lexer.next_token
    assert_equal(lexer.current_token.text, "'2022-01-10'")
    assert_equal(lexer.current_token.token_type.type, :date)
  end

  def test_int_number_works_fine
    code = '124992'
    lexer = @lexer.new(code)
    lexer.next_token
    assert_equal(lexer.current_token.text, '124992')
    assert_equal(lexer.current_token.token_type.type, :number)
  end

  def test_float_number_works_fine
    code = '124992.23'
    lexer = @lexer.new(code)
    lexer.next_token
    assert_equal(lexer.current_token.text, '124992.23')
    assert_equal(lexer.current_token.token_type.type, :number)
  end

  def test_operators
    code = '+ - * / < > % .'
    lexer = @lexer.new(code)
    lexer.lex_analysis
    tokens = lexer.token_list
    assert_equal(tokens[0].token_type.type, :operator)
    assert_equal(tokens[0].text, '+')

    assert_equal(tokens[1].token_type.type, :operator)
    assert_equal(tokens[1].text, '-')

    assert_equal(tokens[2].token_type.type, :operator)
    assert_equal(tokens[2].text, '*')

    assert_equal(tokens[3].token_type.type, :operator)
    assert_equal(tokens[3].text, '/')

    assert_equal(tokens[4].token_type.type, :operator)
    assert_equal(tokens[4].text, '<')

    assert_equal(tokens[5].token_type.type, :operator)
    assert_equal(tokens[5].text, '>')

    assert_equal(tokens[6].token_type.type, :operator)
    assert_equal(tokens[6].text, '%')

    assert_equal(tokens[7].token_type.type, :operator)
    assert_equal(tokens[7].text, '.')
  end

  def test_not_equal_operator
    code = 't <> q'
    lexer = @lexer.new(code)
    lexer.lex_analysis
    tokens = lexer.token_list
    assert_equal(tokens[1].token_type.type, :operator)
    assert_equal(tokens[1].text, '<>')
  end

  def test_more_than_or_equal_operator
    code = 't >= q'
    lexer = @lexer.new(code)
    lexer.lex_analysis
    tokens = lexer.token_list
    assert_equal(tokens[1].token_type.type, :operator)
    assert_equal(tokens[1].text, '>=')
  end

  def test_less_than_or_equal_operator
    code = 't <= q'
    lexer = @lexer.new(code)
    lexer.lex_analysis
    tokens = lexer.token_list
    assert_equal(tokens[1].token_type.type, :operator)
    assert_equal(tokens[1].text, '<=')
  end

  def test_comment
    code =
      "// TODO
    F = 10;"
    lexer = @lexer.new(code)
    lexer.next_token
    assert_equal(lexer.current_token.token_type.type, :comment)
    assert_equal(lexer.current_token.text, '// TODO')
  end

  def test_method_name
    code =
      'result = TestMethod();'
    lexer = @lexer.new(code)
    lexer.next_token
    lexer.next_token
    lexer.next_token
    lexer.next_token
    lexer.next_token
    assert_equal(lexer.current_token.token_type.type, :method_name)
    assert_equal(lexer.current_token.text, 'TestMethod')
  end

  def test_region_as_preproc
    code =
      "#Область ПрограммныйИнтерфейс
    Процедура МояПроцедура()
    КонецПроцедуры
    #КонецОбласти"
    lexer = @lexer.new(code)
    lexer.lex_analysis
    tokens = lexer.token_list
    assert_equal(tokens.first.token_type.type, :preproc)
    assert_equal(tokens.first.text, '#Область ПрограммныйИнтерфейс')

    assert_equal(tokens.last.token_type.type, :preproc)
    assert_equal(tokens.last.text, '#КонецОбласти')
  end

  def test_preproc
    code =
      "#Если Сервер Тогда
    Процедура МояПроцедура()
    КонецПроцедуры
    #КонецЕсли"
    lexer = @lexer.new(code)
    lexer.lex_analysis
    tokens = lexer.token_list
    assert_equal(tokens.first.token_type.type, :preproc)
    assert_equal(tokens.first.text, '#Если Сервер Тогда')

    assert_equal(tokens.last.token_type.type, :preproc)
    assert_equal(tokens.last.text, '#КонецЕсли')
  end

  def test_new_line_string
    code =
      's = "ВЫБРАТЬ
    |ИЗ
    |Справочник.Номенклатура"'
    lexer = @lexer.new(code)
    lexer.lex_analysis
    tokens = lexer.token_list
    assert_equal(tokens[3].token_type.type, :new_line_string)
    assert_equal(
      tokens[3].text.strip,
      '|ИЗ'
    )
    assert_equal(tokens.last.token_type.type, :new_line_string)
    assert_equal(
      tokens.last.text.strip,
      '|Справочник.Номенклатура"'
    )
  end

  def test_lexing_variable_en
    code = 'Var MyVar Export;'
    lexer = @lexer.new(code)
    lexer.lex_analysis
    tokens = lexer.token_list
    assert_equal(tokens.count, 4)
    assert_equal(tokens[0].token_type.type, :keyword)
    assert_equal(tokens[0].text, 'Var')
    assert_equal(tokens[0].position, 0)

    assert_equal(tokens[1].token_type.type, :variable_name)
    assert_equal(tokens[1].text, 'MyVar')
    assert_equal(tokens[1].position, 4)

    assert_equal(tokens[2].token_type.type, :keyword)
    assert_equal(tokens[2].text, 'Export')
    assert_equal(tokens[2].position, 10)

    assert_equal(tokens[3].token_type.type, :punctuation)
    assert_equal(tokens[3].text, ';')
    assert_equal(tokens[3].position, 16)
  end

  def test_lexing_variable_ru
    code = 'Перем МояПерем Экспорт;'
    lexer = @lexer.new(code)
    lexer.lex_analysis
    tokens = lexer.token_list
    assert_equal(tokens.count, 4)

    assert_equal(tokens[0].token_type.type, :keyword)
    assert_equal(tokens[0].text, 'Перем')
    assert_equal(tokens[0].position, 0)

    assert_equal(tokens[1].token_type.type, :variable_name)
    assert_equal(tokens[1].text, 'МояПерем')
    assert_equal(tokens[1].position, 6)

    assert_equal(tokens[2].token_type.type, :keyword)
    assert_equal(tokens[2].text, 'Экспорт')
    assert_equal(tokens[2].position, 15)

    assert_equal(tokens[3].token_type.type, :punctuation)
    assert_equal(tokens[3].text, ';')
    assert_equal(tokens[3].position, 22)
  end

  def test_lexing_procedure_ru
    code =
      "Процедура МояПроцедура() Экспорт
    КонецПроцедуры"
    lexer = @lexer.new(code)
    lexer.lex_analysis
    tokens = lexer.token_list
    assert_equal(tokens.count, 6)

    assert_equal(tokens[0].token_type.type, :keyword)
    assert_equal(tokens[0].text, 'Процедура')
    assert_equal(tokens[0].position, 0)

    assert_equal(tokens[1].token_type.type, :method_name)
    assert_equal(tokens[1].text, 'МояПроцедура')
    assert_equal(tokens[1].position, 10)

    assert_equal(tokens[2].token_type.type, :punctuation)
    assert_equal(tokens[2].text, '(')
    assert_equal(tokens[2].position, 22)

    assert_equal(tokens[3].token_type.type, :punctuation)
    assert_equal(tokens[3].text, ')')
    assert_equal(tokens[3].position, 23)

    assert_equal(tokens[4].token_type.type, :keyword)
    assert_equal(tokens[4].text, 'Экспорт')
    assert_equal(tokens[4].position, 25)

    assert_equal(tokens[5].token_type.type, :keyword)
    assert_equal(tokens[5].text, 'КонецПроцедуры')
    assert_equal(tokens[5].position, 37)
  end

  def test_lexing_procedure_with_annotation_ru
    code =
      "&Желудь
      Процедура МояПроцедура() Экспорт
    КонецПроцедуры"
    lexer = @lexer.new(code)
    lexer.lex_analysis
    tokens = lexer.token_list
    assert_equal(tokens.count, 7)

    assert_equal(tokens[0].token_type.type, :annotation)
    assert_equal(tokens[0].text, '&Желудь')

    assert_equal(tokens[1].token_type.type, :keyword)
    assert_equal(tokens[1].text, 'Процедура')

    assert_equal(tokens[2].token_type.type, :method_name)
    assert_equal(tokens[2].text, 'МояПроцедура')

    assert_equal(tokens[3].token_type.type, :punctuation)
    assert_equal(tokens[3].text, '(')

    assert_equal(tokens[4].token_type.type, :punctuation)
    assert_equal(tokens[4].text, ')')

    assert_equal(tokens[5].token_type.type, :keyword)
    assert_equal(tokens[5].text, 'Экспорт')

    assert_equal(tokens[6].token_type.type, :keyword)
    assert_equal(tokens[6].text, 'КонецПроцедуры')
  end

  def test_lexing_non_variable_ru
    code = 'Пер МояПерем Экспорт;'
    lexer = @lexer.new(code)
    lexer.lex_analysis
    tokens = lexer.token_list
    assert_equal(tokens.count, 4)

    assert_equal(tokens[0].token_type.type, :variable_name)
    assert_equal(tokens[0].text, 'Пер')
    assert_equal(tokens[0].position, 0)

    assert_equal(tokens[1].token_type.type, :variable_name)
    assert_equal(tokens[1].text, 'МояПерем')
    assert_equal(tokens[1].position, 4)

    assert_equal(tokens[2].token_type.type, :keyword)
    assert_equal(tokens[2].text, 'Экспорт')
    assert_equal(tokens[2].position, 13)

    assert_equal(tokens[3].token_type.type, :punctuation)
    assert_equal(tokens[3].text, ';')
    assert_equal(tokens[3].position, 20)
  end
end

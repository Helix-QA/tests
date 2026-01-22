#language: ru

@tree
@ExportScenarios
@IgnoreOnCIMainBuild

Функционал: Печатные формы

Как Тестировщик я хочу
проверить работу печатных форм 
чтобы выводило всё корректно     

Контекст:
	Дано Я запускаю сценарий открытия TestClient или подключаю уже существующий

Сценарий: Я узнаю название Организации и Структурной единицы_САЛПечатФор
//Создаётся переменная строчная, Структурная единица где убирает пробелы до и после
	И я выполняю код встроенного языка на сервере
    """bsl
      ЗначениеСЕ1 = ПараметрыСеанса.ТекущаяСтруктурнаяЕдиница.Наименование;
      Объект.ЗначениеНаСервере = ЗначениеСЕ1;
    """
    И Я запоминаю значение выражения 'СокрП(Строка(Объект.ЗначениеНаСервере))' в переменную "$$ТекущаяСЕ1$$"	
//Создаётся переменная строчная, Организация где убирает пробелы до и после
	И я выполняю код встроенного языка на сервере
    """bsl
      ЗначениеОрг = Неопределено;
      Если ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяСтруктурнаяЕдиница)
          И ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяСтруктурнаяЕдиница.Организация) Тогда
          ЗначениеОрг1 = ПараметрыСеанса.ТекущаяСтруктурнаяЕдиница.Организация.Наименование;
      Иначе
          ЗначениеОрг1 = "Организация не определена";
      КонецЕсли;
      Объект.ЗначениеНаСервере = ЗначениеОрг1;
    """
    И Я запоминаю значение выражения 'СокрП(Строка(Объект.ЗначениеНаСервере))' в переменную "$$ТекущаяОрганизация1$$"
//Создаётся переменная строчная, Структурная единица
	И я выполняю код встроенного языка на сервере
    """bsl
      ЗначениеСЕ = ПараметрыСеанса.ТекущаяСтруктурнаяЕдиница.Наименование;
      Объект.ЗначениеНаСервере = ЗначениеСЕ;
    """
    И Я запоминаю значение выражения 'Строка(Объект.ЗначениеНаСервере)' в переменную "$$ТекущаяСЕ$$"	
//Создаётся переменная строчная, Организация
	И я выполняю код встроенного языка на сервере
    """bsl
      ЗначениеОрг = Неопределено;
      Если ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяСтруктурнаяЕдиница)
          И ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяСтруктурнаяЕдиница.Организация) Тогда
          ЗначениеОрг = ПараметрыСеанса.ТекущаяСтруктурнаяЕдиница.Организация.Наименование;
      Иначе
          ЗначениеОрг = "Организация не определена";
      КонецЕсли;
      Объект.ЗначениеНаСервере = ЗначениеОрг;
    """
    И Я запоминаю значение выражения 'Строка(Объект.ЗначениеНаСервере)' в переменную "$$ТекущаяОрганизация$$"

	Сценарий: Я создаю Даты_САЛПечатФор
//Создаёт дату - 23 октября 2025 г.
	Дано Я запоминаю значение выражения 'Формат(ТекущаяДата(), "ДЛФ=ДД")' в переменную "$$ПолнаяДата$$"
//Создаёт дату - 23*октября*2025 (используется в макетах где функция записана как шаблон, в макете показывается как 23 октября 2025)
	Дано Я запоминаю значение выражения 'Формат(ТекущаяДата(), "ДФ=дд*ММММ*гггг")' в переменную "$$ПолнаяДатаГ$$"
//Создаёт дату - **23**октября*2025 (используется в макетах где функция записана как шаблон,в макете показывается как "23" октября 2025)
	Дано Я запоминаю значение выражения 'Формат(ТекущаяДата(), "ДФ=*дд**ММММ*гггг")' в переменную "$$ПолнаяДатаК$$"
//Создаёт дату - Чт*23*октября*2025 (используется в макетах где функция записана как шаблон, в макете показывается как Чт 23 октября)
	Дано Я запоминаю значение выражения 'Формат(ТекущаяДата(), "ДФ=ддд*дд*ММММ")' в переменную "$$НаиполнаяДата$$"
//Создаёт дату - 23.10.2025
	Дано Я запоминаю значение выражения 'Формат(ТекущаяДата(), "ДЛФ=Д")' в переменную "$$ЦифроваяДата$$"
//Создаёт дату - 23 (Также получаем 2 числа 1ый символ и 2ой символ, пример 2 и 3)
	Дано Я запоминаю значение выражения 'Формат(ТекущаяДата(), "ДФ=дд")' в переменную "$$ДеньДата$$"	
	И Я запоминаю значение выражения 'Сред($$ДеньДата$$, 1, 1)' в переменную "$$ДеньПерваяЦифра$$"
	И Я запоминаю значение выражения 'Сред($$ДеньДата$$, 2, 1)' в переменную "$$ДеньВтораяЦифра$$"	
//Создаёт дату - 10 (Также получаем 2 числа 1ый символ и 2ой символ, пример 1 и 0)
	Дано Я запоминаю значение выражения 'Формат(ТекущаяДата(), "ДФ=ММ")' в переменную "$$МесяцДата$$"
	И Я запоминаю значение выражения 'Сред($$МесяцДата$$, 1, 1)' в переменную "$$МесяцПерваяЦифра$$"
	И Я запоминаю значение выражения 'Сред($$МесяцДата$$, 2, 1)' в переменную "$$МесяцВтораяЦифра$$"
//Создаёт дату - Октябрь
	Дано Я запоминаю значение выражения 'Формат(ТекущаяДата(), "ДФ=ММММ")' в переменную "$$ПолныйМесяцДата$$"
//Создаёт дату - 2025 (Также получаем 4 числа 1ый символ, 2ой символ, 3ий символ, 4ый символ: пример 2, 0, 2, 5)
	Дано Я запоминаю значение выражения 'Формат(ТекущаяДата(), "ДФ=гггг")' в переменную "$$ГодДата$$"
	И Я запоминаю значение выражения 'Сред($$ГодДата$$, 1, 1)' в переменную "$$ГодПерваяЦифра$$"
	И Я запоминаю значение выражения 'Сред($$ГодДата$$, 2, 1)' в переменную "$$ГодВтораяЦифра$$"
	И Я запоминаю значение выражения 'Сред($$ГодДата$$, 3, 1)' в переменную "$$ГодТретьеЦифра$$"
	И Я запоминаю значение выражения 'Сред($$ГодДата$$, 4, 1)' в переменную "$$ГодЧетвёртоеЦифра$$"

	Дано Я запоминаю значение выражения 'Формат(ТекущаяДата(), "ДФ=дд")' в переменную "$$ДеньНоябрь$$"
//Ноябрь (полный месяц)
	Дано Я запоминаю значение выражения 'Формат(ТекущаяДата(), "ДФ=ММММ")' в переменную "$$МесяцНоябрьТекст$$"
//2025 (год)
	Дано Я запоминаю значение выражения 'Формат(ТекущаяДата(), "ДФ=гггг")' в переменную "$$ГодНоябрь$$"
//полная дата
	Дано Я запоминаю значение выражения '$$ДеньНоябрь$$ * $$ГодНоябрь$$ г.' в переменную "$$ДатаC01$$"
//Создаю дату на количество дней в текущем месяце - например, ноябрь — 30, декабрь — 31.
	Дано Я запоминаю значение выражения 'День(КонецМесяца(ТекущаяДата()))' в переменную "ДнейВМесяце"
//Создаю 30 / 30
	И я запоминаю значение выражения 'Формат($ДнейВМесяце$, "ЧГ=0") + " / " + Формат($ДнейВМесяце$, "ЧГ=0")' в переменную "$$ДатаМесяцПослед1$$"
//Содаю текущую дату на год вперёд
	Дано Я запоминаю значение выражения 'Формат(ДобавитьМесяц(ТекущаяДата(), 12), "ДЛФ=Д")' в переменную "$$ЦифроваяДатаПлюсГод$$"
//Создаёт дату - 23 октября 2025 г.
	Дано Я запоминаю значение выражения 'Формат(ТекущаяДата(), "ДФ=гггг")' в переменную "$$Год$$"
//Создаёт дату с начало месяца - 01.01.26
	Дано Я запоминаю значение выражения 'Формат(НачалоМесяца(ТекущаяДата()), "ДФ=dd.MM.yy")' в переменную "НачалоМесяцаЧислоЦифравое"
//Создаёт дату с конец месяца - 30-31(28).01.26
	Дано Я запоминаю значение выражения 'Формат(КонецМесяца(ТекущаяДата()), "ДФ=dd.MM.yy")' в переменную "КонецМесяцаЧислоЦифравое"
//Создаёт дату с начало месяца - 01.01.2026
	Дано Я запоминаю значение выражения 'Формат(НачалоМесяца(ТекущаяДата()), "ДФ=dd.MM.yyyy")' в переменную "$$НачалоМесяцаЧислоДлинныйЦифравое$$"
//Создаёт дату 01.01.26 по: 31.01.26
	И я запоминаю значение выражения 'Формат($НачалоМесяцаЧислоЦифравое$, "ЧГ=0") + " по: " + Формат($КонецМесяцаЧислоЦифравое$, "ЧГ=0")' в переменную "$$ДатаПоИДоЧисловое$$"

Сценарий: Создаю экспорт Шаблона

*Справочник.ХранилищеШаблонов
	И я проверяю или создаю для справочника "ХранилищеШаблонов" объекты:
		| 'Ссылка'                                                                       | 'ПометкаУдаления' | 'Родитель' | 'ЭтоГруппа' | 'Наименование'      | 'Шаблон'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | 'ТипШаблона'                       | 'ДатаСоздания'       | 'ДатаИзменения'      | 'ПользовательСоздал' | 'ПользовательИзменил' | 'КоличествоПоВертикали' | 'КоличествоПоГоризонтали' |
		| 'e1cib/data/Справочник.ХранилищеШаблонов?ref=87418a880b80b86811f0af3addbdf870' | 'False'           | ''         | 'False'     | 'Этикетка (ценник)' | 'ValueStorage:AQH9DgAAAAAAAO+7v3siIyIsNDIzODAxOWQtN2U0OS00ZmM5LTkxZGItYjZiOTUxZDVjZjhlLA0KezcsDQp7DQp7IlMiLCLQnNCw0LrQtdGC0K3RgtC40LrQtdGC0LrQuCJ9LA0KeyIjIixlNjAzMTAzZS1hMzE4LTRlZGMtYTAxNC1iMWM2Y2Y5NGQ0OWYsDQp7OCwxLDEyLA0KeyIjIiwiIiwxLDEsIiMiLCLQr9C30YvQuiDQv9C+INGD0LzQvtC70YfQsNC90LjRjiIsItCv0LfRi9C6INC/0L4g0YPQvNC+0LvRh9Cw0L3QuNGOIiwxfSwNCnsxMjgsNzJ9LA0KezIsMSwNCns0LDAsDQp7MH0sNCwxLDAsZjUyN2RjODgtMWQzOS00MGIzLWJjYmItZDk4YjY5MGVhZDY4LDB9LDAsMSwNCns0LDAsDQp7MH0sMCwwLDAsZjUyN2RjODgtMWQzOS00MGIzLWJjYmItZDk4YjY5MGVhZDY4LDB9LDB9LDAsDQp7MCwwfSwNCnswLDB9LA0KezAsMH0sDQp7MCwwfSwNCnswLDB9LA0KezAsMH0sMCwyLDIwLDAsMSwxLDAsDQp7MTYsMiwNCnsxLDEsDQp7IiMiLCJb0J/QsNGA0LDQvNC10YLRgNCc0LDQutC10YLQsDRdDQpb0J/QsNGA0LDQvNC10YLRgNCc0LDQutC10YLQsDNdDQpb0J/QsNGA0LDQvNC10YLRgNCc0LDQutC10YLQsDJdDQpb0J/QsNGA0LDQvNC10YLRgNCc0LDQutC10YLQsDFdIn0NCn0sMH0sMSwxLDAsMiwxLDAsMywxLDAsNCwxLDAsNSwxLDAsNiwxLDAsNywxLDAsOCwwLDIsMSwNCnswLDN9LDQsDQp7MCw0fSw5LDAsMiwxLA0KezAsM30sNCwNCnswLDR9LDEwLDAsMiwxLA0KezAsM30sNCwNCnswLDR9LDExLDAsMiwxLA0KezAsM30sNCwNCnswLDR9LDEyLDAsMiwxLA0KezAsM30sNCwNCnswLDR9LDEzLDAsMiwxLA0KezAsM30sNCwNCnswLDR9LDE0LDAsMiwxLA0KezAsM30sNCwNCnswLDR9LDE1LDAsMiwxLA0KezAsM30sNCwNCnswLDR9LDE2LDAsMiwxLA0KezAsM30sNCwNCnswLDR9LDE3LDAsMiwxLA0KezAsM30sNCwNCnswLDR9LDE4LDAsMiwxLA0KezAsM30sNCwNCnswLDR9LDE5LDAsNCwxLA0KezAsNX0sMiwNCnswLDZ9LDMsDQp7MCw2fSw0LA0KezAsN30sDQp7NSwwLDAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMCwwfSwyMCwwLDAsMCwwLDAsMCwwLDAsDQp7MSwNCnswLDAsNCw3LDB9DQp9LA0KezB9LA0KezB9LA0KezB9LCIiLA0Kew0KezAsMjEsMCwNCnsiUyIsIiJ9LDEsDQp7Ik4iLDF9LDIsDQp7IlUifSwzLA0KeyJVIn0sNCwNCnsiTiIsMX0sNSwNCnsiVSJ9LDYsDQp7Ik4iLDEwMDB9LDcsDQp7Ik4iLDEwMDB9LDgsDQp7Ik4iLDEwMDB9LDksDQp7Ik4iLDEwMDB9LDEwLA0KeyJOIiwxMDAwfSwxMSwNCnsiTiIsMTAwMH0sMTIsDQp7Ik4iLDB9LDEzLA0KeyJOIiwwfSwxNCwNCnsiVSJ9LDE2LA0KeyJOIiwyMTB9LDE3LA0KeyJOIiwyOTd9LDE4LA0KeyJOIiwwfSwxOSwNCnsiTiIsNH0sMjAsDQp7Ik4iLDB9LDIxLA0KeyJOIiwxfQ0KfQ0KfSwNCnszLDAsMCw0LDcsMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwfSwwLDAsMCwwLDEsMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwLDAsMCwxLDAsMSw3LA0KezY0LDB9LA0KezMyNzk4LDAsMCwwLDAsMn0sDQp7MiwxfSwNCns4LDF9LA0KezE4LDEsMX0sDQp7MTYsMX0sDQp7MjQsMSwxfSwwLDAsMCwwLDIsDQp7MywzLA0Key0xfQ0KfSwNCnszLDMsDQp7LTN9DQp9LDAsMCwwLCIiLDAsDQp7MywwLDAsMTAwLDEsMSwwLDEsMSwwLDAsMCwwLDAsMCwwLDAsMCwwLDAsMCwiIiwwLDEsDQp7MywwLDAsMCwwLDAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMH0sMCwwLDEsMCwwfSwNCnswfSwwLDAsMCwxLDAsMCwwfQ0KfQ0KfSwNCnsNCnsiUyIsItCY0LzRj9Ce0LHQu9Cw0YHRgtC40J/QtdGH0LDRgtC4In0sDQp7IlMiLCJSMUMxOlI4QzUifQ0KfSwNCnsNCnsiUyIsItCi0LjQv9Ca0L7QtNCwIn0sDQp7Ik4iLDF9DQp9LA0Kew0KeyJTIiwi0KDQsNC30LzQtdGA0KjRgNC40YTRgtCwIn0sDQp7Ik4iLDEyfQ0KfSwNCnsNCnsiUyIsItCe0YLQvtCx0YDQsNC20LDRgtGM0KLQtdC60YHRgiJ9LA0KeyJCIiwxfQ0KfSwNCnsNCnsiUyIsItCf0LDRgNCw0LzQtdGC0YDRi9Co0LDQsdC70L7QvdCwIn0sDQp7IiMiLDNkNDhmZWFlLWE5YzYtNGM1YS1hMDk5LTllYjY0Nzc2MzBjNiwNCns0LA0Kew0KeyJTIiwi0KjRgtGA0LjRhdC60L7QtCJ9LA0KeyJTIiwi0J/QsNGA0LDQvNC10YLRgNCc0LDQutC10YLQsDEifQ0KfSwNCnsNCnsiUyIsItCh0YLRgNGD0LrRgtGD0YDQvdCw0Y/QldC00LjQvdC40YbQsCJ9LA0KeyJTIiwi0J/QsNGA0LDQvNC10YLRgNCc0LDQutC10YLQsDIifQ0KfSwNCnsNCnsiUyIsItCS0LjQtNCm0LXQvSJ9LA0KeyJTIiwi0J/QsNGA0LDQvNC10YLRgNCc0LDQutC10YLQsDMifQ0KfSwNCnsNCnsiUyIsItCm0LXQvdCwIn0sDQp7IlMiLCLQn9Cw0YDQsNC80LXRgtGA0JzQsNC60LXRgtCwNCJ9DQp9DQp9DQp9DQp9LA0Kew0KeyJTIiwi0KDQtdC00LDQutGC0L7RgNCi0LDQsdC70LjRh9C90YvQudCU0L7QutGD0LzQtdC90YIifSwNCnsiIyIsZTYwMzEwM2UtYTMxOC00ZWRjLWEwMTQtYjFjNmNmOTRkNDlmLA0KezgsMSwxMiwNCnsiIyIsIiIsMSwxLCIjIiwi0K/Qt9GL0Log0L/QviDRg9C80L7Qu9GH0LDQvdC40Y4iLCLQr9C30YvQuiDQv9C+INGD0LzQvtC70YfQsNC90LjRjiIsMH0sDQp7MTI4LDcyfSwNCnsyLDEsDQp7NCwwLA0KezB9LDQsMSwwLGY1MjdkYzg4LTFkMzktNDBiMy1iY2JiLWQ5OGI2OTBlYWQ2OCwwfSwwLDEsDQp7NCwwLA0KezB9LDAsMCwwLGY1MjdkYzg4LTFkMzktNDBiMy1iY2JiLWQ5OGI2OTBlYWQ2OCwwfSwwfSwwLA0KezAsMH0sDQp7MCwwfSwNCnswLDB9LA0KezAsMH0sDQp7MCwwfSwNCnswLDB9LDAsMiwyMCwwLDEsMSwwLA0KezE2LDIsDQp7MSwxLA0KeyIjIiwiW9Cm0LXQvdCwXQ0KW9CS0LjQtNCm0LXQvV0NClvQodGC0YDRg9C60YLRg9GA0L3QsNGP0JXQtNC40L3QuNGG0LBdDQpb0KjRgtGA0LjRhdC60L7QtF0ifQ0KfSwwfSwxLDEsMCwyLDEsMCwzLDEsMCw0LDEsMCw1LDEsMCw2LDEsMCw3LDEsMCw4LDAsMiwxLA0KezAsM30sNCwNCnswLDR9LDksMCwyLDEsDQp7MCwzfSw0LA0KezAsNH0sMTAsMCwyLDEsDQp7MCwzfSw0LA0KezAsNH0sMTEsMCwyLDEsDQp7MCwzfSw0LA0KezAsNH0sMTIsMCwyLDEsDQp7MCwzfSw0LA0KezAsNH0sMTMsMCwyLDEsDQp7MCwzfSw0LA0KezAsNH0sMTQsMCwyLDEsDQp7MCwzfSw0LA0KezAsNH0sMTUsMCwyLDEsDQp7MCwzfSw0LA0KezAsNH0sMTYsMCwyLDEsDQp7MCwzfSw0LA0KezAsNH0sMTcsMCwyLDEsDQp7MCwzfSw0LA0KezAsNH0sMTgsMCwyLDEsDQp7MCwzfSw0LA0KezAsNH0sMTksMCw0LDEsDQp7MCw1fSwyLA0KezAsNn0sMywNCnswLDZ9LDQsDQp7MCw3fSwNCns1LDAsMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwLDB9LDIwLDAsMCwwLDAsMCwwLDAsMCwNCnsxLA0KezAsMCw0LDcsMH0NCn0sDQp7MH0sDQp7MH0sDQp7MH0sIiIsDQp7DQp7MCw2LDYsDQp7Ik4iLDEwMDB9LDcsDQp7Ik4iLDEwMDB9LDgsDQp7Ik4iLDEwMDB9LDksDQp7Ik4iLDEwMDB9LDEwLA0KeyJOIiwxMDAwfSwxMSwNCnsiTiIsMTAwMH0NCn0NCn0sDQp7MywwLDAsNCw3LDAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMH0sMCwwLDAsMCwwLDAsMCwxLDAsMSw3LA0KezY0LDB9LA0KezMyNzk4LDAsMCwwLDAsMn0sDQp7MiwxfSwNCns4LDF9LA0KezE4LDEsMX0sDQp7MTYsMX0sDQp7MjQsMSwxfSwwLDAsMCwwLDIsDQp7MywzLA0Key0xfQ0KfSwNCnszLDMsDQp7LTN9DQp9LDAsMCwwLCIiLDAsDQp7MywwLDAsMTAwLDEsMSwwLDEsMSwwLDAsMCwwLDAsMCwwLDAsMCwwLDAsMCwiIiwwLDAsMCwwLDAsMCwwfSwNCnswfSwwLDAsMCwxLDAsMCwwfQ0KfQ0KfQ0KfQ0KfQ==' | 'Enum.ТипыШаблонов.ЭтикеткаЦенник' | '01.01.0001 0:00:00' | '01.01.0001 0:00:00' | ''                   | ''                    |                         |                           |


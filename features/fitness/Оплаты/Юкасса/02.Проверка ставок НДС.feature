#language: ru

@tree

Функционал: 02.Проверка ставок НДС.

| 'Код' | 'Описание' |
| 1     | Без НДС    |
| 2     | 0%         |
| 3     | 10%        |
| 4     | 20%        |
| 5     | 10/110     |
| 6     | 20/120     |
| 7     | 5%         |
| 8     | 7%         |
| 9     | 5/105      |
| 10    | 7/107      |
| 11    | 22%        |
| 12    | 22/122     |

Контекст:
	Дано Я запускаю сценарий открытия TestClient или подключаю уже существующий

Сценарий: Настройка перед тестом
	И я удаляю все переменные
	И я удаляю объекты "Справочники.СтавкиНДС" без контроля ссылок
	И я создаю тестовую ставку НДС

Сценарий: 01. Проверка vat_code - 1(Без НДС)
	Дано я открываю основную форму списка справочника "Организации"
	И в таблице "Список" я перехожу к строке
		| 'Наименование'          |
		| 'Основная ораганизация' |
	И в таблице "Список" я выбираю текущую строку
	И я нажимаю на кнопку с именем '_Налогообложение'
	И из выпадающего списка с именем 'ПолеФормыСтавкаНДС_0' я выбираю точное значение "Без НДС"
	И из выпадающего списка с именем 'ПолеФормыСтавкаНДС_1' я выбираю точное значение "Без НДС"
	И из выпадающего списка с именем 'ПолеФормыСтавкаНДС_2' я выбираю точное значение "Без НДС"
		
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'	
	
	И я создаю клиента для юкассы
	И я создаю номенклатуру для Юкассы
	И я создаю продажу
	И я проверяю json
	И таблица "Список" содержит строки по шаблону:
		| 'Клиент'      | 'Платежный шлюз' | 'Сумма чека' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
		| '$$Фамилия$$' | 'ЮКасса'         | '3 000,00'   | '{"amount":{"value":"3000","currency":"RUB"},"capture":true,"description":"Продажа *, $$Фамилия$$, тел.: *, email: dimitrii$$Email$$@gmail.com","save_payment_method":false,"confirmation":{"type":"redirect","return_url":"ya.ru"},"receipt":{"customer":{"phone":"*","email":"dimitrii$$Email$$@gmail.com"},"items":[{"description":"$$НоменклатураЮкассы$$","quantity":"1.00","amount":{"value":"3000","currency":"RUB"},"vat_code":1,"payment_mode":"full_payment","payment_subject":"service"}],"tax_system_code":1},"metadata":{"cms_name":"fitness1c","ClubID":"*","ClubName":"Фитнес плюс","customerNumber":"$$Фамилия$$","orderNumber":"*"}}' |
	
	
Сценарий: 02. Проверка vat_code - 2(0%)

	Дано я открываю основную форму списка справочника "Организации"
	И в таблице "Список" я перехожу к строке
		| 'Наименование'          |
		| 'Основная ораганизация' |
	И в таблице "Список" я выбираю текущую строку
	И я нажимаю на кнопку с именем '_Налогообложение'
	И из выпадающего списка с именем 'ПолеФормыСтавкаНДС_0' я выбираю точное значение "НДС_Юкасса"
	И из выпадающего списка с именем 'ПолеФормыСтавкаНДС_1' я выбираю точное значение "НДС_Юкасса"
	И из выпадающего списка с именем 'ПолеФормыСтавкаНДС_2' я выбираю точное значение "НДС_Юкасса"

	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'

	И я создаю продажу
	И я проверяю json
	И таблица "Список" содержит строки по шаблону:	
		| 'Клиент'      | 'Платежный шлюз' | 'Сумма чека' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
		| '$$Фамилия$$' | 'ЮКасса'         | '3 000,00'   | '{"amount":{"value":"3000","currency":"RUB"},"capture":true,"description":"Продажа *, $$Фамилия$$, тел.: *, email: dimitrii$$Email$$@gmail.com","save_payment_method":false,"confirmation":{"type":"redirect","return_url":"ya.ru"},"receipt":{"customer":{"phone":"*","email":"dimitrii$$Email$$@gmail.com"},"items":[{"description":"$$НоменклатураЮкассы$$","quantity":"1.00","amount":{"value":"3000","currency":"RUB"},"vat_code":2,"payment_mode":"full_payment","payment_subject":"service"}],"tax_system_code":1},"metadata":{"cms_name":"fitness1c","ClubID":"*","ClubName":"Фитнес плюс","customerNumber":"$$Фамилия$$","orderNumber":"*"}}' |

Сценарий: 03. Проверка vat_code - 7(5%)
	Дано Я открываю навигационную ссылку "$$СтавкаНДС$$"
	И я жду открытия окна "НДС_Юкасса*" в течение 5 секунд
	И я активизирую окно "НДС_Юкасса*"
	И в поле с именем 'Ставка' я ввожу текст "5,00"
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'

	И я создаю продажу
	И я проверяю json
	И таблица "Список" содержит строки по шаблону:
		| 'Клиент'      | 'Платежный шлюз' | 'Сумма чека' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
		| '$$Фамилия$$' | 'ЮКасса'         | '3 000,00'   | '{"amount":{"value":"3000","currency":"RUB"},"capture":true,"description":"Продажа *, $$Фамилия$$, тел.: *, email: dimitrii$$Email$$@gmail.com","save_payment_method":false,"confirmation":{"type":"redirect","return_url":"ya.ru"},"receipt":{"customer":{"phone":"*","email":"dimitrii$$Email$$@gmail.com"},"items":[{"description":"$$НоменклатураЮкассы$$","quantity":"1.00","amount":{"value":"3000","currency":"RUB"},"vat_code":7,"payment_mode":"full_payment","payment_subject":"service"}],"tax_system_code":1},"metadata":{"cms_name":"fitness1c","ClubID":"*","ClubName":"Фитнес плюс","customerNumber":"$$Фамилия$$","orderNumber":"*"}}' |

Сценарий: 04. Проверка vat_code - 8(7%)
	Дано Я открываю навигационную ссылку "$$СтавкаНДС$$"
	И я жду открытия окна "НДС_Юкасса*" в течение 5 секунд
	И я активизирую окно "НДС_Юкасса*"
	И в поле с именем 'Ставка' я ввожу текст "7,00"
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'
	И я создаю продажу
	И я проверяю json
	И таблица "Список" содержит строки по шаблону:
		| 'Клиент'      | 'Платежный шлюз' | 'Сумма чека' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
		| '$$Фамилия$$' | 'ЮКасса'         | '3 000,00'   | '{"amount":{"value":"3000","currency":"RUB"},"capture":true,"description":"Продажа *, $$Фамилия$$, тел.: *, email: dimitrii$$Email$$@gmail.com","save_payment_method":false,"confirmation":{"type":"redirect","return_url":"ya.ru"},"receipt":{"customer":{"phone":"*","email":"dimitrii$$Email$$@gmail.com"},"items":[{"description":"$$НоменклатураЮкассы$$","quantity":"1.00","amount":{"value":"3000","currency":"RUB"},"vat_code":8,"payment_mode":"full_payment","payment_subject":"service"}],"tax_system_code":1},"metadata":{"cms_name":"fitness1c","ClubID":"*","ClubName":"Фитнес плюс","customerNumber":"$$Фамилия$$","orderNumber":"*"}}' |

Сценарий: 05. Проверка vat_code - 3(10%)
	Дано Я открываю навигационную ссылку "$$СтавкаНДС$$"
	И я жду открытия окна "НДС_Юкасса*" в течение 5 секунд
	И я активизирую окно "НДС_Юкасса*"
	И в поле с именем 'Ставка' я ввожу текст "10,00"
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'

//	И я создаю клиента для юкассы
//	И я создаю номенклатуру для Юкассы
	И я создаю продажу
	И я проверяю json
	И таблица "Список" содержит строки по шаблону:
		| 'Клиент'      | 'Платежный шлюз' | 'Сумма чека' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
		| '$$Фамилия$$' | 'ЮКасса'         | '3 000,00'   | '{"amount":{"value":"3000","currency":"RUB"},"capture":true,"description":"Продажа *, $$Фамилия$$, тел.: *, email: dimitrii$$Email$$@gmail.com","save_payment_method":false,"confirmation":{"type":"redirect","return_url":"ya.ru"},"receipt":{"customer":{"phone":"*","email":"dimitrii$$Email$$@gmail.com"},"items":[{"description":"$$НоменклатураЮкассы$$","quantity":"1.00","amount":{"value":"3000","currency":"RUB"},"vat_code":3,"payment_mode":"full_payment","payment_subject":"service"}],"tax_system_code":1},"metadata":{"cms_name":"fitness1c","ClubID":"*","ClubName":"Фитнес плюс","customerNumber":"$$Фамилия$$","orderNumber":"*"}}' |
	

Сценарий: 06. Проверка vat_code - 4(20%)
	Дано Я открываю навигационную ссылку "$$СтавкаНДС$$"
	И я жду открытия окна "НДС_Юкасса*" в течение 5 секунд
	И я активизирую окно "НДС_Юкасса*"
	И в поле с именем 'Ставка' я ввожу текст "20,00"
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'

	И я создаю продажу
	И я проверяю json
	И таблица "Список" содержит строки по шаблону:
		| 'Клиент'      | 'Платежный шлюз' | 'Сумма чека' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
		| '$$Фамилия$$' | 'ЮКасса'         | '3 000,00'   | '{"amount":{"value":"3000","currency":"RUB"},"capture":true,"description":"Продажа *, $$Фамилия$$, тел.: *, email: dimitrii$$Email$$@gmail.com","save_payment_method":false,"confirmation":{"type":"redirect","return_url":"ya.ru"},"receipt":{"customer":{"phone":"*","email":"dimitrii$$Email$$@gmail.com"},"items":[{"description":"$$НоменклатураЮкассы$$","quantity":"1.00","amount":{"value":"3000","currency":"RUB"},"vat_code":4,"payment_mode":"full_payment","payment_subject":"service"}],"tax_system_code":1},"metadata":{"cms_name":"fitness1c","ClubID":"*","ClubName":"Фитнес плюс","customerNumber":"$$Фамилия$$","orderNumber":"*"}}' |

Сценарий: 07. Проверка vat_code - 5(10%/110%)
	Дано Я открываю навигационную ссылку "$$СтавкаНДС$$"
	И я жду открытия окна "НДС_Юкасса*" в течение 5 секунд
	И я активизирую окно "НДС_Юкасса*"
	И в поле с именем 'Ставка' я ввожу текст "10,00"
	И я устанавливаю флаг с именем 'Расчетная'
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'

	И я создаю продажу
	И я проверяю json
	И таблица "Список" содержит строки по шаблону:
		| 'Клиент'      | 'Платежный шлюз' | 'Сумма чека' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
		| '$$Фамилия$$' | 'ЮКасса'         | '3 000,00'   | '{"amount":{"value":"3000","currency":"RUB"},"capture":true,"description":"Продажа *, $$Фамилия$$, тел.: *, email: dimitrii$$Email$$@gmail.com","save_payment_method":false,"confirmation":{"type":"redirect","return_url":"ya.ru"},"receipt":{"customer":{"phone":"*","email":"dimitrii$$Email$$@gmail.com"},"items":[{"description":"$$НоменклатураЮкассы$$","quantity":"1.00","amount":{"value":"3000","currency":"RUB"},"vat_code":5,"payment_mode":"full_payment","payment_subject":"service"}],"tax_system_code":1},"metadata":{"cms_name":"fitness1c","ClubID":"*","ClubName":"Фитнес плюс","customerNumber":"$$Фамилия$$","orderNumber":"*"}}' |

Сценарий: 08. Проверка vat_code - 6(20%/120%)
	Дано Я открываю навигационную ссылку "$$СтавкаНДС$$"
	И я жду открытия окна "НДС_Юкасса*" в течение 5 секунд
	И я активизирую окно "НДС_Юкасса*"
	И в поле с именем 'Ставка' я ввожу текст "20,00"
	И я устанавливаю флаг с именем 'Расчетная'
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'

	И я создаю продажу
	И я проверяю json
	И таблица "Список" содержит строки по шаблону:
		| 'Клиент'      | 'Платежный шлюз' | 'Сумма чека' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
		| '$$Фамилия$$' | 'ЮКасса'         | '3 000,00'   | '{"amount":{"value":"3000","currency":"RUB"},"capture":true,"description":"Продажа *, $$Фамилия$$, тел.: *, email: dimitrii$$Email$$@gmail.com","save_payment_method":false,"confirmation":{"type":"redirect","return_url":"ya.ru"},"receipt":{"customer":{"phone":"*","email":"dimitrii$$Email$$@gmail.com"},"items":[{"description":"$$НоменклатураЮкассы$$","quantity":"1.00","amount":{"value":"3000","currency":"RUB"},"vat_code":6,"payment_mode":"full_payment","payment_subject":"service"}],"tax_system_code":1},"metadata":{"cms_name":"fitness1c","ClubID":"*","ClubName":"Фитнес плюс","customerNumber":"$$Фамилия$$","orderNumber":"*"}}' |

Сценарий: 09. Проверка vat_code - 9(5%/105%)
	Дано Я открываю навигационную ссылку "$$СтавкаНДС$$"
	И я жду открытия окна "НДС_Юкасса*" в течение 5 секунд
	И я активизирую окно "НДС_Юкасса*"
	И в поле с именем 'Ставка' я ввожу текст "5,00"
	И я устанавливаю флаг с именем 'Расчетная'
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'

	И я создаю продажу
	И я проверяю json
	И таблица "Список" содержит строки по шаблону:
		| 'Клиент'      | 'Платежный шлюз' | 'Сумма чека' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
		| '$$Фамилия$$' | 'ЮКасса'         | '3 000,00'   | '{"amount":{"value":"3000","currency":"RUB"},"capture":true,"description":"Продажа *, $$Фамилия$$, тел.: *, email: dimitrii$$Email$$@gmail.com","save_payment_method":false,"confirmation":{"type":"redirect","return_url":"ya.ru"},"receipt":{"customer":{"phone":"*","email":"dimitrii$$Email$$@gmail.com"},"items":[{"description":"$$НоменклатураЮкассы$$","quantity":"1.00","amount":{"value":"3000","currency":"RUB"},"vat_code":9,"payment_mode":"full_payment","payment_subject":"service"}],"tax_system_code":1},"metadata":{"cms_name":"fitness1c","ClubID":"*","ClubName":"Фитнес плюс","customerNumber":"$$Фамилия$$","orderNumber":"*"}}' |

Сценарий: 10. Проверка vat_code - 10(7%/107%)
	Дано Я открываю навигационную ссылку "$$СтавкаНДС$$"
	И я жду открытия окна "НДС_Юкасса*" в течение 5 секунд
	И я активизирую окно "НДС_Юкасса*"
	И в поле с именем 'Ставка' я ввожу текст "7,00"
	И я устанавливаю флаг с именем 'Расчетная'
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'

	И я создаю продажу
	И я проверяю json
	И таблица "Список" содержит строки по шаблону:
		| 'Клиент'      | 'Платежный шлюз' | 'Сумма чека' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
		| '$$Фамилия$$' | 'ЮКасса'         | '3 000,00'   | '{"amount":{"value":"3000","currency":"RUB"},"capture":true,"description":"Продажа *, $$Фамилия$$, тел.: *, email: dimitrii$$Email$$@gmail.com","save_payment_method":false,"confirmation":{"type":"redirect","return_url":"ya.ru"},"receipt":{"customer":{"phone":"*","email":"dimitrii$$Email$$@gmail.com"},"items":[{"description":"$$НоменклатураЮкассы$$","quantity":"1.00","amount":{"value":"3000","currency":"RUB"},"vat_code":10,"payment_mode":"full_payment","payment_subject":"service"}],"tax_system_code":1},"metadata":{"cms_name":"fitness1c","ClubID":"*","ClubName":"Фитнес плюс","customerNumber":"$$Фамилия$$","orderNumber":"*"}}' |
		
Сценарий: 11. Проверка vat_code - 22(22%/122%)
	Дано Я открываю навигационную ссылку "$$СтавкаНДС$$"
	И я жду открытия окна "НДС_Юкасса*" в течение 5 секунд
	И я активизирую окно "НДС_Юкасса*"
	И в поле с именем 'Ставка' я ввожу текст "22,00"
	И я снимаю флаг с именем 'Расчетная'
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'

	И я создаю продажу
	И я проверяю json
	И таблица "Список" содержит строки по шаблону:
		| 'Клиент'      | 'Платежный шлюз' | 'Сумма чека' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
		| '$$Фамилия$$' | 'ЮКасса'         | '3 000,00'   | '{"amount":{"value":"3000","currency":"RUB"},"capture":true,"description":"Продажа *, $$Фамилия$$, тел.: *, email: dimitrii$$Email$$@gmail.com","save_payment_method":false,"confirmation":{"type":"redirect","return_url":"ya.ru"},"receipt":{"customer":{"phone":"*","email":"dimitrii$$Email$$@gmail.com"},"items":[{"description":"$$НоменклатураЮкассы$$","quantity":"1.00","amount":{"value":"3000","currency":"RUB"},"vat_code":11,"payment_mode":"full_payment","payment_subject":"service"}],"tax_system_code":1},"metadata":{"cms_name":"fitness1c","ClubID":"*","ClubName":"Фитнес плюс","customerNumber":"$$Фамилия$$","orderNumber":"*"}}'                                                                         |

Сценарий: 12. Проверка vat_code - 22(22%/122%)
	Дано Я открываю навигационную ссылку "$$СтавкаНДС$$"
	И я жду открытия окна "НДС_Юкасса*" в течение 5 секунд
	И я активизирую окно "НДС_Юкасса*"
	И в поле с именем 'Ставка' я ввожу текст "22,00"
	И я устанавливаю флаг с именем 'Расчетная'
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'

	И я создаю продажу
	И я проверяю json
	И таблица "Список" содержит строки по шаблону:
		| 'Клиент'      | 'Платежный шлюз' | 'Сумма чека' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
		| '$$Фамилия$$' | 'ЮКасса'         | '3 000,00'   | '{"amount":{"value":"3000","currency":"RUB"},"capture":true,"description":"Продажа *, $$Фамилия$$, тел.: *, email: dimitrii$$Email$$@gmail.com","save_payment_method":false,"confirmation":{"type":"redirect","return_url":"ya.ru"},"receipt":{"customer":{"phone":"*","email":"dimitrii$$Email$$@gmail.com"},"items":[{"description":"$$НоменклатураЮкассы$$","quantity":"1.00","amount":{"value":"3000","currency":"RUB"},"vat_code":12,"payment_mode":"full_payment","payment_subject":"service"}],"tax_system_code":1},"metadata":{"cms_name":"fitness1c","ClubID":"*","ClubName":"Фитнес плюс","customerNumber":"$$Фамилия$$","orderNumber":"*"}}'                                                                         |

Сценарий: 07. Возврат настроек.
	Дано я открываю основную форму списка справочника "Организации"
	И в таблице "Список" я перехожу к строке
		| 'Наименование'          |
		| 'Основная ораганизация' |
	И в таблице "Список" я выбираю текущую строку
	И я нажимаю на кнопку с именем '_Налогообложение'
	И из выпадающего списка с именем 'ПолеФормыСтавкаНДС_0' я выбираю точное значение "Без НДС"
	И из выпадающего списка с именем 'ПолеФормыСтавкаНДС_1' я выбираю точное значение "Без НДС"
	И из выпадающего списка с именем 'ПолеФормыСтавкаНДС_2' я выбираю точное значение "Без НДС"
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'
	
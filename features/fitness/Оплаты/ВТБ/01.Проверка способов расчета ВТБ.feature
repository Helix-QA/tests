#language: ru

@tree

Функционал: <описание фичи>
Ссылка на документацию ВТБ: https://sandbox.vtb.ru/sandbox/ru/integration/api/rest.html#register
Признаки способа расчета(paymentMethod)
| 'paymentMethod' | 'Описание'                                                                                      |
| '1'             | 'Полная предварительная оплата до момента передачи предмета расчета'                            |
| '2'             | 'Частичная предварительная оплата до момента передачи предмета расчета'                         |
| '3'             | 'Аванс'                                                                                         |
| '4'             | 'Полная оплата в момент передачи предмета расчёта'                                              |
| '5'             | 'Частичная оплата предмета расчёта в момент его передачи с последующей оплатой в кредит'        |
| '6'             | 'Передача предмета расчёта без его оплаты в момент его передачи с последующей оплатой в кредит' |
| '7'             | 'Оплата предмета расчёта после его передачи с оплатой в кредит'                                 |

Контекст:
	Дано Я запускаю сценарий открытия TestClient или подключаю уже существующий
	И я закрываю все окна клиентского приложения

Сценарий: Первоначальная настройка организации.
	И я удаляю все переменные
	И Я создаю клиента для Юкассы
	И Я создаю номенклатуру для Юкассы
*Очистка регистра сведений 'ПрименениеСистемНалогообложения' и заполнение данных в организации.
	И я удаляю все записи РегистрСведений "ПрименениеСистемНалогообложения"
	Дано я открываю основную форму списка справочника "Организации"
	И в таблице 'Список' я перехожу к строке:
		| 'Наименование'          |
		| 'Основная ораганизация' |
	И в таблице 'Список' я выбираю текущую строку 	
	И я нажимаю на кнопку с именем '_Налогообложение'
	Если элемент "ПолеФормыПредметНалогообложения_0" доступен не только для просмотра Тогда
		И в поле с именем 'ПолеФормыПериод_0' я ввожу текст "01.12.2024"	
		И из выпадающего списка с именем 'ПолеФормыПредметНалогообложения_0' я выбираю точное значение "Авансы"
		И из выпадающего списка с именем 'ПолеФормы_СистемаНалогообложения_0' я выбираю точное значение "Общая"
		И из выпадающего списка с именем 'ПолеФормыСтавкаНДС_0' я выбираю точное значение "Без НДС"

		И я нажимаю на кнопку с именем 'КнопкаДобавитьГруппуПримененияСНО'				
		И из выпадающего списка с именем 'ПолеФормыПредметНалогообложения_1' я выбираю точное значение "Товары"
		И из выпадающего списка с именем 'ПолеФормы_СистемаНалогообложения_1' я выбираю точное значение "Общая"
		И из выпадающего списка с именем 'ПолеФормыСтавкаНДС_1' я выбираю точное значение "Без НДС"

		И я нажимаю на кнопку с именем 'КнопкаДобавитьГруппуПримененияСНО'
		И из выпадающего списка с именем 'ПолеФормыПредметНалогообложения_2' я выбираю точное значение "Услуги"
		И из выпадающего списка с именем 'ПолеФормы_СистемаНалогообложения_2' я выбираю точное значение "Общая"
		И из выпадающего списка с именем 'ПолеФормыСтавкаНДС_2' я выбираю точное значение "Без НДС"
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'

*Настройка эквайрингового терминала "CloudPayments".
	Дано я открываю основную форму списка справочника 'ЭквайринговыеТерминалы'
	И в таблице 'Список' я перехожу к строке:
		| 'Наименование'                  |
		| '05.ВТБ, Основная ораганизация' |
	И в таблице 'Список' я выбираю текущую строку
	Тогда открылось окно "05.ВТБ, Основная ораганизация (эквайринг)"
	И в поле с именем 'ЛогинБанка' я ввожу текст "academi.frw-api"
	И в поле с именем 'ПарольБанка' я ввожу текст "academi.frw"
	И в поле с именем 'UrlRedirect' я ввожу текст "https://google.com/"
	И я запоминаю значение поля с именем 'URLCallback' как 'URLCallback'
	И в поле с именем 'ВремяЖизниСсылкиНаОплату' я ввожу текст '2'
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'

*Добавление URLCallback в ЛК ВТБ Банка.
	И я выполняю код встроенного языка
		"""bsl
			Путь = "$КаталогПроекта$\features\fitness\Оплаты\ВТБ\ВТБ.bat";
			ЗапуститьПриложение(Путь);
		"""
	//"D:\Репозиторий\tests\features\fitness\Оплаты\ВТБ\ВТБ.bat"
	И пауза 3
	И я запускаю браузер
	И я открываю ссылку в браузере "https://vtb.rbsuat.com/mportal3/"
	И пауза 3
	*Ввод через JS Логина и пароля.
		И я выполняю код Javascript в странице браузера
			"""
				document.querySelector('input[name="login"]').value = 'academi.frw-operator';
				document.querySelector('input[name="password"]').value = 'academi.frw';

				// Для React-приложений дополнительно инициируем события ввода
				document.querySelector('input[name="login"]').dispatchEvent(
					new Event('input', { bubbles: true })
				);

				document.querySelector('input[name="password"]').dispatchEvent(
					new Event('input', { bubbles: true })
				);

				document.querySelector('input[name="login"]').dispatchEvent(
					new Event('change', { bubbles: true })
				);

				document.querySelector('input[name="password"]').dispatchEvent(
					new Event('change', { bubbles: true })
				);
			"""
	*Нажатие на кнопку "Войти".
		И я выполняю код Javascript в странице браузера
			"""
				document.querySelector('[data-test-id="login-form__submit-button"]').click();
			"""
		И пауза 3
	*Нажатие на кнопку "Настройки"	
		И в странице браузера для элемента с именем класса "flex-1 text-sm" я делаю клик
		И пауза 2
	*Нажатие на кнопку "Системные настройки"	
		И я выполняю код Javascript в странице браузера
			"""
				document.querySelector('[data-test-id="desktop-navigation__settings-system-link"]').click();
			"""		
		И пауза 2
	*Нажатие на кнопку "Callback уведомления"
		И я выполняю код Javascript в странице браузера
			"""
				document.querySelector('[data-test-id="settings-navigation__links-callback-notifications"]').click();
			"""
		И пауза 2
	*Ввод ссылки на callback
		И я выполняю код Javascript в странице браузера
			"""
				const el = document.querySelector('input[name="callbackUrl"]');
				const setter = Object.getOwnPropertyDescriptor(
					window.HTMLInputElement.prototype,
					'value'
				).set;
				setter.call(el, "$URLCallback$");
				el.dispatchEvent(new Event('input', { bubbles: true }));
				el.dispatchEvent(new Event('change', { bubbles: true }));
			"""
	*Сохранение настроек callback.
		И я выполняю код Javascript в странице браузера
			"""
				document.querySelector('.panel__footer button[type="submit"]')?.click();
			"""
	*Закрытие браузера.
		И я закрываю все вкладки браузера

Сценарий: Проверка прошлых сценариев на ошибки и остановка фича файла.
	И Остановка если была ошибка в прошлом сценарии

Сценарий: Проверка PaymentMethod - 1(Полная предварительная оплата до момента передачи предмета расчета).
*Включение авансовой схемы в огранизации.
	Дано я открываю основную форму списка справочника "Организации"
	И в таблице 'Список' я перехожу к строке:
		| 'Наименование'          |
		| 'Основная ораганизация' |
	И в таблице 'Список' я выбираю текущую строку
	И я устанавливаю флаг с именем 'АвансоваяСхемаПробитияУслуг'
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'

*Создание продажи и проверка json.
	И Я создаю продажу ВТБ.
	И Я проверяю json
	И в таблице "Список" я перехожу к первой строке
	И я нажимаю на кнопку с именем 'ОбновитьСтатус'
	И таблица 'Список' содержит строки по шаблону:
		| 'Клиент'      | 'Статус оплаты в банке'                | 'Статус в 1С' | 'Сумма чека' | 'Платежный шлюз' | 'Эквайринговый терминал'                    | 'Структурная единица' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | 'Источник записи'  |
		| '$$Фамилия$$' | 'Заказ зарегистрирован, но не оплачен' | 'Не оплачено' | '3 000,00'   | 'ВТБ'            | '05.ВТБ, Основная ораганизация (эквайринг)' | 'Фитнес плюс'         | '{"errorCode":"0","errorMessage":"Успешно","orderNumber":"*","orderStatus":0,"actionCode":-100,"actionCodeDescription":"","displayErrorMessage":"","amount":300000,"currency":"643","date":*,"orderDescription":"$$НоменклатураЮкассы$$","merchantOrderParams":[{"name":"ClubName","value":"Фитнес плюс"},{"name":"orderNumber","value":"*"},{"name":"phone","value":"*"},{"name":"UserID","value":"*"},{"name":"orderEmail","value":"dimitrii$$Email$$@gmail.com"},{"name":"ClubID","value":"*"},{"name":"orderPhone","value":"*"},{"name":"email","value":"dimitrii$$Email$$@gmail.com"}],"transactionAttributes":[{"name":"merchantIp","value":"*"}],"attributes":[{"name":"mdOrder","value":"*"}],"terminalId":"*","paymentAmountInfo":{"paymentState":"CREATED","approvedAmount":0,"depositedAmount":0,"refundedAmount":0,"feeAmount":0,"totalAmount":300000},"bankInfo":{"bankCountryCode":"UNKNOWN","bankCountryName":"<Неизвестно>"},"payerData":{"email":"dimitrii$$Email$$@gmail.com","phone":"*"},"orderBundle":{"customerDetails":{"email":"dimitrii$$Email$$@gmail.com","phone":"*"},"cartItems":{"items":[{"positionId":"1","name":"$$НоменклатураЮкассы$$","quantity":{"value":1.0,"measure":"0"},"itemAmount":300000,"depositedItemAmount":300000,"itemCurrency":643,"itemCode":"*","itemPrice":300000,"itemAttributes":{"attributes":[{"name":"paymentMethod","value":"1"},{"name":"paymentObject","value":"4"}]}}]}},"chargeback":false}' | 'Ссылка на оплату' |
	
Сценарий: Проверка PaymentMethod - 3(Аванс).
*Открытие рецепции и взнос на лицевой счет.
	Дано я открываю основную форму обработки "РабочийСтол"
	И в поле с именем 'ТекущийКлиент' я ввожу текст "$$Фамилия$$"
	И из выпадающего списка с именем 'ТекущийКлиент' я выбираю "$$Фамилия$$"
	И я нажимаю на гиперссылку с именем 'ВнестиНаЛицевойСчет'
	Тогда открылось окно "Взнос на лицевой счет"
	И я нажимаю на кнопку с именем 'КассаОплаты_1'
	И я нажимаю на кнопку с именем 'КнопкаВидыОплатаНаименованиеСтрока_1x4'
	И в поле с именем 'ПолеВидыОплатВводСуммыСтрока_1x4' я ввожу текст "2 500,00"
	И Я нажимаю на кнопку оплаты 'КнопкаВидыОплатПрименитьеСуммуСтрока_1x4'	
	И я нажимаю на кнопку с именем 'Оплатить'
	И я нажимаю на кнопку с именем 'СформироватьСсылкуНаОплатуСВыбраннойСуммой'				

*Проверка json.
	И Я проверяю json
	И в таблице "Список" я перехожу к первой строке
	И я нажимаю на кнопку с именем 'ОбновитьСтатус'
	И таблица 'Список' содержит строки по шаблону:
		| 'Клиент'      | 'Статус оплаты в банке'                | 'Статус в 1С' | 'Сумма чека' | 'Платежный шлюз' | 'Эквайринговый терминал'                    | 'Структурная единица' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | 'Источник записи'  |
		| '$$Фамилия$$' | 'Заказ зарегистрирован, но не оплачен' | 'Не оплачено' | '2 500,00'   | 'ВТБ'            | '05.ВТБ, Основная ораганизация (эквайринг)' | 'Фитнес плюс'         | '{"errorCode":"0","errorMessage":"Успешно","orderNumber":"*","orderStatus":0,"actionCode":-100,"actionCodeDescription":"","displayErrorMessage":"","amount":250000,"currency":"643","date":*,"orderDescription":"","merchantOrderParams":[{"name":"ClubName","value":"Фитнес плюс"},{"name":"orderNumber","value":"*"},{"name":"phone","value":"*"},{"name":"UserID","value":"*"},{"name":"orderEmail","value":"dimitrii$$Email$$@gmail.com"},{"name":"ClubID","value":"*"},{"name":"orderPhone","value":"*"},{"name":"email","value":"dimitrii$$Email$$@gmail.com"}],"transactionAttributes":[{"name":"merchantIp","value":"*"}],"attributes":[{"name":"mdOrder","value":"*"}],"terminalId":"*","paymentAmountInfo":{"paymentState":"CREATED","approvedAmount":0,"depositedAmount":0,"refundedAmount":0,"feeAmount":0,"totalAmount":250000},"bankInfo":{"bankCountryCode":"UNKNOWN","bankCountryName":"<Неизвестно>"},"payerData":{"email":"dimitrii$$Email$$@gmail.com","phone":"*"},"orderBundle":{"customerDetails":{"email":"dimitrii$$Email$$@gmail.com","phone":"*"},"cartItems":{"items":[{"positionId":"1","name":"Взнос на лицевой счет","quantity":{"value":1.0,"measure":"0"},"itemAmount":250000,"depositedItemAmount":250000,"itemCurrency":643,"itemCode":"*","itemPrice":250000,"itemAttributes":{"attributes":[{"name":"paymentMethod","value":"3"},{"name":"paymentObject","value":"10"}]}}]}},"chargeback":false}' | 'Ссылка на оплату' |
	
Сценарий: Проверка PaymentMethod - 4(Полная оплата в момент передачи предмета расчёта).
*Отключение авансовой схемы в огранизации.
	Дано я открываю основную форму списка справочника "Организации"
	И в таблице 'Список' я перехожу к строке:
		| 'Наименование'          |
		| 'Основная ораганизация' |
	И в таблице 'Список' я выбираю текущую строку
	И я снимаю флаг с именем 'АвансоваяСхемаПробитияУслуг'
	И я нажимаю на кнопку с именем 'ФормаКнопкаСохранитьИЗакрыть'			

*Создание продажи и проверка json.
	И Я создаю продажу ВТБ.
	И Я проверяю json
	И в таблице "Список" я перехожу к первой строке
	И я нажимаю на кнопку с именем 'ОбновитьСтатус'
	И таблица 'Список' содержит строки по шаблону:
		| 'Клиент'      | 'Статус оплаты в банке'                | 'Статус в 1С' | 'Сумма чека' | 'Платежный шлюз' | 'Эквайринговый терминал'                    | 'Структурная единица' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | 'Источник записи'  |
		| '$$Фамилия$$' | 'Заказ зарегистрирован, но не оплачен' | 'Не оплачено' | '3 000,00'   | 'ВТБ'            | '05.ВТБ, Основная ораганизация (эквайринг)' | 'Фитнес плюс'         | '{"errorCode":"0","errorMessage":"Успешно","orderNumber":"*","orderStatus":0,"actionCode":-100,"actionCodeDescription":"","displayErrorMessage":"","amount":300000,"currency":"643","date":*,"orderDescription":"$$НоменклатураЮкассы$$","merchantOrderParams":[{"name":"ClubName","value":"Фитнес плюс"},{"name":"orderNumber","value":"*"},{"name":"phone","value":"*"},{"name":"UserID","value":"*"},{"name":"orderEmail","value":"dimitrii$$Email$$@gmail.com"},{"name":"ClubID","value":"*"},{"name":"orderPhone","value":"*"},{"name":"email","value":"dimitrii$$Email$$@gmail.com"}],"transactionAttributes":[{"name":"merchantIp","value":"*"}],"attributes":[{"name":"mdOrder","value":"*"}],"terminalId":"*","paymentAmountInfo":{"paymentState":"CREATED","approvedAmount":0,"depositedAmount":0,"refundedAmount":0,"feeAmount":0,"totalAmount":300000},"bankInfo":{"bankCountryCode":"UNKNOWN","bankCountryName":"<Неизвестно>"},"payerData":{"email":"dimitrii$$Email$$@gmail.com","phone":"*"},"orderBundle":{"customerDetails":{"email":"dimitrii$$Email$$@gmail.com","phone":"*"},"cartItems":{"items":[{"positionId":"1","name":"$$НоменклатураЮкассы$$","quantity":{"value":1.0,"measure":"0"},"itemAmount":300000,"depositedItemAmount":300000,"itemCurrency":643,"itemCode":"*","itemPrice":300000,"itemAttributes":{"attributes":[{"name":"paymentMethod","value":"4"},{"name":"paymentObject","value":"4"}]}}]}},"chargeback":false}' | 'Ссылка на оплату' |

Сценарий: Проверка PaymentMethod - 7(Оплата предмета расчёта после его передачи с оплатой в кредит).
*Создание продажи с её передачей в кредит.
	Дано Я открываю основную форму документа "Реализация"
	И в поле с именем 'Контрагент' я ввожу значение выражения "$$Фамилия$$"
	И из выпадающего списка с именем 'Контрагент' я выбираю по строке "$$Фамилия$$"
	И я нажимаю на кнопку с именем 'ЗапасыКнопкаДобавить'
	И в таблице 'Запасы' в поле с именем 'ЗапасыНоменклатура' я ввожу текст "$$НоменклатураЮкассы$$"
	И в таблице 'Запасы' из выпадающего списка с именем 'ЗапасыНоменклатура' я выбираю по строке "$$НоменклатураЮкассы$$"
	И я нажимаю на кнопку с именем 'КнопкаЗаписать'
	Дано я сохраняю навигационную ссылку текущего окна в переменную "ПродажаВКредит"
	И я нажимаю на кнопку с именем 'КнопкаОплатитьРеализацию'
	И я нажимаю на кнопку с именем 'КнопкаВидыОплатаНаименованиеСтрока_0'
	И в поле с именем 'ПолеВидыОплатВводСуммыСтрока_0' я ввожу текст "1 500,00"
	И Я нажимаю на кнопку оплаты 'КнопкаВидыОплатПрименитьеСуммуСтрока_0'
	И я нажимаю на кнопку с именем 'Оплатить'
	И я нажимаю на кнопку с именем 'Button0'
	Если открылось окно "Внимание" Тогда
		И я нажимаю на кнопку с именем 'Button0'
		И я нажимаю на гиперссылку с именем 'ДекорацияZОтчета_0'
		И я нажимаю на кнопку с именем 'ПодтвердитьЗакрытиеСмены'
	И Я открываю основную форму списка документа "Реализация"
	И я нажимаю на кнопку с именем 'СписокОплатить'
	И я нажимаю на кнопку с именем 'КассаОплаты_1'
	И я изменяю флаг с именем 'ЗадолженностьВыборСтрока_0'
	И я нажимаю на кнопку с именем 'КнопкаВидыОплатаНаименованиеСтрока_1x4'
	И Я нажимаю на кнопку оплаты 'КнопкаВидыОплатПрименитьеСуммуСтрока_1x4'
	И я нажимаю на кнопку с именем 'Оплатить'
	И я нажимаю на кнопку с именем 'СформироватьСсылкуНаОплатуСВыбраннойСуммой''	

*Проверка json
	И Я проверяю json
	И в таблице "Список" я перехожу к первой строке
	И я нажимаю на кнопку с именем 'ОбновитьСтатус'
	И таблица 'Список' содержит строки по шаблону:
		| 'Клиент'      | 'Статус оплаты в банке'                | 'Статус в 1С' | 'Сумма чека' | 'Платежный шлюз' | 'Эквайринговый терминал'                    | 'Структурная единица' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | 'Источник записи'  |
		| '$$Фамилия$$' | 'Заказ зарегистрирован, но не оплачен' | 'Не оплачено' | '1 500,00'   | 'ВТБ'            | '05.ВТБ, Основная ораганизация (эквайринг)' | 'Фитнес плюс'         | '{"errorCode":"0","errorMessage":"Успешно","orderNumber":"*","orderStatus":0,"actionCode":-100,"actionCodeDescription":"","displayErrorMessage":"","amount":150000,"currency":"643","date":*,"orderDescription":"$$НоменклатураЮкассы$$","merchantOrderParams":[{"name":"ClubName","value":"Фитнес плюс"},{"name":"orderNumber","value":"*"},{"name":"phone","value":"*"},{"name":"UserID","value":"*"},{"name":"orderEmail","value":"dimitrii$$Email$$@gmail.com"},{"name":"ClubID","value":"*"},{"name":"orderPhone","value":"*"},{"name":"email","value":"dimitrii$$Email$$@gmail.com"}],"transactionAttributes":[{"name":"merchantIp","value":"*"}],"attributes":[{"name":"mdOrder","value":"*"}],"terminalId":"*","paymentAmountInfo":{"paymentState":"CREATED","approvedAmount":0,"depositedAmount":0,"refundedAmount":0,"feeAmount":0,"totalAmount":150000},"bankInfo":{"bankCountryCode":"UNKNOWN","bankCountryName":"<Неизвестно>"},"payerData":{"email":"dimitrii$$Email$$@gmail.com","phone":"*"},"orderBundle":{"customerDetails":{"email":"dimitrii$$Email$$@gmail.com","phone":"*"},"cartItems":{"items":[{"positionId":"1","name":"$$НоменклатураЮкассы$$","quantity":{"value":1.0,"measure":"0"},"itemAmount":150000,"depositedItemAmount":150000,"itemCurrency":643,"itemCode":"*","itemPrice":150000,"itemAttributes":{"attributes":[{"name":"paymentMethod","value":"7"},{"name":"paymentObject","value":"10"}]}}]}},"chargeback":false}' | 'Ссылка на оплату' |

Сценарий: Проверка оплаты через браузер и обновление статуса заказа.
*Создание продажи.
	Дано Я открываю основную форму документа "Реализация"
	И в поле с именем 'Контрагент' я ввожу текст "$$Фамилия$$"
	И из выпадающего списка с именем 'Контрагент' я выбираю по строке "$$Фамилия$$"
	И я нажимаю на кнопку с именем 'ЗапасыКнопкаДобавить'
	И в таблице 'Запасы' в поле с именем 'ЗапасыНоменклатура' я ввожу текст "$$НоменклатураЮкассы$$"
	И в таблице 'Запасы' из выпадающего списка с именем 'ЗапасыНоменклатура' я выбираю по строке "$$НоменклатураЮкассы$$"
	И я нажимаю на кнопку с именем 'КнопкаОплатитьРеализацию'
	И я нажимаю на кнопку с именем 'КассаОплаты_1'
	Когда открылось окно "Оплата"
	И я снимаю флаг "ЗадолженностьУстановитьСнятьГалочки"
	И я устанавливаю флаг с именем 'ЗадолженностьВыборСтрока_0'
	Когда открылось окно "Оплата"
	И я нажимаю на кнопку с именем 'КнопкаВидыОплатаНаименованиеСтрока_1x4'
	И Я нажимаю на кнопку оплаты 'КнопкаВидыОплатПрименитьеСуммуСтрока_1x4'
	И я нажимаю на кнопку с именем 'Оплатить'
	И я запоминаю значение поля с именем 'СсылкаНаОплату' как 'СсылкаНаОплату'

*Открытие браузера и оплата.
	И я запускаю браузер
	И я открываю ссылку в браузере "$СсылкаНаОплату$"

*Ввод тестовой карты.
	И я Выполняю код Javascript в странице браузера	
	"""
		function setValue(selector, value) {
		const el = document.querySelector(selector);

		el.focus();
		el.value = value;

		el.dispatchEvent(new Event('input', { bubbles: true }));
		el.dispatchEvent(new Event('change', { bubbles: true }));
		el.dispatchEvent(new KeyboardEvent('keyup', { bubbles: true }));
		}

		setValue('input[name="cardnumber"]', '4111111111111111');
		setValue('input[name="expdate"]', '12/34');
		setValue('input[name="cvc"]', '123');
	"""
*Нажатие на кнопку "Оплатить".
	И я Выполняю код Javascript в странице браузера
		"""
			document.querySelector('button[type="submit"]').click();
		"""
	И пауза 2
*Ввод пароля от карты.
	И я активизирую вкладку браузера с заголовком "Подтверждение оплаты"
	И я Выполняю код Javascript в странице браузера
		"""
			var input = document.getElementById('password');
			input.focus();
			input.value = '12345678';

			input.dispatchEvent(new Event('input', { bubbles: true }));
			input.dispatchEvent(new Event('change', { bubbles: true }));

			document.forms['form1'].submit();
		"""
	И я закрываю все вкладки браузера
		
	И я активизирую окно "ВТБ, 05.ВТБ, Основная ораганизация"
	И я нажимаю на кнопку с именем 'ПроверитьСтатус'
	И в течение 10 секунд я выполняю
		Если в логе сообщений TestClient есть строки: Тогда
			|'Заказ ожидает оплаты'|
			Тогда я нажимаю на кнопку с именем 'ПроверитьСтатус'	
		Иначе 
			И я прерываю цикл			

*Проверка json
	И Я проверяю json
	И таблица 'Список' содержит строки по шаблону:
		| 'Клиент'      | 'Статус оплаты в банке'                | 'Статус в 1С' | 'Сумма чека' | 'Платежный шлюз' | 'Эквайринговый терминал'                    | 'Структурная единица' | 'Параметры JSON'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | 'Источник записи'  |
		| '$$Фамилия$$' | 'Заказ зарегистрирован, но не оплачен' | 'Не оплачено' | '3 000,00'   | 'ВТБ'            | '05.ВТБ, Основная ораганизация (эквайринг)' | 'Фитнес плюс'         | '{"errorCode":"0","errorMessage":"Успешно","orderNumber":"*","orderStatus":0,"actionCode":-100,"actionCodeDescription":"","displayErrorMessage":"","amount":300000,"currency":"643","date":*,"orderDescription":"$$НоменклатураЮкассы$$","merchantOrderParams":[{"name":"ClubName","value":"Фитнес плюс"},{"name":"orderNumber","value":"*"},{"name":"phone","value":"*"},{"name":"UserID","value":"*"},{"name":"orderEmail","value":"dimitrii$$Email$$@gmail.com"},{"name":"ClubID","value":"*"},{"name":"orderPhone","value":"*"},{"name":"email","value":"dimitrii$$Email$$@gmail.com"}],"transactionAttributes":[{"name":"merchantIp","value":"*"}],"attributes":[{"name":"mdOrder","value":"*"}],"terminalId":"*","paymentAmountInfo":{"paymentState":"CREATED","approvedAmount":0,"depositedAmount":0,"refundedAmount":0,"feeAmount":0,"totalAmount":300000},"bankInfo":{"bankCountryCode":"UNKNOWN","bankCountryName":"<Неизвестно>"},"payerData":{"email":"dimitrii$$Email$$@gmail.com","phone":"*"},"orderBundle":{"customerDetails":{"email":"dimitrii$$Email$$@gmail.com","phone":"*"},"cartItems":{"items":[{"positionId":"1","name":"$$НоменклатураЮкассы$$","quantity":{"value":1.0,"measure":"0"},"itemAmount":300000,"depositedItemAmount":300000,"itemCurrency":643,"itemCode":"*","itemPrice":300000,"itemAttributes":{"attributes":[{"name":"paymentMethod","value":"1"},{"name":"paymentObject","value":"4"}]}}]}},"chargeback":false}' | 'Ссылка на оплату' |
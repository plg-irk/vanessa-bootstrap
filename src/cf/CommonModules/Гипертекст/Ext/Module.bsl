
#Область ПрограммныйИнтерфейс

// Обрабатывает текст HTML электронного письма.
//
// Параметры:
//  Событие  - ДокументСсылка.ЭлектронноеПисьмоВходящее,
//            ДокументСсылка.ЭлектронноеПисьмоИсходящее - письмо для которого будет проведена оценка.
//  Кодировка - Строка - кодировка текста
//  ТаблицаВложений - Коллекция строк - таблица с колонками Идентификатор, Представление, АдресВоВременномХранилище
//
// Возвращаемое значение:
//   Строка   - обработанный текст электронного письма.
//
Функция ОбработатьТекстHTML(ТекстHTML, Кодировка = Неопределено, ТаблицаВложений = Неопределено) Экспорт
	
	Если ПустаяСтрока(ТекстHTML) Тогда
		Возврат ТекстHTML;
	КонецЕсли;
	
	// Добавим тег HTML если он отсутствует. Такие письма могут приходить к примеру с Gmail. 
	// Необходимо для корректного отображения в элементе формы.
	Если СтрЧислоВхождений(ТекстHTML, "<html") = 0 Тогда
		ТекстHTML = СтрШаблон("<html>%1</html>", ТекстHTML);
	КонецЕсли;
	
	Если ТаблицаВложений = Неопределено Тогда
		Возврат ТекстHTML;
	КонецЕсли;
	
	Если ТаблицаВложений.Количество() = 0 Тогда
		Возврат ТекстHTML;
	КонецЕсли;
	
	ДокументHTML = ЗаменитьИдентификаторыКартинокНаПутьКФайлам(ТекстHTML, ТаблицаВложений, Кодировка);
	
	Возврат ПолучитьТекстHTMLИзОбъектаДокументHTML(ДокументHTML);
	
КонецФункции

// Возвращает структуру "Заголовок, Тело, Окончание",
// где ТекстHTML = Заголовок + Тело + Окончание
// и Тело - содержимое тега body
//
Функция РазложитьТекстHTML(ТекстHTML) Экспорт
	
	Результат = РазложитьЕдиничныйТекстHTML(ТекстHTML);
	
	Окончание = Результат.Окончание;
	Пока СтрНайти(Окончание, "<html") Цикл
		
		РезультатРазложенияПоОкончанию = РазложитьЕдиничныйТекстHTML(Окончание);
		Окончание = РезультатРазложенияПоОкончанию.Окончание;
		Результат.Тело = СтрШаблон("%1%2", Результат.Тело, РезультатРазложенияПоОкончанию.Тело);
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Преобразовывает HTML текст в текст
Функция ПолучитьТекстИзHTML(Знач ТекстHTML, Знач Кодировка = Неопределено) Экспорт
	
	ПереводСтроки = Символы.ВК + Символы.ПС;
	
	ТекстHTML = СтрЗаменить(ТекстHTML, "</o:p>", "</o:p>" + ПереводСтроки);
	ТекстHTML = СтрЗаменить(ТекстHTML, "</o:p>" + ПереводСтроки + ПереводСтроки, "</o:p>" + ПереводСтроки);
	ТекстHTML = СтрЗаменить(ТекстHTML, "</p>", "</p>" + ПереводСтроки);
	ТекстHTML = СтрЗаменить(ТекстHTML, "</p>" + ПереводСтроки + ПереводСтроки, "</p>" + ПереводСтроки);
	ТекстHTML = СтрЗаменить(ТекстHTML, "</div>", "</div>" + ПереводСтроки);
	ТекстHTML = СтрЗаменить(ТекстHTML, "</div>" + ПереводСтроки + ПереводСтроки, "</div>" + ПереводСтроки);
	ТекстHTML = СтрЗаменить(ТекстHTML, "<br>", ПереводСтроки + ПереводСтроки);
	
	Построитель = Новый ПостроительDOM;
	ЧтениеHTML = Новый ЧтениеHTML;
	Если ЗначениеЗаполнено(Кодировка) Тогда
		Попытка
			ЧтениеHTML.УстановитьСтроку(ТекстHTML, Кодировка);
		Исключение	
			ЧтениеHTML.УстановитьСтроку(ТекстHTML); // кодировка могла быть некорректная - ставим без кодировки
		КонецПопытки;	
	Иначе
		ЧтениеHTML.УстановитьСтроку(ТекстHTML);
	КонецЕсли;
	
	ДокументHTML = Построитель.Прочитать(ЧтениеHTML);
	
	Попытка
		УдалитьТегиИзЭлементаHTML(ДокументHTML, "style");
	Исключение
		ЗаписьЖурналаРегистрации("ОшибкаУдаленияТэгов", УровеньЖурналаРегистрации.Ошибка,,, ТекстHTML,);
	КонецПопытки;
	
	Если ДокументHTML.Тело = Неопределено Тогда
		Возврат "";
	КонецЕсли;
	
	Возврат ДокументHTML.Тело.ТекстовоеСодержимое;
	
КонецФункции

// Заменяет в строке все спецсимволы на соответствующие им имена,
// возвращает измененную строку.
//
Функция ЗаменитьСпецСимволыHTML(Строка) Экспорт
	
	СоответствиеСпецСимволов = СоответствиеСпецСимволов();
	
	ЗаменитьСпецСимволHTML(Строка, 38, "amp");
	
	НоваяСтрока = "";
	
	Для Поз = 1 По СтрДлина(Строка) Цикл
		
		Код = КодСимвола(Строка, Поз);
		ИмяСимвола = СоответствиеСпецСимволов.Получить(Код);
		
		Если ИмяСимвола = Неопределено Тогда
			НоваяСтрока = НоваяСтрока + Символ(Код);
		Иначе
			НоваяСтрока = НоваяСтрока + "&" + ИмяСимвола + ";";
		КонецЕсли;
		
	КонецЦикла;
	
	Строка = НоваяСтрока;
	
	Возврат Строка;
	
КонецФункции

// Получает объект ДокументHTML из текста HTML.
//
// Параметры:
//  ТекстHTML  - Строка - текст в формате HTML
//  Кодировка  - Строка - кодировка для ЧтениеHTML
//
// Возвращаемое значение:
//   ДокументHTML   - созданный документ HTML.
//
Функция ПолучитьОбъектДокументHTMLИзТекстаHTML(ТекстHTML, Кодировка = Неопределено) Экспорт
	
	Построитель = Новый ПостроительDOM;
	ЧтениеHTML = Новый ЧтениеHTML;
	
	НовыйТекстHTML = ТекстHTML;
	ПозицияОткрытиеXML = СтрНайти(НовыйТекстHTML,"<?xml");
	
	Если ПозицияОткрытиеXML > 0 Тогда
		
		ПозицияЗакрытиеXML = СтрНайти(НовыйТекстHTML,"?>");
		Если ПозицияЗакрытиеXML > 0 Тогда
			
			НовыйТекстHTML = ЛЕВ(НовыйТекстHTML,ПозицияОткрытиеXML - 1) + ПРАВ(НовыйТекстHTML,СтрДлина(НовыйТекстHTML) - ПозицияЗакрытиеXML -1);
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если Кодировка = Неопределено Тогда
		ЧтениеHTML.УстановитьСтроку(ТекстHTML);
	Иначе
		ЧтениеHTML.УстановитьСтроку(ТекстHTML, Кодировка);
	КонецЕсли;
	Возврат Построитель.Прочитать(ЧтениеHTML);
	
КонецФункции

// Получает текст HTML из объекта ДокументHTML.
//
// Параметры:
//  ДокументHTML  - ДокументHTML - документ, из которого будет извлекаться текст.
//
// Возвращаемое значение:
//   Строка   - текст HTML
//
Функция ПолучитьТекстHTMLИзОбъектаДокументHTML(ДокументHTML) Экспорт
	
	ЗаписьDOM = Новый ЗаписьDOM;
	ЗаписьHTML = Новый ЗаписьHTML;
	ЗаписьHTML.УстановитьСтроку();
	
	Попытка
		
		ЗаписьDOM.Записать(ДокументHTML,ЗаписьHTML);
		Возврат ЗаписьHTML.Закрыть();
		
	Исключение
		
		Возврат "";
		ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ЗаписьЖурналаРегистрации(
			НСтр("ru = 'Гипертекст.Преобразование ДокументаHTML в Строку'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка, , ,
			ТекстОшибки);
		
	КонецПопытки;
	
КонецФункции

// Перенос картинок внутри HTML в разных форматах в Соответствие в формате "cid" 
// 
// Параметры:
//  ТекстHTML - Строка
//  Соответствие - Соответствие
//
Процедура ПеренестиКартинкиВСоответствие(ТекстHTML, Соответствие) Экспорт
	
	ДокументHTML = ПолучитьОбъектДокументHTMLИзТекстаHTML(ТекстHTML);
	
	МассивSRCКартинок = Новый Массив;
	Картинки = ДокументHTML.Картинки;
	Для Каждого Картинка Из Картинки Цикл
		
		ПутьДоКартинки = Картинка.ПолучитьАтрибут("src");
		Если Не ПустаяСтрока(ПутьДоКартинки) И Не СтрНачинаетсяС(ПутьДоКартинки, "?seanceId") Тогда
			МассивSRCКартинок.Добавить(ПутьДоКартинки);
		КонецЕсли;
		
	КонецЦикла;
	
	ИдентификаторBase64 = "base64,";
	
	Для Каждого ПутьДоКартинки Из МассивSRCКартинок Цикл
		
		ИндексBase64 = СтрНайти(ПутьДоКартинки, ИдентификаторBase64);
		Если ИндексBase64 <> 0 Тогда
			
			ИндексНачалаПоиска = ИндексBase64 + СтрДлина(ИдентификаторBase64);
			ДвоичныеДанные = Base64Значение(Сред(ПутьДоКартинки, ИндексНачалаПоиска));
			
		ИначеЕсли ЭтоАдресВременногоХранилища(АдресВременногоХранилищаБезHTTP(ПутьДоКартинки)) Тогда
			ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресВременногоХранилищаБезHTTP(ПутьДоКартинки));
		ИначеЕсли Не СтрНачинаетсяС(ПутьДоКартинки, "e1c") И Не СтрНачинаетсяС(ПутьДоКартинки, "http") Тогда
			
			Попытка
				ДвоичныеДанные = Новый ДвоичныеДанные(ПутьДоКартинки);
			Исключение
				
				ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
				ЗаписьЖурналаРегистрации(
				НСтр("ru = 'Двоичные данные'", ОбщегоНазначения.КодОсновногоЯзыка()),
				УровеньЖурналаРегистрации.Ошибка, , ,
				ТекстОшибки);
				
				Продолжить;
				
			КонецПопытки;
			
		Иначе
			Продолжить;
		КонецЕсли;
		
		СтруктураДанныхКартинки = Новый Структура;
		СтруктураДанныхКартинки.Вставить("Идентификатор", Новый УникальныйИдентификатор);
		СтруктураДанныхКартинки.Вставить("ДвоичныеДанные", ДвоичныеДанные);
		
		Соответствие.Вставить(СтруктураДанныхКартинки.Идентификатор, СтруктураДанныхКартинки);
		
		НовыйSrc = СтрШаблон("cid:%1", СтруктураДанныхКартинки.Идентификатор);
		ТекстHTML = СтрЗаменить(ТекстHTML, ПутьДоКартинки, НовыйSrc);
		
	КонецЦикла;
	
КонецПроцедуры

// Очищает HTTP с параметрами в URL (?...) у SRC картинок
// и переносит их в атрибут data-cleared-http.
// Очистка не проводится, если у картинки есть атрибут data-http-used
// (см ГипертекстКлиент.ПереопределитьHTTPИзАтрибута)
// 
// Параметры:
//  ТекстHTML - Строка - HTML
// 
// Возвращаемое значение:
//  Булево - ТекстHTML был изменен
//
Функция ОчиститьНежелательныеHTTP(ТекстHTML) Экспорт
	
	ТекстHTMLИзменен = Ложь;
	
	Если ПустаяСтрока(СокрЛП(ТекстHTML)) Тогда
		Возврат ТекстHTMLИзменен;
	КонецЕсли;
	
	МассивРасширенийКартинок = Новый Массив;
	МассивРасширенийКартинок.Добавить(".gif");
	МассивРасширенийКартинок.Добавить(".png");
	МассивРасширенийКартинок.Добавить(".jpg");
	МассивРасширенийКартинок.Добавить(".jpeg");
	МассивРасширенийКартинок.Добавить(".tif");
	МассивРасширенийКартинок.Добавить(".bmp");
	
	МаксимальнаяДлинаРасширения = 4;
	
	ДокументHTML = ПолучитьОбъектДокументHTMLИзТекстаHTML(ТекстHTML);
	
	Картинки = ДокументHTML.Картинки;
	АтрибутSRC = Неопределено;
	Для Каждого Картинка Из Картинки Цикл
		
		Если Картинка.ПолучитьАтрибут("data-http-used") <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		АтрибутSRC = Картинка.ПолучитьАтрибут("src");
		Если Лев(АтрибутSRC, 4) <> "http" Тогда
			Продолжить;
		КонецЕсли;
		
		ИндексНачалаРасширения = СтрНайти(АтрибутSRC, ".", , СтрДлина(АтрибутSRC) - МаксимальнаяДлинаРасширения);
		РасширениеФайла = Сред(АтрибутSRC, ИндексНачалаРасширения);
		
		Если СтрНайти(АтрибутSRC, "?")
			Или МассивРасширенийКартинок.Найти(РасширениеФайла) = Неопределено Тогда
			
			Картинка.УстановитьАтрибут("data-cleared-http", АтрибутSRC);
			Картинка.УстановитьАтрибут("src", "");
			ТекстHTMLИзменен = Истина;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Результат = ПолучитьТекстHTMLИзОбъектаДокументHTML(ДокументHTML);
	Если ПустаяСтрока(Результат) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ТекстHTML = Результат;
	Возврат ТекстHTMLИзменен;
	
КонецФункции

// Очищает HTML от нежелательного содержимого, кроме внешних картинок
// 
// Параметры:
//  ТекстHTML - Строка - ТекстHTML
// 
// Возвращаемое значение:
//  Строка - очищенный HTML
// 
Функция ОчищенныйHTMLОтНежелательногоКонтента(Знач ТекстHTML) Экспорт
	
	// Для проверки содержимого src картинок (см Гипертекст.ОчиститьНежелательныеHTTP)
	ТекстHTML = СтрЗаменить(ТекстHTML, "data-http-used", "");
	
	ТекстHTML = СтрЗаменить(ТекстHTML, "contenteditable", "");
	
	// Обработка нежелательных ссылок
	ТекстHTML = СтрЗаменить(ТекстHTML, "bad-link-used", "");
	ТекстHTML = СтрЗаменить(ТекстHTML, "header-link", "");
	
	ДокументHTML = ПолучитьОбъектДокументHTMLИзТекстаHTML(ТекстHTML);
	
	// СтандартныеПодсистемы.РаботаСПочтовымиСообщениями
	РаботаСПочтовымиСообщениями.ОтключитьНебезопасноеСодержимое(ДокументHTML, Ложь);
	// Конец СтандартныеПодсистемы.РаботаСПочтовымиСообщениями
	
	ОписаниеТипа = Новый ОписаниеТипов("Число");
	Для Каждого Картинка Из ДокументHTML.Картинки Цикл
		
		Если ОписаниеТипа.ПривестиЗначение(Картинка.ПолучитьАтрибут("width")) = 1
			Или ОписаниеТипа.ПривестиЗначение(Картинка.ПолучитьАтрибут("height")) = 1 Тогда
			Картинка.УстановитьАтрибут("src", "");
		КонецЕсли;
		
	КонецЦикла;
	
	Результат = ПолучитьТекстHTMLИзОбъектаДокументHTML(ДокументHTML);
	
	Если ПустаяСтрока(Результат) Тогда
		Возврат ТекстHTML;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Получает HTML из форматированного документа, заменяет параграфы на блоки, преобразует картинки в двоичные данные
//
// Параметры:
//  ФД - ФорматированныйДокумент - форматированный документ
// 
// Возвращаемое значение:
//  Строка - HTML с картинками в двоичных данных
//
Функция HTMLИзФорматированногоДокумента(ФД) Экспорт
	
	Результат = "";
	
	КартинкиHTML = Новый Структура;
	ФД.ПолучитьHTML(Результат, КартинкиHTML);
	
	ПеревестиТекстHTMLИзФорматированногоДокументаВОбычныйHTML(Результат, КартинкиHTML);
	
	Возврат Результат;
	
КонецФункции

// Заменяет параграфы на блоки, преобразует картинки в двоичные данные
//
// Параметры:
//  ТекстHTML - Строка - текст HTML от форматированного документа
//  КартинкиHTML - Структура - см ФорматированныйДокумент
//
Процедура ПеревестиТекстHTMLИзФорматированногоДокументаВОбычныйHTML(ТекстHTML, КартинкиHTML) Экспорт
	
	ТекстHTML = РазложитьТекстHTML(ТекстHTML).Тело;
	
	ПоместитьКартинкиИзСтруктурыВHTML(ТекстHTML, КартинкиHTML);
	
	ТекстHTML = СтрЗаменить(ТекстHTML, "<p", "<div");
	ТекстHTML = СтрЗаменить(ТекстHTML, "</p>", "</div>");
	
	ТекстHTML = СтрШаблон("<html><body style=""line-height: 1.15;"">%1</body></html>", ТекстHTML);
	
КонецПроцедуры

// Добавляет в HTML теги html и body, если таковых там нет
//
// Параметры:
//  ТекстHTML - Строка - текст формата HTML
// 
// Возвращаемое значение:
//  Строка - новый HTML
//
Функция HTMLСТегамиHtmlИBody(ТекстHTML) Экспорт
	
	ЕстьТегHtml = СтрНайти(ТекстHTML, "<html");
	ЕстьТегBody = СтрНайти(ТекстHTML, "<body");
	
	Если ЕстьТегHtml И ЕстьТегBody Тогда
		Возврат ТекстHTML;
	КонецЕсли;
	
	Если Не ЕстьТегHtml И Не ЕстьТегBody Тогда
		Возврат СтрШаблон("<html><body>%1</body></html>", ТекстHTML);
	КонецЕсли;
	
	Если ЕстьТегBody Тогда
		Возврат СтрШаблон("<html>%1</html>", ТекстHTML);
	КонецЕсли;
	
	КонецТега = СтрНайти(ТекстHTML, "</html");
	Если Не КонецТега Тогда
		ТекстHTML = СтрШаблон("%1</html>", ТекстHTML);
		КонецТега = СтрНайти(ТекстHTML, "</html");
	КонецЕсли;
	
	ПраваяКавычка = СтрНайти(ТекстHTML, ">");
	
	Возврат СтрШаблон("<html><body>%1</body></html>",
	Сред(ТекстHTML, ПраваяКавычка + 1, КонецТега - ПраваяКавычка - 1));
	
КонецФункции

#Область РаботаСHTMLПолем

// Добавляет переданный тег в <head>
// 
// Параметры:
//  ТекстHTML - Строка
//  НазваниеТега - Строка
//  Содержание - Строка
//
Процедура ДобавитьТегВHead(ТекстHTML, НазваниеТега, Содержание) Экспорт
	
	Содержание = СтрШаблон("<%1>%2</%1>", НазваниеТега, Содержание);
	
	ИндексТегаДляПоиска = СтрНайти(ТекстHTML, "<head");
	
	Если ИндексТегаДляПоиска = 0 Тогда
		
		ИндексТегаДляПоиска = СтрНайти(ТекстHTML, "<html");
		ИндексПравойКавычки = СтрНайти(ТекстHTML, ">", , ИндексТегаДляПоиска);
		
		ЧастьДоТега = Сред(ТекстHTML, 1, ИндексТегаДляПоиска - 1);
		ЧастьПослеТега = Сред(ТекстHTML, ИндексПравойКавычки + 1);
		
		ТекстHTML = СтрШаблон(
			"%1<html><head>%2</head>%3",
			ЧастьДоТега,
			Содержание,
			ЧастьПослеТега);
		
	Иначе
		
		ИндексПравойКавычки = СтрНайти(ТекстHTML, ">", , ИндексТегаДляПоиска);
		
		ЧастьДоТега = Сред(ТекстHTML, 1, ИндексТегаДляПоиска - 1);
		ЧастьПослеТега = Сред(ТекстHTML, ИндексПравойКавычки + 1);
		
		ТекстHTML = СтрШаблон(
			"%1<head>%2%3",
			ЧастьДоТега,
			Содержание,
			ЧастьПослеТега);
		
	КонецЕсли;
	
КонецПроцедуры

// Добавление общего JS кода
// см ДобавитьКодДляИзмененияИзображений, ДобавитьКодДляИзмененияТаблиц, ДобавитьКодДляПереопределенияНажатияКлавиш
// 
// Параметры:
//  ТекстHTML - Строка
//
Процедура ДобавитьJSКод(ТекстHTML) Экспорт
	
	ДобавитьКодДляПереопределенияНажатияКлавиш(ТекстHTML);
	ДобавитьКодДляИзмененияИзображений(ТекстHTML);
	ДобавитьКодДляИзмененияТаблиц(ТекстHTML);
	
КонецПроцедуры

// Добавление JS и CSS кода для интерактивного изменения изображений
// 
// Параметры:
//  ТекстHTML - Строка
//
Процедура ДобавитьКодДляИзмененияИзображений(ТекстHTML) Экспорт
	
	Если СтрНайти(ТекстHTML, "Код для изменения изображений добавлен") Тогда
		Возврат;
	КонецЕсли;
	
	КодJS = "
	|// Код для изменения изображений добавлен
	|document.addEventListener('DOMContentLoaded', setResizableToImages);
	|document.addEventListener('mouseup', mouseupImages);
	|document.addEventListener('mousemove', mousemoveImages);
	|document.addEventListener('dragstart', (e) => e.preventDefault());
	|
	|function setResizableToImages() {
	|   for (const img of document.images) {
	|	   if (!img.getAttribute('data-default-height')) {
	|         img.setAttribute('data-default-height', img.height);
	|         img.setAttribute('data-default-width', img.width);
	|	   }
	|
	|      let parent = img.parentNode;
	|
	|      if (parent.classList.contains('img-wrapper')) {
	|         parent.contentEditable = false;
	|         
	|         parent.querySelector('.img-right').onmousedown = () =>
	|            resizeImage(true, false);
	|         parent.querySelector('.img-bottom').onmousedown = () =>
	|            resizeImage(false, true);
	|         parent.querySelector('.img-corner').onmousedown = () =>
	|            resizeImage(true, true);
	|         continue;
	|      }
	|      
	|      if (parent.children.length != 1) {
	|         const newParent = document.createElement('div');
	|         parent.insertBefore(newParent, img);
	|         
	|         newParent.appendChild(img.cloneNode(true));
	|         parent.removeChild(img);
	|
	|         parent = newParent;
	|      }
	|
	|	   parent.classList.add('img-editor');
	|
	|	   const wrapper = document.createElement('div');
	|	   wrapper.classList.add('img-wrapper');
	|	   wrapper.contentEditable = false;
	|	   wrapper.append(parent.firstElementChild.cloneNode(true));
	|
	|	   parent.removeChild(parent.firstElementChild);
	|	   parent.append(wrapper);
	|
	|	   parent = wrapper;
	|
	|	   const inputBlock = document.createElement('div');
	|	   inputBlock.innerHTML = '<br>';
	|	   parent.parentNode.after(inputBlock);
	|
	|	   parent.innerHTML += `
	|	   <div class=""img-right"" onmousedown=""resizeImage(true, false)""></div>
	|	   <div class=""img-bottom"" onmousedown=""resizeImage(false, true)""></div>
	|	   <div class=""img-corner"" onmousedown=""resizeImage(true, true)""></div>
	|	   `;
	|   }
	|}
	|
	|let resizeDataImages = undefined;
	|
	|function resizeImage(horizontalResize = false, verticalResize = false) {
	|   const elem = event.target.parentNode.querySelector('img');
	|   
	|   const defaultHeight = elem.getAttribute(""data-default-height"");
	|   const defaultWidth = elem.getAttribute(""data-default-width"");
	|   if (!defaultHeight || defaultHeight == ""0"") {
	|   	elem.setAttribute(""data-default-height"", elem.height);
	|   }
	|   if (!defaultWidth || defaultWidth == ""0"") {
	|   	elem.setAttribute(""data-default-width"", elem.width);
	|   }
	|
	|   elem.height = elem.height;
	|   elem.width = elem.width;
	|
	|   resizeDataImages = {
	|      elem,
	|      x: event.clientX - elem.offsetWidth,
	|      y: event.clientY - elem.offsetHeight,
	|      horizontalResize,
	|      verticalResize,
	|      aspectRatio: elem.width / elem.height,
	|      wasChanged: false,
	|   };
	|}
	|
	|function mouseupImages() {
	|   if (resizeDataImages) {
	|      if (resizeDataImages.wasChanged) {
	|         if (window.recordHTML) {
	|            recordHTML();
	|         }
	|      }
	|
	|      resizeDataImages = undefined;
	|   }
	|}
	|
	|function mousemoveImages() {
	|   if (!resizeDataImages) return;
	|
	|   const {
	|      elem,
	|      x,
	|      y,
	|      horizontalResize,
	|      verticalResize,
	|      aspectRatio,
	|      wasChanged,
	|   } = resizeDataImages;
	|
	|   if (!horizontalResize && !verticalResize) return;
	|
	|   if (horizontalResize && verticalResize) {
	|      let ny = event.clientY - y;
	|      if (ny < 20) return;
	|
	|      elem.height = ny;
	|      elem.width = aspectRatio * ny;
	|   } else if (horizontalResize) {
	|      let nx = event.clientX - x;
	|      if (nx < 20) return;
	|
	|      elem.width = nx;
	|   } else {
	|      let ny = event.clientY - y;
	|      if (ny < 20) return;
	|
	|      elem.height = ny;
	|   }
	|
	|   if (!wasChanged) resizeDataImages.wasChanged = true;
	|}";
	
	ДобавитьТегВHead(ТекстHTML, "script", КодJS);
	
	КодCSS = "
	|.img-editor {
	|	display: inline-block;
	|	width: 100%;
	|}
	|
	|.img-wrapper {
	|   position: relative;
	|   display: inline-block;
	|}
	|
	|.img-wrapper::before {
	|   position: absolute;
	|   background-color: transparent;
	|   left: 3px;
	|   right: 3px;
	|   top: 3px;
	|   bottom: 3px;
	|   border: 3px dotted #dcdcdc;
	|}
	|
	|.img-wrapper:hover::before {
	|   content: '';
	|}
	|
	|.img-right {
	|   cursor: e-resize;
	|   position: absolute;
	|   width: 15px;
	|   top: 0;
	|   bottom: 5px;
	|   right: -5px;
	|}
	|
	|.img-bottom {
	|   cursor: s-resize;
	|   position: absolute;
	|   height: 15px;
	|   left: 0;
	|   right: 5px;
	|   bottom: -5px;
	|}
	|
	|.img-corner {
	|   cursor: se-resize;
	|   position: absolute;
	|   height: 10px;
	|   width: 10px;
	|   right: -5px;
	|   bottom: -5px;
	|}";
	
	ДобавитьТегВHead(ТекстHTML, "style", КодCSS);
	
КонецПроцедуры

// Добавление JS и CSS кода для интерактивного изменения таблиц
// 
// Параметры:
//  ТекстHTML - Строка
//
Процедура ДобавитьКодДляИзмененияТаблиц(ТекстHTML) Экспорт
	
	Если СтрНайти(ТекстHTML, "Код для изменения таблиц добавлен") Тогда
		Возврат;
	КонецЕсли;
	
	КодJS = "
	|// Код для изменения таблиц добавлен
	|
	|document.addEventListener('DOMContentLoaded', () => setResizableToTables(false));
	|document.addEventListener('mouseup', mouseupTables);
	|document.addEventListener('mousemove', mousemoveTables);
	|document.addEventListener('dragstart', (e) => e.preventDefault());
	|
	|function directChildren(parent, selector) {
	|   const children = parent.children;
	|   const result = [];
	|
	|   for (const elem of children) {
	|      if (elem.matches(selector)) {
	|         result.push(elem);
	|      }
	|   }
	|
	|   return result;
	|}
	|
	|function setResizableToTables(refactorNew = false) {
	|   const tables = document.querySelectorAll('table');
	|
	|   for (const table of tables) {
	|      let parent = table.parentNode;
	|
	|      if (parent.classList.contains('table-wrapper')) {
	|         parent.style.width = '100%';
	|         
	|		  let elems = parent.querySelectorAll('.table-bottom');
	|		  for (const elem of elems) {
	|		  	  elem.parentNode.removeChild(elem);
	|		  }
	|		  elems = parent.querySelectorAll('.table-right');
	|		  for (const elem of elems) {
	|			  elem.parentNode.removeChild(elem);
	|		  }
	|      }
	|      
	|	   // Для совместимости после вставки таблиц с помощью Ctrl+V
	|      if (refactorNew && !table.getAttribute('data-our-ready-table')) {
	|		  table.setAttribute('data-our-ready-table', true);
	|
	|         for (const child of table.children) {
	|            if (child.nodeName != 'TBODY') {
	|               table.removeChild(child);
	|            }
	|         }
	|         if (table.getAttribute('width') != '100%') {
	|            table.removeAttribute('width');
	|         }
	|         table.removeAttribute('style');
	|         table.setAttribute('border', '');
	|         table.setAttribute('cellspacing', '0');
	|
	|         const trs = table.firstElementChild.children;
	|
	|         let trHeight = 0;
	|         let trWidth = 0;
	|         let tdHeight = 0;
	|         let tdWidth = 0;
	|         for (const tr of trs) {
	|            if (trHeight && trWidth && tdHeight && tdWidth) {
	|               break;
	|            }
	|
	|            if (!trHeight && tr.height) {
	|               trHeight = tr.height;
	|            }
	|            if (!trWidth && tr.width) {
	|               trWidth = tr.width;
	|            }
	|
	|            for (const td of tr.children) {
	|               if (tdHeight && tdWidth) {
	|                  break;
	|               }
	|
	|               if (!tdHeight && td.height) {
	|                  tdHeight = td.height;
	|               }
	|
	|               if (!tdWidth && td.width) {
	|                  tdWidth = td.width;
	|               }
	|            }
	|         }
	|
	|         for (const tr of trs) {
	|            tr.style.border = null;
	|            tr.style.width = null;
	|            tr.style.height = null;
	|            tr.height = trHeight;
	|            tr.width = trWidth;
	|
	|            for (const td of tr.children) {
	|               td.style.border = null;
	|               td.style.width = null;
	|               td.style.height = null;
	|               td.height = tdHeight;
	|               td.width = tdWidth;
	|            }
	|         }
	|      }
	|	   ////
	|
	|      if (parent.children.length != 1) {
	|         const newParent = document.createElement('div');
	|         parent.insertBefore(newParent, table);
	|
	|         newParent.appendChild(table.cloneNode(true));
	|         parent.removeChild(table);
	|
	|         parent = newParent;
	|      }
	|      
	|	   if (!parent.classList.contains('table-wrapper')) {
	|      	  parent.classList.add('table-wrapper');
	|         
	|		  const inputBlock = document.createElement('div');
	|		  inputBlock.innerHTML = '<br>';
	|		  parent.after(inputBlock);
	|	   }
	|      parent.style.width = '100%';
	|
	|      let blockForResizing = undefined;
	|      const trs = directChildren(
	|         parent.firstElementChild.firstElementChild,
	|         'tr'
	|      );
	|      for (let i = 0; i < trs.length; i++) {
	|         blockForResizing = document.createElement('div');
	|         blockForResizing.classList.add('table-bottom');
	|         blockForResizing.onmousedown = () => resizeTable(false);
	|         blockForResizing.contentEditable = false;
	|         blockForResizing.setAttribute('data-row-id', i);
	|         parent.appendChild(blockForResizing);
	|      }
	|
	|      const tds = trs[0].children;
	|      for (let i = 0; i < tds.length; i++) {
	|         blockForResizing = document.createElement('div');
	|         blockForResizing.classList.add('table-right');
	|         blockForResizing.onmousedown = () => resizeTable(true);
	|         blockForResizing.contentEditable = false;
	|         blockForResizing.setAttribute('data-col-id', i);
	|         parent.appendChild(blockForResizing);
	|      }
	|
	|      moveTableLines(parent);
	|   }
	|}
	|
	|let resizeDataTables = undefined;
	|
	|function moveTableLines(tableWrapper) {
	|   const tds = tableWrapper.querySelector('tr').children;
	|
	|   const tdWidths = [];
	|   for (const td of tds) {
	|      tdWidths.push(td.offsetWidth);
	|   }
	|
	|   const offsetWidths = [tdWidths[0]];
	|   tdWidths
	|      .slice(1)
	|      .forEach((width, i) => offsetWidths.push(offsetWidths[i] + width));
	|
	|   let lines = directChildren(tableWrapper, '.table-right');
	|   lines.forEach((line, i) => (line.style.left = offsetWidths[i] - 5 + 'px'));
	|
	|   ////
	|
	|   const trs = directChildren(
	|      tableWrapper.firstElementChild.firstElementChild,
	|      'tr'
	|   );
	|
	|   const trHeights = [];
	|   for (const tr of trs) {
	|      trHeights.push(tr.offsetHeight);
	|   }
	|
	|   const offsetHeights = [trHeights[0]];
	|   trHeights
	|      .slice(1)
	|      .forEach((height, i) => offsetHeights.push(offsetHeights[i] + height));
	|
	|   lines = directChildren(tableWrapper, '.table-bottom');
	|   lines.forEach((line, i) => (line.style.top = offsetHeights[i] - 5 + 'px'));
	|}
	|
	|function resizeTable(horizontalResize = false) {
	|   resizeDataTables = {};
	|
	|   let elems = [];
	|
	|	const target = event.target;
	|	const table = target.parentNode.querySelector('table');
	|	const tbody = table.querySelector('tbody');
	|
	|   if (horizontalResize) {
	|		const colId = parseInt(target.getAttribute('data-col-id'));
	|
	|		resizeDataTables.initialClientX = event.clientX;
	|
	|		resizeDataTables.leftElemsWidth =
	|			tbody.children[0].children[colId].offsetWidth;
	|		let tempElems = [];
	|		for (const tr of tbody.children) {
	|			tempElems.push(tr.children[colId]);
	|		}
	|		elems.push(tempElems);
	|
	|		if (tbody.children[0].children.length > colId + 1) {
	|			resizeDataTables.rightElemsWidth =
	|				tbody.children[0].children[colId + 1].offsetWidth;
	|			resizeDataTables.newInitialClientXBeenSet = false;
	|
	|			tempElems = [];
	|			for (const tr of tbody.children) {
	|				tempElems.push(tr.children[colId + 1]);
	|			}
	|			elems.push(tempElems);
	|		}
	|   } else {
	|		const rowId = parseInt(target.getAttribute('data-row-id'));
	|
	|		const tr = tbody.children[rowId];
	|		resizeDataTables.topElemsHight = tr.offsetHeight;
	|		resizeDataTables.initialClientY = event.clientY;
	|
	|		elems = tr.children;
	|   }
	|	resizeDataTables.tableWrapper = table.parentNode;
	|	resizeDataTables.table = table;
	|   resizeDataTables.elems = elems;
	|   resizeDataTables.horizontalResize = horizontalResize;
	|   resizeDataTables.wasChanged = false;
	|}
	|
	|function mouseupTables() {
	|   if (resizeDataTables) {
	|      if (resizeDataTables.wasChanged) {
	|         if (resizeDataTables.tableWrapper) {
	|            moveTableLines(resizeDataTables.tableWrapper);
	|         }
	|		 
	|		  if (window.recordHTML) {
	|            recordHTML();
	|         }
	|      }
	|
	|      resizeDataTables = undefined;
	|   }
	|}
	|
	|function mousemoveTables() {
	|   if (!resizeDataTables) return;
	|
	|	const {
	|		elems,
	|		horizontalResize,
	|		tableWrapper,
	|		table,
	|		wasChanged,
	|		newInitialClientXBeenSet,
	|		rightElemsWidth,
	|		initialClientY,
	|		topElemsHight,
	|	} = resizeDataTables;
    |
	|	let initialClientX = resizeDataTables.initialClientX;
    |
	|	if (horizontalResize) {
	|		const currentClientX = event.clientX;
	|		const newLeftWidth =
	|			currentClientX - initialClientX + resizeDataTables.leftElemsWidth;
	|		if (newLeftWidth < 20) return;
    |
	|		if (table.offsetWidth >= tableWrapper.offsetWidth - 10) {
	|			if (elems.length == 1) {
	|				if (currentClientX >= initialClientX) {
	|					return;
	|				}
	|			} else {
	|				if (!newInitialClientXBeenSet) {
	|					resizeDataTables.initialClientX = currentClientX;
	|					initialClientX = currentClientX;
    |
	|					resizeDataTables.leftElemsWidth = newLeftWidth;
    |
	|					resizeDataTables.newInitialClientXBeenSet = true;
	|				}
    |
	|				const newRightWidth =
	|					initialClientX - currentClientX + rightElemsWidth;
	|				if (newRightWidth < 20) return;
	|				for (const td of elems[1]) {
	|					td.width = newRightWidth;
	|				}
	|			}
	|		}
	|
	|		for (const td of elems[0]) {
	|			td.width = newLeftWidth;
	|		}
	|	} else {
	|		const currentClientY = event.clientY;
	|		const newTopHeight = currentClientY - initialClientY + topElemsHight;
	|		if (newTopHeight < 20) return;
	|
	|		for (const td of elems) {
	|			td.height = newTopHeight;
	|		}
	|	}
	|
	|   if (!wasChanged) resizeDataTables.wasChanged = true;
	|}";
	
	ДобавитьТегВHead(ТекстHTML, "script", КодJS);
	
	КодCSS = "
	|.table-wrapper {
	|   position: relative;
	|   display: inline-block;
	|}
	|
	|.table-bottom {
	|   cursor: row-resize;
	|   position: absolute;
	|   height: 10px;
	|   left: 0;
	|   right: 0;
	|}
	|
	|.table-right {
	|   cursor: col-resize;
	|   position: absolute;
	|   top: 0;
	|   bottom: 0;
	|   width: 10px;
	|}
	|";
	
	ДобавитьТегВHead(ТекстHTML, "style", КодCSS);
	
КонецПроцедуры

// Добавление JS кода для установки собственной реализации нажатия клавиш
// В том числе тут же реализовано и сохранение истории документа
// 
// Параметры:
//  ТекстHTML - Строка
//
Процедура ДобавитьКодДляПереопределенияНажатияКлавиш(ТекстHTML) Экспорт
	
	Если СтрНайти(ТекстHTML, "Код JS для UndoRedo добавлен") Тогда
		Возврат;
	КонецЕсли;
	
	ДобавитьКодДляРаботыСЭлементами(ТекстHTML);
	
	Код = "
	|// Код JS для UndoRedo добавлен
	|
	|let history = [''];
	|let currentIndex = 0;
	|
	|function undo() {
	|	if (currentIndex) {
	|		currentIndex--;
	|	}
	|
	|	setChangedHTML();
	|}
	|
	|function redo() {
	|	if (currentIndex !== history.length - 1) {
	|		currentIndex++;
	|	}
	|
	|	setChangedHTML();
	|}
	|
	|function setChangedHTML() {
	|	document.body.innerHTML = history[currentIndex];
	|
	|	if (window.setResizableToImages) {
	|		setTimeout(setResizableToImages, 10);
	|	}
	|
	|	if (window.setResizableToTables) {
	|		setTimeout(() => setResizableToTables(false), 10);
	|	}
	|}
	|
	|function recordHTML() {
	|	setTimeout(() => {
	|		history = history.slice(0, currentIndex + 1);
	|		history.push(document.body.innerHTML);
	|		currentIndex++;
	|	}, 0);
	|}
	|
	|let tablesResizableIntervalID = undefined;
	|let tablesResized = false;
	|
	|function handlePasteCommand(e, keyCode) {
	|	if (!(keyCode == 86 && e.ctrlKey)) {
	|		return;
	|	}
	|
	|	if (window.setResizableToImages) {
	|		setTimeout(setResizableToImages, 10);
	|	}
	|
	|	if (window.setResizableToTables) {
	|		setTimeout(() => setResizableToTables(true), 10);
	|		tablesResized = true;
	|	}
	|}
	|
	|function handleBackspaceCommand(keyCode) {
	|	if (keyCode != 8) {
	|		return true;
	|	}
	|
	|	const elems = selectedElems();
	|	if (!elems.length) {
	|		return true;
	|	}
	|
	|	let insideTable = false;
	|	for (const elem of elems) {
	|		if (elem.nodeName == 'TD' || elem.nodeName == 'TR') {
	|			insideTable = true;
	|			break;
	|		}
	|
	|		const parents = elementParents(elem);
	|		for (const parent of parents) {
	|			if (parent == 'TD' || parent == 'TR') {
	|				insideTable = true;
	|				break;
	|			}
	|		}
	|
	|		if (insideTable) {
	|			break;
	|		}
	|	}
	|
	|	if (!insideTable) {
	|		return true;
	|	}
	|
	|	for (const elem of elems) {
	|		if (elem.nodeName == 'TR') {
	|			for (const td of elem.children) {
	|				td.innerHTML = '&nbsp;';
	|			}
	|		} else if (elem.nodeName == 'TD') {
	|			elem.innerHTML = '&nbsp;';
	|		}
	|	}
	|
	|	return false;
	|}
	|
	|function handleCommonKeys(e, keyCode) {
	|	handlePasteCommand(e, keyCode);
	|
	|	const backspaceCommandRes = handleBackspaceCommand(keyCode);
	|	if (!backspaceCommandRes) {
	|		return false;
	|	}
	|
	|	recordHTML();
	|
	|	return true;
	|}
	|
	|document.onkeydown = e => {
	|	const keyCode = window.event.keyCode;
	|	if (e.ctrlKey && (keyCode === 90 || keyCode === 89)) {
	|		// 90 -> 'z', 89 -> 'y'
	|		e.preventDefault();
	|
	|		if (keyCode === 90) {
	|			undo();
	|		} else {
	|			redo();
	|		}
	|	} else if (keyCode != 17 && !(e.ctrlKey && keyCode === 67)) {
	|		// 17 -> 'Control', 67 -> 'c'
	|		const res = handleCommonKeys(e, keyCode);
	|		if (!res) {
	|			return false;
	|		}
	|	}
	|
	|	if (window.setResizableToTables) {
	|		if (tablesResized) {
	|			tablesResized = false;
	|		} else {
	|			clearTimeout(tablesResizableIntervalID);
	|			tablesResizableIntervalID = setTimeout(
	|				() => setResizableToTables(false),
	|				500
	|			);
	|		}
	|	}
	|};";
	
	ДобавитьТегВHead(ТекстHTML, "script", Код);
	
КонецПроцедуры

// Меняет src картинок в HTML на двоичные данные в формате Base64
// 
// Параметры:
//  ТекстПисьма - Строка - HTML
// 
// Возвращаемое значение:
//  Строка - текст в форме HTML
//
Функция ТекстHTMLСКартинкамиВДвоичныхДанных(Знач ТекстПисьма) Экспорт
	
	Результат = ТекстПисьма;
	
	МассивSRCКартинок = Новый Массив;
	
	ДокументHTML = ПолучитьОбъектДокументHTMLИзТекстаHTML(ТекстПисьма);
	Картинки = ДокументHTML.Картинки;
	Для Каждого Картинка Из Картинки Цикл
		МассивSRCКартинок.Добавить(Картинка.ПолучитьАтрибут("src"));
	КонецЦикла;
	
	Для Каждого ПутьКартинки Из МассивSRCКартинок Цикл
		Если СтрНайти(ПутьКартинки, "base64") Тогда
			Продолжить;
		КонецЕсли;
		
		ПутьКартинкиБезHTTP = АдресВременногоХранилищаБезHTTP(ПутьКартинки);
		Если ЭтоАдресВременногоХранилища(ПутьКартинкиБезHTTP) Тогда
			
			ДанныеВФорматеBase64 = Base64Строка(ПолучитьИзВременногоХранилища(ПутьКартинкиБезHTTP));
			НовыйПутьКартинки = СтрШаблон("data:image/jpg;base64,%1", ДанныеВФорматеBase64);
			Результат = СтрЗаменить(Результат, ПутьКартинки, НовыйПутьКартинки);
			
		ИначеЕсли Не ПустаяСтрока(ПутьКартинки) И СтрНайти(ПутьКартинки, "http") = 0 И СтрНайти(ПутьКартинки, "cid") = 0 Тогда
			
			Результат = СтрЗаменить(Результат, ПутьКартинки, "");
			
		Иначе
			Продолжить;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция РазложитьЕдиничныйТекстHTML(ТекстHTML) Экспорт
	
	НРегТекстHTML = НРег(ТекстHTML);
	
	ПозицияНачалаТела = 1;
	ПозицияОкончанияТела = СтрДлина(ТекстHTML);
	
	ПозицияНачалаТегаHTML = СтрНайти(НРегТекстHTML, "<html");
	Если ПозицияНачалаТегаHTML > 0 Тогда
		ПозицияОкончанияТегаHTML = НайтиПосле(НРегТекстHTML, ">", ПозицияНачалаТегаHTML);
		Если ПозицияОкончанияТегаHTML > 0 Тогда
			ПозицияНачалаТела = ПозицияОкончанияТегаHTML + 1;
		КонецЕсли;
	КонецЕсли;
	
	ПозицияНачалаТегаBODY = НайтиПосле(НРегТекстHTML, "<body", ПозицияНачалаТела - 1);
	Если ПозицияНачалаТегаBODY > 0 Тогда
		ПозицияОкончанияТегаBODY = НайтиПосле(НРегТекстHTML, ">", ПозицияНачалаТегаBODY);
		Если ПозицияОкончанияТегаBODY > 0 Тогда
			ПозицияНачалаТела = ПозицияОкончанияТегаBODY + 1;
		КонецЕсли;
	КонецЕсли;
	
	ПозицияНачалаЗакрывающегоТегаBODY = НайтиПосле(НРегТекстHTML, "</body", ПозицияНачалаТела - 1);
	Если ПозицияНачалаЗакрывающегоТегаBODY > 0 Тогда
		ПозицияОкончанияТела = ПозицияНачалаЗакрывающегоТегаBODY - 1;
	Иначе
		ПозицияНачалаЗакрывающегоТегаHTML = НайтиПосле(НРегТекстHTML, "</html", ПозицияНачалаТела - 1);
		Если ПозицияНачалаЗакрывающегоТегаHTML > 0 Тогда
			ПозицияОкончанияТела = ПозицияНачалаЗакрывающегоТегаHTML - 1;
		КонецЕсли;
	КонецЕсли;
	
	Заголовок = Лев(ТекстHTML, ПозицияНачалаТела - 1);
	Тело = Сред(ТекстHTML, ПозицияНачалаТела, ПозицияОкончанияТела - ПозицияНачалаТела + 1);
	Окончание = Сред(ТекстHTML, ПозицияОкончанияТела + 1);
	
	Результат = Новый Структура("Заголовок, Тело, Окончание", Заголовок, Тело, Окончание);
	
	Возврат Результат;
	
КонецФункции

Процедура ПоместитьКартинкиИзСтруктурыВHTML(ТекстHTML, КартинкиHTML)
	
	Для Каждого Картинка Из КартинкиHTML Цикл
		
		ДвоичныеДанные = Картинка.Значение.ПолучитьДвоичныеДанные();
		ДанныеСтрокой = Base64Строка(ДвоичныеДанные);
		
		СтарыйSRC = СтрШаблон("src=""%1""", Картинка.Ключ);
		НовыйSRC = СтрШаблон("src=""data:image/jpg;base64,%1""", ДанныеСтрокой);
		ТекстHTML = СтрЗаменить(ТекстHTML, СтарыйSRC, НовыйSRC);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ДобавитьКодДляРаботыСЭлементами(ТекстHTML)
	
	Если СтрНайти(ТекстHTML, "Код для работы с элементами добавлен") Тогда
		Возврат;
	КонецЕсли;
	
	Код = "
	|// Код для работы с элементами добавлен
	|
	|function elementParents(elem) {
	|	const res = [];
	|
	|	if (!elem) {
	|		return res;
	|	}
	|
	|	while (elem.parentNode) {
	|		res.push(elem.parentNode);
	|		elem = elem.parentNode;
	|	}
	|
	|	return res;
	|}
	|
	|function generalParent(elem1, elem2) {
	|	const parents1 = elementParents(elem1);
	|	const parents2 = elementParents(elem2);
	|
	|	let res = undefined;
	|
	|	for (const parent1 of parents1) {
	|		for (const parent2 of parents2) {
	|			if (parent1 == parent2) {
	|				res = parent1;
	|				break;
	|			}
	|		}
	|
	|		if (res) {
	|			break;
	|		}
	|	}
	|
	|	return res;
	|}
	|
	|function areElementsMerged(parent, elem) {
	|	let node = elem;
	|	while (node) {
	|		if (node == parent) {
	|			return true;
	|		}
	|
	|		node = node.parentNode;
	|	}
	|
	|	return false;
	|}
	|
	|function elementsBetween(parent, elem1, elem2) {
	|	let res = [];
	|
	|	let areElementsBetween = false;
	|	for (const elem of parent.children) {
	|		if (areElementsMerged(elem, elem1) || areElementsMerged(elem, elem2)) {
	|			areElementsBetween = res.length == 0;
	|			res.push(elem);
	|		} else if (res.length) {
	|			if (areElementsBetween) {
	|				res.push(elem);
	|			} else {
	|				return res;
	|			}
	|		}
	|	}
	|
	|	if (res.length == 0) {
	|		res.push(parent);
	|		return res;
	|	}
	|
	|	if (
	|		areElementsMerged(res[res.length - 1], elem1) ||
	|		areElementsMerged(res[res.length - 1], elem2)
	|	) {
	|		return res;
	|	}
	|
	|	const firstElem = res[0];
	|	res = [];
	|	res.push(firstElem);
	|	return res;
	|}
	|
	|function pointedElem() {
	|	return window.getSelection().anchorNode;
	|}
	|
	|function hilightedElems() {
	|	const selection = window.getSelection();
	|	const res = [];
	|
	|	if (selection.isCollapsed) {
	|		return res;
	|	}
	|
	|	const elem1 = selection.anchorNode;
	|	const elem2 = selection.focusNode;
	|
	|	const parent = generalParent(elem1, elem2);
	|	if (!parent) {
	|		return res;
	|	}
	|
	|	return elementsBetween(parent, elem1, elem2);
	|}
	|
	|function selectedElems() {
	|	const res = hilightedElems();
	|
	|	if (res.length == 0) {
	|		const elem = pointedElem();
	|		if (elem) {
	|			res.push(elem);
	|		}
	|	}
	|
	|	return res;
	|}
	|";
	
	ДобавитьТегВHead(ТекстHTML, "script", Код);
	
КонецПроцедуры

Функция АдресВременногоХранилищаБезHTTP(ПолныйАдресВХ)
	
	Если СтрНайти(ПолныйАдресВХ, "http") = 0 Или ПолныйАдресВХ = """" Тогда
		Возврат ПолныйАдресВХ;
	КонецЕсли;
	
	ПутьКартинки = ПолныйАдресВХ;
	ИндексНачалаВХ = СтрНайти(ПолныйАдресВХ, "e1cib");
	Если ИндексНачалаВХ <> 0 Тогда
		ПутьКартинки = Прав(ПолныйАдресВХ, СтрДлина(ПолныйАдресВХ) - ИндексНачалаВХ + 1);
	КонецЕсли;
	
	Возврат ПутьКартинки;
	
КонецФункции

// Получает вложения письма с непустым ИД.
//
// Параметры:
//  Письмо  - ДокументСсылка.Событие,
//
// Возвращаемое значение:
//   ТаблицаЗначений   - таблица с информацией о вложениях электронного письма с непустым ИД.
//
Функция ПолучитьВложенияПисьмаСНеПустымИД(Событие) Экспорт
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	ПрисоединенныеФайлыПисьма.Ссылка,
	|	ПрисоединенныеФайлыПисьма.Наименование,
	|	ПрисоединенныеФайлыПисьма.Размер,
	|	ПрисоединенныеФайлыПисьма.ИДФайлаЭлектронногоПисьма
	|ИЗ
	|	Справочник.СобытиеПрисоединенныеФайлы КАК ПрисоединенныеФайлыПисьма
	|ГДЕ
	|	ПрисоединенныеФайлыПисьма.ВладелецФайла = &ВладелецФайлов
	|	И НЕ ПрисоединенныеФайлыПисьма.ПометкаУдаления
	|	И ПрисоединенныеФайлыПисьма.ИДФайлаЭлектронногоПисьма <> &ПустаяСтрока");
	
	Запрос.УстановитьПараметр("ПустаяСтрока","");
	Запрос.УстановитьПараметр("ВладелецФайлов", Событие);
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции 

// Заменяет в тексте HTML ИД картинок вложений на путь к файлам и создает объект документ HTML.
//
// Параметры:
//  ТекстHTML - Строка - обрабатываемый текст HTML.
//  ТаблицаВложений - ТаблицаЗначений - таблица, содержащая информацию о присоединенных файлах в колонках:
//    * Идентификатор - Строка - идентификатор картинки, используется для переопределения атрибута src в производном HTML,
//    * Представление - Строка - интерпретируется как полное имя файла, используется для определения типа файла,
//    * АдресВоВременномХранилище - Строка - адрес во временном хранилище.
//  Кодировка - Строка - кодировка текста HTML.
//
// Возвращаемое значение:
//  ДокументHTML   - созданный документ HTML.
//
Функция ЗаменитьИдентификаторыКартинокНаПутьКФайлам(ТекстHTML, ТаблицаВложений, Кодировка = Неопределено, ОбработатьКартинки = Ложь)
	
	ДокументHTML = ПолучитьОбъектДокументHTMLИзТекстаHTML(ТекстHTML, Кодировка);
	
	Для каждого ТекВложение Из ТаблицаВложений Цикл
		
		Для каждого Картинка Из ДокументHTML.Картинки Цикл
			
			АтрибутИсточникКартинки = Картинка.Атрибуты.ПолучитьИменованныйЭлемент("src");
			Если АтрибутИсточникКартинки = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			
			Если СтрЧислоВхождений(АтрибутИсточникКартинки.Значение, ТекВложение.Идентификатор) <= 0 Тогда
				Продолжить;
			КонецЕсли;
			
			Попытка
				
				ТекстовоеСодержимое = ТекВложение.АдресВоВременномХранилище;
				Если ТекстовоеСодержимое = Неопределено Тогда
					ТекстовоеСодержимое = "";
				ИначеЕсли ОбработатьКартинки Тогда
					
					ДвоичныеДанные = ПолучитьИзВременногоХранилища(ТекстовоеСодержимое);
					ТекстовоеСодержимое = СтрШаблон(
					"data:image/%1;base64,
					|%2",
					ТипКартинки(ДвоичныеДанные),
					Base64Строка(ДвоичныеДанные));
					
				КонецЕсли;
				
			Исключение
				// Если данные картинки получить не удалось, то картинку не выводим. Пользователю при этом ничего не сообщаем.
				ТекстовоеСодержимое = "";
			КонецПопытки;
			
			НовыйАтрибутКартинки = АтрибутИсточникКартинки.КлонироватьУзел(Ложь);
			НовыйАтрибутКартинки.ТекстовоеСодержимое = ТекстовоеСодержимое;
			Картинка.Атрибуты.УстановитьИменованныйЭлемент(НовыйАтрибутКартинки);
			
			Прервать;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат ДокументHTML;
	
КонецФункции

// Ищет подстроку в строке, после указанной позиции
//
Функция НайтиПосле(Строка, Подстрока, НачальнаяПозиция = 0)
	
	Если СтрДлина(Строка) <= НачальнаяПозиция Тогда
		Возврат 0;
	КонецЕсли;
	
	Позиция = СтрНайти(Строка, Подстрока, НаправлениеПоиска.СНачала, НачальнаяПозиция + 1);
	Возврат Позиция;
	
КонецФункции

Процедура ЗаменитьСпецСимволHTML(Строка, КодСимвола, ИмяСимвола)
	
	Строка = СтрЗаменить(Строка, Символ(КодСимвола), "&" + ИмяСимвола + ";");
	
КонецПроцедуры

Функция СоответствиеСпецСимволов()
	
	Результат = Новый Соответствие;
	
	Результат.Вставить(193, "Aacute");
	Результат.Вставить(225, "aacute");
	Результат.Вставить(226, "acirc");
	Результат.Вставить(194, "Acirc");
	Результат.Вставить(180, "acute");
	Результат.Вставить(230, "aelig");
	Результат.Вставить(198, "AElig");
	Результат.Вставить(192, "Agrave");
	Результат.Вставить(224, "agrave");
	Результат.Вставить(8501, "alefsym");
	Результат.Вставить(913, "Alpha");
	Результат.Вставить(945, "alpha");
	Результат.Вставить(8743, "and");
	Результат.Вставить(8736, "ang");
	Результат.Вставить(229, "aring");
	Результат.Вставить(197, "Aring");
	Результат.Вставить(8776, "asymp");
	Результат.Вставить(195, "Atilde");
	Результат.Вставить(227, "atilde");
	Результат.Вставить(196, "Auml");
	Результат.Вставить(228, "auml");
	Результат.Вставить(8222, "bdquo");
	Результат.Вставить(914, "Beta");
	Результат.Вставить(946, "beta");
	Результат.Вставить(166, "brvbar");
	Результат.Вставить(8226, "bull");
	Результат.Вставить(8745, "cap");
	Результат.Вставить(199, "Ccedil");
	Результат.Вставить(231, "ccedil");
	Результат.Вставить(184, "cedil");
	Результат.Вставить(162, "cent");
	Результат.Вставить(967, "chi");
	Результат.Вставить(935, "Chi");
	Результат.Вставить(710, "circ");
	Результат.Вставить(9827, "clubs");
	Результат.Вставить(8773, "cong");
	Результат.Вставить(169, "copy");
	Результат.Вставить(8629, "crarr");
	Результат.Вставить(8746, "cup");
	Результат.Вставить(164, "curren");
	Результат.Вставить(8224, "dagger");
	Результат.Вставить(8225, "Dagger");
	Результат.Вставить(8659, "dArr");
	Результат.Вставить(8595, "darr");
	Результат.Вставить(176, "deg");
	Результат.Вставить(916, "Delta");
	Результат.Вставить(948, "delta");
	Результат.Вставить(9830, "diams");
	Результат.Вставить(247, "divide");
	Результат.Вставить(233, "eacute");
	Результат.Вставить(201, "Eacute");
	Результат.Вставить(202, "Ecirc");
	Результат.Вставить(234, "ecirc");
	Результат.Вставить(232, "egrave");
	Результат.Вставить(200, "Egrave");
	Результат.Вставить(8709, "empty");
	Результат.Вставить(8195, "emsp");
	Результат.Вставить(8194, "ensp");
	Результат.Вставить(949, "epsilon");
	Результат.Вставить(917, "Epsilon");
	Результат.Вставить(8801, "equiv");
	Результат.Вставить(919, "Eta");
	Результат.Вставить(951, "eta");
	Результат.Вставить(240, "eth");
	Результат.Вставить(208, "ETH");
	Результат.Вставить(235, "euml");
	Результат.Вставить(203, "Euml");
	Результат.Вставить(8364, "euro");
	Результат.Вставить(8707, "exist");
	Результат.Вставить(402, "fnof");
	Результат.Вставить(8704, "forall");
	Результат.Вставить(189, "frac12");
	Результат.Вставить(188, "frac14");
	Результат.Вставить(190, "frac34");
	Результат.Вставить(8260, "frasl");
	Результат.Вставить(915, "Gamma");
	Результат.Вставить(947, "gamma");
	Результат.Вставить(8805, "ge");
	Результат.Вставить(62, "gt");
	Результат.Вставить(8660, "hArr");
	Результат.Вставить(8596, "harr");
	Результат.Вставить(9829, "hearts");
	Результат.Вставить(8230, "hellip");
	Результат.Вставить(237, "iacute");
	Результат.Вставить(205, "Iacute");
	Результат.Вставить(238, "icirc");
	Результат.Вставить(206, "Icirc");
	Результат.Вставить(161, "iexcl");
	Результат.Вставить(204, "Igrave");
	Результат.Вставить(236, "igrave");
	Результат.Вставить(8465, "image");
	Результат.Вставить(8734, "infin");
	Результат.Вставить(8747, "int");
	Результат.Вставить(921, "Iota");
	Результат.Вставить(953, "iota");
	Результат.Вставить(191, "iquest");
	Результат.Вставить(8712, "isin");
	Результат.Вставить(207, "Iuml");
	Результат.Вставить(239, "iuml");
	Результат.Вставить(922, "Kappa");
	Результат.Вставить(954, "kappa");
	Результат.Вставить(955, "lambda");
	Результат.Вставить(923, "Lambda");
	Результат.Вставить(9001, "lang");
	Результат.Вставить(171, "laquo");
	Результат.Вставить(8592, "larr");
	Результат.Вставить(8656, "lArr");
	Результат.Вставить(8968, "lceil");
	Результат.Вставить(8220, "ldquo");
	Результат.Вставить(8804, "le");
	Результат.Вставить(8970, "lfloor");
	Результат.Вставить(8727, "lowast");
	Результат.Вставить(9674, "loz");
	Результат.Вставить(8206, "lrm");
	Результат.Вставить(8249, "lsaquo");
	Результат.Вставить(8216, "lsquo");
	Результат.Вставить(60, "lt");
	Результат.Вставить(175, "macr");
	Результат.Вставить(8212, "mdash");
	Результат.Вставить(181, "micro");
	Результат.Вставить(183, "middot");
	Результат.Вставить(8722, "minus");
	Результат.Вставить(924, "Mu");
	Результат.Вставить(956, "mu");
	Результат.Вставить(8711, "nabla");
	Результат.Вставить(160, "nbsp");
	Результат.Вставить(8211, "ndash");
	Результат.Вставить(8800, "ne");
	Результат.Вставить(8715, "ni");
	Результат.Вставить(172, "not");
	Результат.Вставить(8713, "notin");
	Результат.Вставить(8836, "nsub");
	Результат.Вставить(241, "ntilde");
	Результат.Вставить(209, "Ntilde");
	Результат.Вставить(925, "Nu");
	Результат.Вставить(957, "nu");
	Результат.Вставить(243, "oacute");
	Результат.Вставить(211, "Oacute");
	Результат.Вставить(212, "Ocirc");
	Результат.Вставить(244, "ocirc");
	Результат.Вставить(338, "OElig");
	Результат.Вставить(339, "oelig");
	Результат.Вставить(242, "ograve");
	Результат.Вставить(210, "Ograve");
	Результат.Вставить(8254, "oline");
	Результат.Вставить(969, "omega");
	Результат.Вставить(937, "Omega");
	Результат.Вставить(927, "Omicron");
	Результат.Вставить(959, "omicron");
	Результат.Вставить(8853, "oplus");
	Результат.Вставить(8744, "or");
	Результат.Вставить(170, "ordf");
	Результат.Вставить(186, "ordm");
	Результат.Вставить(216, "Oslash");
	Результат.Вставить(248, "oslash");
	Результат.Вставить(213, "Otilde");
	Результат.Вставить(245, "otilde");
	Результат.Вставить(8855, "otimes");
	Результат.Вставить(214, "Ouml");
	Результат.Вставить(246, "ouml");
	Результат.Вставить(182, "para");
	Результат.Вставить(8706, "part");
	Результат.Вставить(8240, "permil");
	Результат.Вставить(8869, "perp");
	Результат.Вставить(966, "phi");
	Результат.Вставить(934, "Phi");
	Результат.Вставить(928, "Pi");
	Результат.Вставить(960, "pi");
	Результат.Вставить(982, "piv");
	Результат.Вставить(177, "plusmn");
	Результат.Вставить(163, "pound");
	Результат.Вставить(8243, "Prime");
	Результат.Вставить(8242, "prime");
	Результат.Вставить(8719, "prod");
	Результат.Вставить(8733, "prop");
	Результат.Вставить(968, "psi");
	Результат.Вставить(936, "Psi");
	Результат.Вставить(34, "quot");
	Результат.Вставить(8730, "radic");
	Результат.Вставить(9002, "rang");
	Результат.Вставить(187, "raquo");
	Результат.Вставить(8658, "rArr");
	Результат.Вставить(8594, "rarr");
	Результат.Вставить(8969, "rceil");
	Результат.Вставить(8221, "rdquo");
	Результат.Вставить(8476, "real");
	Результат.Вставить(174, "reg");
	Результат.Вставить(8971, "rfloor");
	Результат.Вставить(929, "Rho");
	Результат.Вставить(961, "rho");
	Результат.Вставить(8207, "rlm");
	Результат.Вставить(8250, "rsaquo");
	Результат.Вставить(8217, "rsquo");
	Результат.Вставить(8218, "sbquo");
	Результат.Вставить(352, "Scaron");
	Результат.Вставить(353, "scaron");
	Результат.Вставить(8901, "sdot");
	Результат.Вставить(167, "sect");
	Результат.Вставить(173, "shy");
	Результат.Вставить(931, "Sigma");
	Результат.Вставить(963, "sigma");
	Результат.Вставить(962, "sigmaf");
	Результат.Вставить(8764, "sim");
	Результат.Вставить(9824, "spades");
	Результат.Вставить(8834, "sub");
	Результат.Вставить(8838, "sube");
	Результат.Вставить(8721, "sum");
	Результат.Вставить(8835, "sup");
	Результат.Вставить(185, "sup1");
	Результат.Вставить(178, "sup2");
	Результат.Вставить(179, "sup3");
	Результат.Вставить(8839, "supe");
	Результат.Вставить(223, "szlig");
	Результат.Вставить(932, "Tau");
	Результат.Вставить(964, "tau");
	Результат.Вставить(8756, "there4");
	Результат.Вставить(920, "Theta");
	Результат.Вставить(952, "theta");
	Результат.Вставить(977, "thetasym");
	Результат.Вставить(8201, "thinsp");
	Результат.Вставить(222, "THORN");
	Результат.Вставить(254, "thorn");
	Результат.Вставить(732, "tilde");
	Результат.Вставить(215, "times");
	Результат.Вставить(8482, "trade");
	Результат.Вставить(250, "uacute");
	Результат.Вставить(218, "Uacute");
	Результат.Вставить(8657, "uArr");
	Результат.Вставить(8593, "uarr");
	Результат.Вставить(251, "ucirc");
	Результат.Вставить(219, "Ucirc");
	Результат.Вставить(217, "Ugrave");
	Результат.Вставить(249, "ugrave");
	Результат.Вставить(168, "uml");
	Результат.Вставить(978, "upsih");
	Результат.Вставить(965, "upsilon");
	Результат.Вставить(933, "Upsilon");
	Результат.Вставить(252, "uuml");
	Результат.Вставить(220, "Uuml");
	Результат.Вставить(8472, "weierp");
	Результат.Вставить(958, "xi");
	Результат.Вставить(926, "Xi");
	Результат.Вставить(253, "yacute");
	Результат.Вставить(221, "Yacute");
	Результат.Вставить(165, "yen");
	Результат.Вставить(255, "yuml");
	Результат.Вставить(376, "Yuml");
	Результат.Вставить(918, "Zeta");
	Результат.Вставить(950, "zeta");
	Результат.Вставить(8205, "zwj");
	Результат.Вставить(8204, "zwnj");
	
	Возврат Результат;
	
КонецФункции

Процедура УдалитьТегиИзЭлементаHTML(ЭлементHTML, Тег)
	
	УдалитьТегиИзЭлементаHTMLРекурсия(ЭлементHTML, Тег);
	
КонецПроцедуры

Процедура УдалитьТегиИзЭлементаHTMLРекурсия(ЭлементHTML, Тег, Знач Счетчик = 0)
	
	Счетчик = Счетчик + 1;
	Если Счетчик > 100 Тогда
		Возврат;
	КонецЕсли;
	
	Для каждого Узел Из ЭлементHTML.ДочерниеУзлы Цикл
		Если НРег(Узел.ИмяУзла) = НРег(Тег) Тогда
			ЭлементHTML.УдалитьДочерний(Узел);
		Иначе
			УдалитьТегиИзЭлементаHTMLРекурсия(Узел, Тег, Счетчик);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Функция ТипКартинки(ДвоичныеДанные)
	
	Картинка = Новый Картинка(ДвоичныеДанные);
	Возврат НРег(Картинка.Формат());
	
КонецФункции

#КонецОбласти
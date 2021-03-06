﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если ПустаяСтрока(Параметры.АдресВоВременномХранилище) Тогда
		Сообщить("Не передан адрес файла во временном хранилище!");
		Отказ	= Истина;
	ИначеЕсли ПустаяСтрока(Параметры.ИмяФайла) Тогда
		Сообщить("Не передано имя файла!");
		Отказ	= Истина;
	ИначеЕсли ПустаяСтрока(Параметры.Путь) Тогда
		Сообщить("Не передан путь!");
		Отказ	= Истина;		
	КонецЕсли;
	АдресВоВременномХранилище	= Параметры.АдресВоВременномХранилище;
	ИмяФайла					= Параметры.ИмяФайла;
	Путь						= Параметры.Путь;
	
	Если СтрНачинаетсяС(Путь, "/") Тогда
		Путь	= Сред(Путь, 2);
	КонецЕсли;
	Если СтрЗаканчиваетсяНа(Путь, "/") Тогда
		Путь	= Сред(Путь, 1, СтрДлина(Путь)-1);	
	КонецЕсли;
	
	// Пробуем получить ключ доступа по ключу обновления
	МодульОбъекта	= РеквизитФормыВЗначение("Объект");
	access_token	= МодульОбъекта.ПолучитьAccessToken();
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если ПустаяСтрока(access_token) Тогда
		ПолучитьAccessToken();
	Иначе
		ЭтаФорма.Закрыть(ОтправитьФайл());
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьAccessToken() 
	ДополнительныеПараметры	= Новый Структура();
	ОООЗ					= Новый ОписаниеОповещения("ПослеЗакрытияАвторизации", ЭтаФорма, ДополнительныеПараметры);
	ОткрытьФорму("Обработка.OneDrive.Форма.Авторизация",, ЭтаФорма,,,, ОООЗ);
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗакрытияАвторизации(ПараметрыЗакрытия, ДополнительныеПараметры) Экспорт
	Если ПараметрыЗакрытия = Неопределено Тогда
		Сообщить("Авторизация не пройдена.");
		ЭтаФорма.Закрыть();
		Возврат;
	ИначеЕсли ТипЗнч(ПараметрыЗакрытия) = Тип("Строка") И Не ПустаяСтрока(ПараметрыЗакрытия) Тогда
		access_token	= ПараметрыЗакрытия;
		ЭтаФорма.Закрыть(ОтправитьФайл());
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ОтправитьФайл()
	Соединение = Новый HTTPСоединение("graph.microsoft.com", 443,,,, 100, Новый ЗащищенноеСоединениеOpenSSL);
	Заголовки = Новый Соответствие;
	Заголовки["Authorization"] = "bearer " + access_token;
	Запрос = Новый HTTPЗапрос("/v1.0/me/drive/root:/"+Путь+"/"+ИмяФайла+":/content", Заголовки);
	Запрос.УстановитьТелоИзДвоичныхДанных(ПолучитьИзВременногоХранилища(АдресВоВременномХранилище)); 
	Результат	= Соединение.Записать(Запрос);
	Если Результат.КодСостояния < 300 Тогда
		Сообщить("Успешно.");
		Возврат Истина;
	Иначе 
		Сообщить("Не удачно.");
		Возврат Ложь;
	КонецЕсли;
КонецФункции
﻿
Процедура ЗапомнитьRefreshToken(Пользователь, RefreshToken) Экспорт
	ПВХ	= ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоНаименованию("OneDrive.RefreshToken", Истина);
	Если ПВХ.Пустая() Тогда
		ОбъектПВХ				= ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.СоздатьЭлемент();
		ОбъектПВХ.Наименование	= "OneDrive.RefreshToken";
		ОбъектПВХ.Виден			= Ложь;
		ОбъектПВХ.Записать();
		ПВХ						= ОбъектПВХ.Ссылка;
	КонецЕсли;
	Токен			= РегистрыСведений.ДополнительныеСведения.СоздатьМенеджерЗаписи();
	Токен.Свойство	= ПВХ;
	Токен.Объект	= Пользователь;
	Токен.Значение	= RefreshToken;
	Токен.Записать(Истина);	
КонецПроцедуры

Функция ПолучитьRefreshToken()
	RefreshToken	= "";
	Запрос			= Новый Запрос("ВЫБРАТЬ ПЕРВЫЕ 1 Значение ИЗ РегистрСведений.ДополнительныеСведения 
	|ГДЕ Объект = &ТекущийПользователь И Свойство В(
	|ВЫБРАТЬ Ссылка ИЗ ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения 
	|ГДЕ Наименование = ""OneDrive.RefreshToken"") ");
	Запрос.УстановитьПараметр("ТекущийПользователь", ПараметрыСеанса.ТекущийПользователь);
	Выборка			= Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		RefreshToken	= Выборка.Значение;		
	КонецЦикла;
	Возврат RefreshToken; 
КонецФункции

Функция ПолучитьAccessToken() Экспорт
	AccessToken		= "";
	RefreshToken	= ПолучитьRefreshToken();
	Если ПустаяСтрока(RefreshToken) Тогда
		Возврат "";
	КонецЕсли;
	
	Параметры		= СтрШаблон("client_id=%1&scope=%2&refresh_token=%3&redirect_uri=%4&grant_type=%5&client_secret=%6"
		, "client_id"
		, КодироватьСтроку("user.read files.readwrite files.readwrite.all offline_access", СпособКодированияСтроки.КодировкаURL)
		, RefreshToken
		, "https://site.ru:443/base/hs/api/oauth2callback/"
		, "refresh_token"
		, "client_secret"
	);
	Соединение		= Новый HTTPСоединение("login.microsoftonline.com", 443,,,, 100, Новый ЗащищенноеСоединениеOpenSSL);
	Заголовки		= Новый Соответствие;
	Заголовки["Content-Type"]	= "application/x-www-form-urlencoded";
	Запрос			= Новый HTTPЗапрос("/common/oauth2/v2.0/token", Заголовки);
	Запрос.УстановитьТелоИзСтроки(Параметры); 
	HTTPОтвет		= Соединение.ОтправитьДляОбработки(Запрос);
	Если HTTPОтвет.КодСостояния = 200 Тогда
		ДанныеJSON		= HTTPОтвет.ПолучитьТелоКакСтроку();
		Данные			= Сериализация.ДесериализоватьJSON(ДанныеJSON);
		ЗапомнитьRefreshToken(ПараметрыСеанса.ТекущийПользователь, Данные.refresh_token);
		Возврат Данные.access_token;
	Иначе
		Возврат "";		
	КонецЕсли;
КонецФункции


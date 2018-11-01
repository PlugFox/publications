```
#Область OAuth2
Функция OAuth2CallbackGET(Запрос)
	// https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow
	УстановитьПривилегированныйРежим(Истина);
	Попытка
		Если СтрНайти(Запрос.Заголовки["Referer"], "login.microsoftonline.com") Тогда 
			Возврат OneDrive(Запрос)	
		Иначе
			ВызватьИсключение "Откуда происходит аутентификация?";
		КонецЕсли;	
	Исключение
		Ошибка		= ОписаниеОшибки();
		Ответ		= Новый HTTPСервисОтвет(501);		
		Ответ.Заголовки.Вставить("Content-Type","text/html; charset=utf-8");	
		Ответ.УстановитьТелоИзСтроки(Ошибка);
		Возврат Ответ;
	КонецПопытки;
КонецФункции

Функция OneDrive(Знач Запрос)
	Пользователь	= Справочники.Пользователи.НайтиПоРеквизиту("ИдентификаторПользователяИБ", Новый УникальныйИдентификатор(Запрос.ПараметрыЗапроса["state"]));
	Если Пользователь.Пустая() Тогда
		ВызватьИсключение "Пользователь не найден.";
	КонецЕсли;
	Параметры		= СтрШаблон("client_id=%1&scope=%2&code=%3&redirect_uri=%4&grant_type=%5&client_secret=%6"
		, "client id"
		, КодироватьСтроку("user.read files.readwrite files.readwrite.all offline_access", СпособКодированияСтроки.КодировкаURL)
		, Запрос.ПараметрыЗапроса["code"]
		, "https://site.ru:443/base/hs/api/oauth2callback/"
		, "authorization_code"
		, "client_secret"
	);
	Соединение		= Новый HTTPСоединение("login.microsoftonline.com", 443,,,, 100, Новый ЗащищенноеСоединениеOpenSSL);
	Заголовки		= Новый Соответствие;
	Заголовки["Content-Type"]	= "application/x-www-form-urlencoded";
	Запрос			= Новый HTTPЗапрос("/common/oauth2/v2.0/token", Заголовки);
	Запрос.УстановитьТелоИзСтроки(Параметры); 
	HTTPОтвет		= Соединение.ОтправитьДляОбработки(Запрос);
	ДанныеJSON		= HTTPОтвет.ПолучитьТелоКакСтроку();
	Данные			= Сериализация.ДесериализоватьJSON(ДанныеJSON);
	
	OneDrive		= Обработки.OneDrive.Создать();
	OneDrive.ЗапомнитьRefreshToken(Пользователь, Данные.refresh_token);
	access_token	= Данные.access_token;	
	
	Ответ	= Новый HTTPСервисОтвет(200);		
	Ответ.Заголовки.Вставить("Content-Type","text/html; charset=utf-8");
	Ответ.УстановитьТелоИзСтроки("access_token="+access_token);
	
	Возврат Ответ;
КонецФункции

#КонецОбласти
```
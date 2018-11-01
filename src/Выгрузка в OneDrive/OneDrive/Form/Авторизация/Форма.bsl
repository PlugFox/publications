&НаСервере
Функция ПолучитьДанныеПодключения()
	// https://apps.dev.microsoft.com/#/appList
	// https://docs.microsoft.com/ru-ru/azure/active-directory/develop/v2-oauth2-auth-code-flow
	appInfo			= Новый Структура("clientId,redirectUri,scopes,authServiceUri,msGraphApiRoot,state"
    , "clientId"
    , "https://site.ru:443/base/hs/api/oauth2callback/"
    , "user.read files.readwrite files.readwrite.all offline_access"
    , "https://login.microsoftonline.com/common/oauth2/v2.0/authorize"
	, "https://graph.microsoft.com/v1.0/me"
	, ПараметрыСеанса.ТекущийПользователь.ИдентификаторПользователяИБ);
	
	// Для implicit аутентификации: response_type=token
	url	= СтрШаблон("%1?client_id=%2&response_type=code&redirect_uri=%3&response_mode=query&scope=%4&state=%5"
    , appInfo.authServiceUri
    , appInfo.clientId
    , КодироватьСтроку(appInfo.redirectUri, СпособКодированияСтроки.КодировкаURL)
	, КодироватьСтроку(appInfo.scopes, СпособКодированияСтроки.КодировкаURL)	
	, Строка(appInfo.state)
	);
	appInfo.Вставить("OAuth2Adress", url);
	
	Возврат appInfo;
КонецФункции

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ДанныеПодключения	= ПолучитьДанныеПодключения();
	Элементы.HTML.Документ.location.href	= ДанныеПодключения.OAuth2Adress;
КонецПроцедуры

&НаКлиенте
Процедура HTMLДокументСформирован(Элемент)
	Если СтрНайти(Элемент.Документ.body.innerText, "access_token=") Тогда
		ЭтаФорма.Закрыть(СтроковыеФункцииКлиентСервер.ПолучитьПараметрыИзСтроки(Элемент.Документ.body.innerText).access_token);
	КонецЕсли;
КонецПроцедуры

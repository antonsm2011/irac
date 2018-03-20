﻿///////////////////////////////////////////////////////////////////////////////////
// УПРАВЛЕНИЕ ЗАПУСКОМ КОМАНД 1С:Предприятия 8
//

#Использовать logos
#Использовать tempfiles
#Использовать asserts
#Использовать strings
#Использовать 1commands
#Использовать v8runner
#Использовать "."

Перем Лог;

//////////////////////////////////////////////////////////////////////////////////
// Программный интерфейс

Процедура ОписаниеСерверов(Серверы)
	
	Сообщить("Всего серверов: " + Серверы.ПолучитьСписок().Количество());
	Для Каждого ТекОписание Из Серверы.ПолучитьСписок() Цикл
		Сервер = ТекОписание.Значение;
		Сообщить(Сервер.Имя() + " (" + Сервер.Сервер() + ":" + Сервер.Порт() + ")");
		Для Каждого ТекАтрибут Из Сервер.Параметры() Цикл
			Сообщить(ТекАтрибут.Ключ + " : " + ТекАтрибут.Значение);
		КонецЦикла;
		Сообщить("");
	КонецЦикла;
				
КонецПроцедуры

Процедура ОписаниеИБ(ИБ)
	
	Сообщить("Всего ИБ: " + ИБ.ПолучитьСписок().Количество());
	Для Каждого ТекОписание Из ИБ.ПолучитьСписок() Цикл
		ТекИБ = ТекОписание.Значение;
		Сообщить(ТекИБ.Имя() + " (" + ?(ТекИБ.ПолноеОписание(), "Полное", "Сокращенное") + " " + ТекИБ.Описание() + ")");
		Для Каждого ТекАтрибут Из ТекИБ.Параметры() Цикл
			Сообщить(ТекАтрибут.Ключ + " : " + ТекАтрибут.Значение);
		КонецЦикла;
		Сообщить("");
	КонецЦикла;
				
КонецПроцедуры

Функция ПолучитьСписокБаз(НомерКластера = 0) Экспорт
	
	Агент = Новый АгентКластера("localhost", 1545, "8.3");
	Сообщить(Агент.ОписаниеПодключения());

	Кластеры = Агент.Кластеры();

	МассивРезультатов = Новый Массив();

	Для Каждого ТекЭлемент Из Кластеры.ПолучитьСписок() Цикл

		Сообщить(СтрШаблон("Кластер: %1", ТекЭлемент.Ключ));
		Для Каждого ТекПоле Из ТекЭлемент.Значение.Параметры() Цикл
			Сообщить(СтрШаблон("%1 : %2", ТекПоле.Ключ, ТекПоле.Значение));
		КонецЦикла;

		ОписаниеСерверов(ТекЭлемент.Значение.Серверы());
		ОписаниеИБ(ТекЭлемент.Значение.ИнформационныеБазы());

		Параметры = Новый Массив();
		Параметры.Добавить(Агент.СтрокаПодключения());

		Параметры.Добавить("infobase");
		Параметры.Добавить(СтрШаблон("--cluster=%1", ТекЭлемент.Значение.Ид()));
		Параметры.Добавить("summary");
		Параметры.Добавить("list");
		
		Служебный.ВыполнитьКоманду(Параметры);

		ВремМассивРезультатов = Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды());

		Для Каждого ТекОписание Из ВремМассивРезультатов Цикл
			
			Для Каждого ТекАтрибут Из ТекОписание Цикл
				//Сообщить(ТекАтрибут.Ключ + " : " + ТекАтрибут.Значение);
			КонецЦикла;
			МассивРезультатов.Добавить(ТекОписание);
		КонецЦикла;

		//Лог.Информация(Служебный.ВыводКоманды());
	КонецЦикла;

	Возврат МассивРезультатов;

КонецФункции
	
//////////////////////////////////////////////////////////////////////////////////
// Служебные процедуры

//////////////////////////////////////////////////////////////////////////////////////
// Инициализация

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");

ПолучитьСписокБаз();
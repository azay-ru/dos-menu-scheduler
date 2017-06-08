# DOS-Меню-Планировщик

Программа представляет из себя простое меню, с возможностью выбора указанных пунктов по расписанию или наличию файлов.

## Предыстория

Данная разработка является эхом эпохи процветания MS-DOS, соответственно работает только в среде MS-DOS.
Выложена в открытый доступ "просто так", as is. 

## Основные возможности

Программа представляет простое меню в стиле Norton Commander, с возможность автоматического выбора какого-либо пункта.
Программа ожидает действие пользователя в течении 1 минуты, если за это время не было нажатий клавиш, меню переходит в режим ScreenSaver. В этом режиме могут запускаться автоматические операции: по расписанию, или появлению файлов.

При выборе пункта меню (автоматически или по нажатию) программа закрывается и передает в DOS код завершения, который является номером выбранного пункта. Если нажата Esc - код завершения 0.
Код необходимо проверять в вызываемом .bat файле с помощью ERRORLEVEL

### Параметры запуска

```
mschedul.exe <имя файла конфигурации> <Номера рабочих дней 0..6>
```

### Пример файла конфигурации

Конфигурация состоит из 3-х частей, разделяемых строкой с первым символом "#".
В первой части перечисляются пункты меню.
Во второй части перечисляются порядковые номера пунктов, через запятую маска файла, при которой будет автоматически выбран пункт меню.
В третьей части перечислются временные точки автоматического запуска, через запятую порядковый номер меню.

```
First item
Second item
Third item
Fourth item
#
4,c:\*.111
3,c:\*.222
#
10:00,1
11:00,2
12:00,3
15:00,4
```

### Пример запуска

Пример .bat файла для вызова и обработки меню

```
@echo off 
:again
mschedul.exe mschedul.cfg 0123456
if errorlevel 4 goto A4
if errorlevel 3 goto A3
if errorlevel 2 goto A2
if errorlevel 1 goto A1
if errorlevel 0 goto END
goto again

:A4
echo Обработан пункт меню N4
goto again

:A3
echo Обработан пункт меню N3
goto again

:A2
echo Обработан пункт меню N2
goto again

:A1
echo Обработан пункт меню N1
goto again
:END
```

## License

This project is licensed under the GPL License - see the [LICENSE] file for details
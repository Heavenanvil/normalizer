:: «normalizer»
:: 
:: © Heavenanvil
:: E-mail: heavenanvil@gmail.com
:: version 1.1
::
:: данный скрипт при помощи консольного приложения ffmpeg позволяет
:: из mkv-видеофайла вытащить звуковую дорожку ac3, 
:: если она в формате 5.1, то конвертирует её в стерео (2.0),
:: нормализует звук (уменьшение пиков громких звуков и увеличения общей громкости, дважды)
:: и упаковывает в новый mkv файл, удаляя все лишние звуковые дорожки и субтитры.
:: 
:: Ссылка на актуальный ffmpeg.exe
:: https://ffmpeg.zeranoe.com/builds/

:: Объявляем переменные
set file=myfavoritefilm
set format=mkv
set aformat=ac3

:: Шаг 1 - Извлекаем отдельно видео дорожку
:: ffmpeg -i "%file%.%format%" -y -an -vcodec copy "%file%+.%format%"
ffmpeg -i "%file%.%format%" -map 0:v -c copy "%file%+.%format%"

:: Шаг 2 - Извлекаем первую аудиодорожку
:: ffmpeg -i "%file%.%format%" -y -c:a copy "%file%.%aformat%"
ffmpeg -i "%file%.%format%" -map 0:a -c copy %file%.%aformat%"

:: Шаг 3 - %aformat% 5.1 кодируем в стерео (2.0)
ffmpeg -i "%file%.%aformat%" -y -c:a %aformat% -ac 2 "%file%+.%aformat%"

:: Шаг 4 - Применяем Limiter -6dB
ffmpeg -i "%file%+.%aformat%" -y -filter_complex alimiter=level_in=1:level_out=1:limit=-6dB:attack=7:release=100:level=disabled "%file%++.%aformat%"

:: Шаг 5 - Добавляем громкости на 7dB
ffmpeg -i "%file%++.%aformat%" -y -filter:a "volume=7dB" "%file%+++.%aformat%"

:: Шаг 6 - Применяем Limiter -8dB
 ffmpeg -i "%file%+++.%aformat%" -y -filter_complex alimiter=level_in=1:level_out=1:limit=-8dB:attack=7:release=100:level=disabled "%file%++++.%aformat%"

:: Шаг 7 - Добавляем громоксти на 4dB
ffmpeg -i "%file%++++.%aformat%" -y -filter:a "volume=4dB" "%file%+++++.%aformat%"

:: Шаг 8 - Собираем контейнер обратно
ffmpeg -i "%file%+.%format%" -i "%file%+++++.%aformat%" -c:v copy -c:a copy -map 0:v:0 -map 1:a:0 "%file%_norm.%format%"

:: Шаг 9 - Удаляем лишние файлы
del "%file%+.%format%" -y
del "%file%.%aformat%" -y
del "%file%+.%aformat%" -y
del "%file%++.%aformat%" -y
del "%file%+++.%aformat%" -y
del "%file%++++.%aformat%" -y
del "%file%+++++.%aformat%" -y

pause
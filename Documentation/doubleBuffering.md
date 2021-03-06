| Содержание |
| ----- |
| [О библиотеке](#О-библиотеке) |
| [Установка](#Установка) |
| [Методы библиотеки](#Методы-библиотеки) |
| [    buffer.getResolution](#buffergetresolution-int-width-int-height) |
| [    buffer.setResolution](#buffersetresolution-width-height-) |
| [    buffer.bindScreen](#bufferbindscreen-address-) |
| [    buffer.bindGPU](#bufferbindgpu-address-) |
| [Методы отрисовки](#Методы-отрисовки) |
| [    buffer.draw](#bufferdraw-force-) |
| [    buffer.setDrawLimit](#buffersetdrawlimit-x1-y1-x2-y2-) |
| [    buffer.getDrawLimit](#buffergetdrawlimit--int-x1-int-y1-int-x2-int-y2) |
| [    buffer.copy](#buffercopy-x-y-width-height--table-pixeldata) |
| [    buffer.paste](#bufferpaste-x-y-pixeldata-) |
| [    buffer.set](#bufferpaste-x-y-pixeldata-) |
| [    buffer.get](#bufferpaste-x-y-pixeldata-) |
| [    buffer.square](#buffersquare-x-y-width-height-background-foreground-symbol-transparency-) |
| [    buffer.clear](#bufferclear-color-transparency-) |
| [    buffer.text](#buffertext-x-y-color-text-transparency-) |
| [    buffer.formattedText](#bufferformattedtext-x-y-text-) |
| [    buffer.image](#bufferimage-x-y-picture-) |
| [Методы полупиксельной отрисовки:](#Методы-полупиксельной-отрисовки) |
| [    buffer.semiPixelSet](#buffersemipixelset-x-y-color-) |
| [    buffer.semiPixelSquare](#buffersemipixelsquare-x-y-width-height-color-) |
| [    buffer.semiPixelLine](#buffersemipixelline-x1-y1-x2-y2-color-) |
| [    buffer.semiPixelCircle](#buffersemipixelcircle-xcenter-ycenter-radius-color-) |
| [    buffer.semiPixelBezierCurve](#buffersemipixelbeziercurve-points-color-precision-) |
| [Вспомогательные методы:](#Вспомогательные-методы) |
| [    buffer.flush](#bufferflush-width-height-) |
| [    buffer.getIndexByCoordinates](#buffergetindexbycoordinates-x-y--int-index) |
| [    buffer.getCoordinatesByIndex](#buffergetcoordinatesbyindex-index--int-x-int-y) |
| [    buffer.rawSet](#bufferrawset-index-background-foreground-symbol-) |
| [    buffer.rawGet](#bufferrawget-index--int-background-int-foreground-char-symbol) |
| [Практический пример #1](#Практический-пример-1) |


О библиотеке
======
DoubleBuffering - низкоуровневая библиотека для эффективного использования ресурсов GPU и отрисовки содержимого экрана с предельно возможной скоростью. К примеру, с ее помощью реализован наш игровой движок с динамическим освещением сцен, а также небольшая игра на алгоритме рейкастинга, выдающие более чем достойные значения FPS:

![Imgur](http://i.imgur.com/YgL9fCo.png?1)

![Imgur](http://i.imgur.com/yHEwiNo.png?1)

Сама суть библиотеки очень проста: в оперативной памяти хранится два массива, содержащих информацию о пикселях на экране. Первый хранит то, что отображено в данный момент, а второй - то, что пользователь желает отрисовать. После осуществления всех операций отрисовки пользователь вызывает метод buffer.**draw**(),  затем система автоматически определяет изменившиеся пиксели, группирует их в промежуточный буфер, чтобы число GPU-операций было минимальным, а затем выводит изменения на экран.

По сравнению с стандартной отрисовкой время отображения сокращается в сотни и тысячи раз. На рисунке ниже наглядно показана эффективность библиотеки:

![meow](http://i60.fastpic.ru/big/2015/1026/8a/4c72bfcbe8fbee5993bfd7a058a5f88a.png)

Цена таких космических скоростей - повышенный расход оперативной памяти. Чтобы предельно уменьшить его, мы используем одномерную структуру экранных массивов вместо трехмерной:

![Imgur](http://i.imgur.com/2Pkne53.png)

Для получения данных о пикселях используются специальные методы, преобразующие экранные координаты в индексы экранного буфера и наоборот, подробнее об этом написано ниже в разделе "**Вспомогательные методы**".

Кроме того, библиотека не обращается ни к одной lua-таблице напрямую, заменяя их на переменные-аналоги и избегая при этом расчетов данных хеш-таблиц: к примеру, каждый метод GPU экранирован, и вместо gpu.setBackground используется GPUSetBackground(). При грамотной реализации такой подход колоссально увеличивает производительность, не нагружая при этом Lua GC.

Установка
======

| Библиотека | Функционал |
| ------ | ------ |
| *[advancedLua](https://github.com/IgorTimofeev/OpenComputers/blob/master/lib/advancedLua.lua)* | Дополнение стандартных библиотек Lua множеством функций: быстрой сериализацией таблиц, переносом строк, методами обработки бинарных данных и т.д. |
| *[color](https://github.com/IgorTimofeev/OpenComputers/blob/master/lib/color.lua)* | Экструзия цветовых каналов, альфа-блендинг, поддержка различных палитр и конвертации цвета в 8-битный формат |
| *[image](https://github.com/IgorTimofeev/OpenComputers/blob/master/lib/image.lua)* | Реализация стандарта изображений для OpenComputers и базовые методы их обработки: транспонирование, обрезка, поворот, отражение и т.д. |
| *[OCIF](https://github.com/IgorTimofeev/OpenComputers/blob/master/lib/FormatModules/OCIF.lua)* | Модуль формата изображения OCIF (OpenComputers Image Format) для библиотеки image, написанный с учетом особенностей мода и реализующий эффективное сжатие пиксельных данных |
| *[doubleBuffering](https://github.com/IgorTimofeev/OpenComputers/blob/master/lib/doubleBuffering.lua)* | Данная библиотека |

Вы можете использовать имеющиеся выше ссылки для установки зависимостей вручную или запустить автоматический [установщик](https://pastebin.com/vTM8nbSZ), загружающий все необходимые файлы за вас:

    pastebin run vTM8nbSZ

Основные методы
======

buffer.**getResolution**(): *int* width, *int* height
-----------------------------------------------------------
Получить разрешение экранного буфера. Для удобства также имеются методы buffer.**getWidth**() и buffer.**getHeight**().

buffer.**setResolution**( width, height )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | width | Ширина буфера |
| *int* | height | Высота буфера |

Установить разрешение экранного буфера и GPU равным указанному. Содержимое буфера при этом будет заполнено черными пикселями с символом пробела.

buffer.**bindScreen**( address )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *string* | address | Адрес компонента экрана |

Связать используемую буфером видеокарту с указанным адресом компонента экрана.  Содержимое буфера при этом будет очищено черными пикселями с символом пробела.

buffer.**bindGPU**( address )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *string* | address | Адрес компонента видеокарты |

Изменить используемую буфером видеокарту на указанную. Содержимое буфера при этом будет очищено черными пикселями с символом пробела.

buffer.**getGPUProxy**( ): *table* GPUProxy
-----------------------------------------------------------
Получить указатель на proxy используемого буфером компонента видеокарты.

Методы отрисовки
======

buffer.**draw**( [force] )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| [*boolean* | force] | Принудительная отрисовка |

Отрисовать содержимое буфера на экран. Если имеется опциональный аргумент *force*, то содержимое буфера будет отрисовано полностью и вне зависимости от изменившихся пикселей.

buffer.**setDrawLimit**( x1, y1, x2, y2 )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | x1 | Координата первой точки лимита отрисовки по оси x |
| *int* | y1 | Координата первой точки лимита отрисовки по оси y |
| *int* | x2 | Координата второй точки лимита отрисовки по оси x |
| *int* | y2 | Координата второй точки лимита отрисовки по оси y |

Установить лимит отрисовки буфера до указанного. При этом любые операции, выходящие за границы лимита, будут игнорироваться. По умолчанию буфер всегда имеет лимит отрисовки в диапазонах **x ∈ [1; buffer.width]** и **y ∈ [1; buffer.height]** 

buffer.**getDrawLimit**( ): *int* x1, *int* y1, *int* x2, *int* y2
-----------------------------------------------------------
Получить текущий лимит отрисовки.

buffer.**copy**( x, y, width, height ): *table* pixelData
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | x | Координата копируемой области по оси x |
| *int* | y | Координата копируемой области по оси y |
| *int* | width | Ширина копируемой области |
| *int* | height | Высота копируемой области |

Скопировать содержимое указанной области из буфера и выдать в виде таблицы. Впоследствии можно использовать с buffer.**paste**(...).

buffer.**paste**( x, y, pixelData )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | x | Координата вставки по оси x |
| *int* | y | Координата вставки по оси y |
| *table* | pixelData | Таблица со скопированной ранее областью буфера |

Вставить скопированное содержимое буфера по указанным координатам.

buffer.**set**( x, y, background, foreground, symbol )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | x | Координата по оси x |
| *int* | y | Координата по оси y |
| *int* | background | Цвет фона |
| *int* | foreground | Цвет символа |
| *char* | symbol | Символ |

Установить значение конкретного пикселя на экране. Полезно для мелкого и точного редактирования.

buffer.**get**( x, y ): *int* background, *int* foreground, *char* symbol
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | x | Координата по оси x |
| *int* | y | Координата по оси y |

Получить значение конкретного пикселя на экране.

buffer.**square**( x, y, width, height, background, foreground, symbol, transparency )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | x | Координата прямоугольника по оси x |
| *int* | y | Координата прямоугольника по оси y |
| *int* | width | Ширина прямоугольника |
| *int* | height | Высота прямоугольника |
| *int* | background | Цвет фона прямоугольника |
| *int* | foreground | Цвет символов прямоугольника |
| *char* | symbol | Символ, которым будет заполнен прямоугольник |
| [*float* | transparency] | Опциональная прозрачность прямоугольника |

Заполнить прямоугольную область указанными данными. При указании прозрачности в диапазоне [0.0; 1.0] прямоугольник будет накладываться поверх существующей информации, словно прозрачное стеклышко.

buffer.**clear**( [color, transparency] )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| [*int* | background] | Опциональный цвет фона |
| [*float* | transparency] | Опциональная прозрачность фона |

Работает как buffer.**square**(...), однако применяется сразу ко всем пикселям буфера. Если аргументов не передается, то буфер заполняется стандартным черным цветом и символом пробела. Удобно для быстрой очистки содержимого буфера.

buffer.**text**( x, y, color, text, transparency )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | x | Координата текста по оси x |
| *int* | y | Координата текста  по оси y |
| *int* | foreground | Цвет текста |
| *string* | text | Текст |
| [*float* | transparency] | Опциональная прозрачность текста |

Нарисовать текст указанного цвета поверх имеющихся пикселей. Цвет фона при этом остается прежним. Можно также указать опциональную прозрачность текста текста в диапазоне [0.0; 1.0].

buffer.**formattedText**( x, y, text )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | x | Координата текста по оси x |
| *int* | y | Координата текста  по оси y |
| *string* | text | Текст |

Аналогичен методу buffer.**text**(), однако поддерживает цветовое форматирование. По умолчанию цвет текста имеет значение 0xFFFFFF, для его изменения используйте синтаксическую вставку вида **\#RRGGBB**. К примеру, "Hello world, **\#FF00FF**this is formatted text!".

buffer.**image**( x, y, picture )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | x | Координата изображения по оси x |
| *int* | y | Координата изображения  по оси y |
| *table* | picture | Загруженное изображение |

Нарисовать загруженное через image.**load**(*string* path) изображение. Альфа-канал изображения также поддерживается.

Методы полупиксельной отрисовки
======

Все методы полупиксельной отрисовки позволяют избежать эффекта удвоения высоты пикселя консольной графики, используя специальные символы наподобие "▄". При этом передаваемые координаты по оси **Y** должны принадлежать промежутку **[0; buffer.height * 2]**. 


buffer.**semiPixelSet**( x, y, color )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | x1 | Координата пикселя по оси x |
| *int* | y1 | Координата пикселя по оси y |
| *int* | color | Цвет пикселя |

Установка пиксельного значения в указанной точке.

buffer.**semiPixelSquare**( x, y, width, height, color )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | x | Координата прямоугольника по оси x |
| *int* | y | Координата прямоугольника по оси y |
| *int* | width | Ширина прямоугольника |
| *int* | height | Высота прямоугольника |
| *int* | color | Цвет прямоугольника |

Отрисовка прямоугольника с указанными параметрами.

buffer.**semiPixelLine**( x1, y1, x2, y2, color )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | x1 | Координата первой точки линии по оси x |
| *int* | y1 | Координата первой точки линии по оси y |
| *int* | x2 | Координата второй точки линии по оси x |
| *int* | y2 | Координата второй точки линии по оси y |
| *int* | color | Цвет линии |

Растеризация отрезка указанного цвета

buffer.**semiPixelCircle**( xCenter, yCenter, radius, color )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | xCenter | Координата центральной точки окружности по оси x |
| *int* | yCenter | Координата центральной точки окружности по оси y |
| *int* | radius | Радиус окружности |
| *int* | color | Цвет окружности |

buffer.**semiPixelBezierCurve**( points, color, precision )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *table* | points | Таблица вида ```{{x = 32, y = 2}, {x = 2, y = 2}, {x = 2, y = 98}}```, содержащая опорные точки для отрисовки кривой Безье |
| *int* | color | Цвет кривой Безье |
| *float* | precision | Точность отрисовки кривой Безье. Чем меньше - тем точнее |

Растеризация [кривой Безье](https://ru.wikipedia.org/wiki/%D0%9A%D1%80%D0%B8%D0%B2%D0%B0%D1%8F_%D0%91%D0%B5%D0%B7%D1%8C%D0%B5) с указанным цветом.

Вспомогательные методы
======

Ниже перечислены методы, используемые самой библиотекой или приложениями, требующими максимального быстродействия и рассчитывающими пиксельные данные буфера вручную. В большинстве случаев они не пригождаются, однако для ознакомления указаны.

buffer.**flush**( [width, height] )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | width | Ширина буфера |
| *int* | height | Высота буфера |

Метод, устанавливающий разрешение экранного буфера равным указанному и заполняющий его черными пикселями с символом пробела. В отличие от buffer.**setResolution** не изменяет текущего разрешения GPU. Если опциональные аргументы не указаны, то размер буфера становится эквивалентным текущему разрешению GPU.

buffer.**getIndex*( x, y ): int index
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | x | Координата пикселя экрана по оси x |
| *int* | y | Координата пикселя экрана по оси y |

Метод, преобразующий экранные координаты в индекс экраннного буфера. К примеру, пиксель 2x1 имеет индекс буфера 4, а пиксель 3x1 имеет индекс буфера 7.

buffer.**getCoordinates**( index ): int x, int y
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | index | Индекс экранного буфера |

Метод, преобразующий индекс буфера в соответствующие ему координаты на экране.

buffer.**rawSet**( index, background, foreground, symbol )
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | index | Индекс экранного буфера |
| *int* | background | Цвет фона |
| *int* | foreground | Цвет символа |
| *char* | symbol | Символ |

Метод, устанавливающий соответствующие значения цветов и символа пикселю с указанным индексом.

buffer.**rawGet**( index ): int background, int foreground, char symbol
-----------------------------------------------------------
| Тип | Аргумент | Описание |
| ------ | ------ | ------ |
| *int* | index | Индекс экранного буфера |

Метод, возвращающий соответствующие значения цветов и символа пикселя с указанным индексом.

Практический пример
======

```lua
-- Подключаем библиотеки
local buffer = require("doubleBuffering")
local image = require("image")

-----------------------------------------------------------------------------------------------

-- Загружаем и рисуем изображение
buffer.image(1, 1, image.load("/MineOS/Pictures/Raspberry.pic"))
-- Заполняем буфер черным цветом с прозрачностью 0.6, чтобы изображение было чуть темнее
buffer.clear(0x0, 0.6)

-- Рисуем 10 квадратиков, заполненных случайным цветом
local x, y, xStep, yStep = 2, 2, 4, 2
for i = 1, 10 do
	buffer.square(x, y, 6, 3, math.random(0x0, 0xFFFFFF), 0x0, " ")
	x, y = x + xStep, y + yStep
end

-- Рисуем желтую окружность
buffer.semiPixelCircle(22, 22, 10, 0xFFDB40)
-- Рисуем белую линию
buffer.semiPixelLine(2, 36, 35, 3, 0xFFFFFF)
-- Рисуем зеленую кривую Безье с точностью 0.01
buffer.semiPixelBezierCurve(
	{
		{ x = 2, y = 63},
		{ x = 63, y = 63},
		{ x = 63, y = 2}
	},
	0x44FF44,
	0.01
)

-- Выводим содержимое буфера на экран
buffer.draw()
```

Результат: 

![Imgur](http://i.imgur.com/wvu0jeh.png?1)

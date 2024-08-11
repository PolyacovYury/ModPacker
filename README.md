**Автор: Polyacov_Yury.**  
**Основано на проекте KMP, автор Kotyarko_O.**  
**Дополнительные ресурсы:**  
* [Apache License](http://www.apache.org/licenses/)
* [jrsoftware.org](http://jrsoftware.org/)
* [VCL-Styles](https://github.com/RRUZ/vcl-styles-plugins)
* [Bass](http://www.un4seen.com/)
* [iCatalyst](https://github.com/lorents17/iCatalyst)
* [OpenWG.Utils](https://koreanrandom.com/forum/topic/80506-)

**Использование**:
1. Удостовериться, что Inno Setup версии 6.2+ и Python 3.6+ установлены в системе.
2. Удостовериться, что iscc.exe и py.exe доступны в PATH.
3. Копируем содержимое папки /data/examples/ в папку /data/ и редактируем его под себя.
   - Знак процента в названии папки отделяет номер компонента от его идентификатора, поскольку идентификатор компонента не может начинаться с цифры.
   - Каждый компонент должен содержать файл lang.txt.
     - Нулевой уровень поддерживает только название, все остальные требуют название и описание (может быть пустым).
   - Компоненты нулевого уровня могут содержать файл dep_hard.txt
   - Компоненты других уровней могут содержать файлы dep_hard.txt и dep_soft.txt
   - Также, компоненты ненулевого уровня могут содержать файлы preview.png и preview.mp3.
4. Файл _build.bat собирает инсталлятор и кладёт его в папку /build/.
5. Файл _test.bat вызывает _build.bat и запускает собранный инсталлятор.

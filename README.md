# Задание №1

В файле `task1.rb` находится ruby-программа, которая выполняет обработку данных из файла.

При запуске `ruby task1.rb` запускается тест, который показывает как программа должна работать.

С помощью этой программы нужно обработать файл с данными `data_large.txt`.


**Проблема в том, что это происходит слишком долго, дождаться пока никому не удавалось.**


## Задача

- Оптимизировать эту программу, выстроив процесс согласно "общему фреймворку оптимизации" из первой презентации;
- Профилировать программу с помощью `stackprof` и `ruby-prof`, (можно ещё попробовать `vernier`);
- Добиться того, чтобы программа корректно обработала файл `data_large.txt` за `30 секунд`;
- Написать кейс-стади о вашей оптимизации по шаблону `case-study-template.md`.

Case-study должен получиться рассказом с техническими подробностями о том как вы пришли к успеху в оптимизации благодаря системному подходу. Можно сказать, заготовкой технической статьи.

## Сдача задания

Надо сделать `PR` в этот репозиторий и прислать его для проверки.

В `PR`-е
- должны быть внесены оптимизации в `task1.rb`;
- должен быть файл `case-study.md` с описанием проделанной оптимизации;


# Комментарии

## Риски

Задание моделирует такую ситуацию: вы получили неффективную систему, в которой код и производительность оставляет желать лучшего. При этом актуальной проблемой является именно плохая производительность.
Вам нужно оптимизировать эту незнакомую систему.

С какими искушениями вы сталкиваететь:
- вы “с ходу” замечаете какие-то непроизводительные идиомы, и у вас возникает соблазн их сразу исправить;
- попытаться в уме очень вникнуть в работу программы, как будто просветить её микроскопом, превратиться в компилятор

Эти искушения типичны и часто возникают в моделируемой ситуации, но есть риски:

- перед рефакторингом “очевидных” косяков не написать тестов и незаметно внести регрессию;
- потратить время на рефакторинг, хотя время было только на оптимизацию;
- исправить на глаз замеченные/предположенные проблемы, не получить заметного результата, решить что наверное просто Ruby слишком медленный для этой задачи, демотивироваться

## Советы

- Найдите объём данных, на которых программа отрабатывает достаточно быстро - это позволит вам выстроить фидбек-луп; если улучшите метрику для части данных, то улучшите и для полного объёма данных; *оптимально давать программе покрутиться секунд 5; слишком мало тоже нехорошо для профилирования и бенчмаркинга*
- Попробуйте прикинуть ассимтотику роста времени работы в зависимости от объёма входных данных (попробуйте объём x, 2x, 3x, ...)
- Оцените, как долго программа будет обрабатывать полный обём данных
- Вкладывайтесь в удобство работы и скорость получения обратной связи, сделайте себе эффективный фидбек-луп

### Советы по профилированию и измерению метрики

- попробуйсте `rbspy`
- попробуйте `Stackprof` с визуализацией в `Speedpscope` и `CLI`
- попробуйте `ruby-prof`
- попробуйте `Vernier`
- задайте простую и понятную метрику для оптимизируемой системы (на каждой итерации)
- отключайте профилировщики при вычислении метрики (они замедляют работу системы)
- не замеряйте время профилировщиком (при замерах он вообще должен быть отключен)
- aka не смешивайте профилирование и бенчмаркинг

### Совет: как посчитать кол-во строк в файле

```
wc -l data_large.rb # (3250940)  total line count
```

### Совет: как создать меньший файл из большего, оставив перевые N строк

```
head -n N data_large.txt > dataN.txt # create smaller file from larger (take N first lines)
```

## Что нужно делать

- исследовать предложенную вам на рассмотрение систему
- построить фидбек-луп, который позволит вам быстро тестировать гипотезы и измерять их эффект
- применить инструменты профилирования CPU, чтобы найти главные точки роста
- выписывать в case-study несколько пунктов: каким профилировщиком вы нашли точку роста, как её оптимизировали, какой получили прирост метрики, как найденная проблема перестала быть главной точкой роста;


## Что не нужно делать

- переписывать с нуля
- забивать на выстраивание фидбек-лупа
- вносить оптимизации по наитию, без профилировщика и без оценки эффективности
- смешивать несколько изменений в одну итерацию

## Что можно делать

- рефакторить код
- рефакторить/дописывать тесты
- разбивать скрипт на несколько файлов

## Основная польза задания

Главная польза этого задания - попрактиковаться в применении грамотного и системного подхода к оптимизации, почуствовать этот процесс:
- как взяли незнакомую систему и исследовали её
- как выстроили фидбек луп
- как с помощью профилировщиков сформировали гипотезу о том что именно даст вам наибольший эффект (главную точку роста)
- как быстро протестировали гипотезу, получили измеримый результат и зафиксировали его
- как в итоге написали небольшой журнал об успешных шагах этого процесса

## Extended Checklist

Советую использовать все рассмотренные в лекции инструменты хотя бы по разу - попрактикуйтесь с ними, научитесь с ними работать.

- [ ] Прикинуть зависимость времени работы програмы от размера обрабатываемого файла
- [ ] Поюзать `stackprof` со `speedscope` и `cli`
- [ ] Профилировать работающий процесс `rbspy`;
- [ ] Попробовать `vernier`
- [ ] Постараться довести асимптотику до линейной и написать на это `assert`;

## Second Thread - Reaper
- [ ] По фану можно завести второй тред, который будет убивать процесс, если прошло больше 30 секунд

### Главное

Нужно потренироваться методично работать по схеме с фидбек-лупом:
- построили отчёт каким-то из профилировщиков
- осознали его
- поняли, какая самая большая точка роста
- внесли минимальные изменения, чтобы использовать только эту точку роста
- вычислили метрику - оценили, как изменение повлияло на метрику
- перестроили отчёт, убедились, что проблема решена
- записали полученные результаты
- закоммитились
- перешли к следующей итерации

### PS

**Не комитьте пожалуйста много файлов типа дампов профилировщиков или усечённых data.txt**

**Самое главное в этом задании это case-study, и на втором месте ruby-код.**

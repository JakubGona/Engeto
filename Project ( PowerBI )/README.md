# Projekt : Power BI report #

### Úvod do projektu ###

Vypracoval som Power BI projekt podľa zadania ENGETO z Projektu 2.

Základom reportu je 5 Excel tabuliek ktoré slúžia ako náhrada funkčný dynamických zdrojov. Tabuľky som vyplnil pomocou random funkcií v Exceli ( RAND a RANDBETWEEN ) s podobným rozložením ako má ostro používaná relačná databáza ERP alebo CRM systémov ktoré môžu firmy používať.

﻿Všetky tabuľky sú prepojené pomocou IDs ( Primary keys ) a odkazujú na seba tak, aby bolo do tabuliek možné pridávať nové dáta bez nutnosti naviazanosti ( Teda aj bez zmien v hlavne SalesTable tabuľke ) a môžeme ich teda meniť rovnako ako v dynamických zdrojoch.

Pridal som nové grafické pozadie v jpg ( Vytvorené vo Photoshope ) a upravil všetky farby reportu tak, aby bol dobre čitateľný a mohol byť používaný na ukážku tržieb a predajov.

Tabuľky obsahujú dáta len za rok 2024.

SalesTable ( Tabuľka všetkých predajov s odkazmi do iných tabuliek )
Customer ( Tabuľka zákazníkov )
Location ( Tabuľka krajín )
Product ( Tabuľka produktov s ich menami a parametrami )
Budget ( Tabuľka budgetu )

### Zadanie projektu ###

Rozsah 2-5 stránek ( Celkovo 4 funkčné listy )

Použití minimálně 5 různých typů vizuálů ( Použitých viac vizuálov )

Filtrování (primárně) pomocí průřezů/slicerů ( Pridané filtry na dátum alebo kategóriu )

Využití interaktivních prvků jako jsou záložky, navigace po stranách, odkazy na webové stránky, ... ( Odkazy na webové stránky alebo navigácia pomocou šípiek v produkte )

Propojení několika (2+) datových tabulek, buď přes vazby v rámci Power BI nebo přes propojení v Power Query ( Report má prepojených 5 tabuliek )

Použití vytvořené hierarchie o alespoň dvou úrovních (nepovinné) ( Hierarchia dátumu použitá vo filtre )

Vytvoření alespoň 1 measure (metrika/míra) a 1 kalkulovaného sloupce/tabulky ( Celkovo 3 measurements pre výpočet nákladov alebo marginu )

Grafická úprava použitých vizuálů, zvolení správných typů vizuálů a vizuálně přívětivý výsledný report ( Vytvorené grafické pozadie a výber farieb v celkom reporte )

### Výstupy z projektu ###

Report zobrazuje predaje a zisky dodávateľa potravín do rôznych obchodov. Pracuje s krajinami, druhmi produktov a s ďalšími parametrami ktoré by sa mohli použiť pri podobnom reporte.

Pomocou viacero listov si uživateľ môže zobraziť KPIs, pohľady na predaj podľa objednávok alebo zákazníkov.

Všetky listy sú plne dynamické a môžu sa používať na zobrazovanie viacero dát.



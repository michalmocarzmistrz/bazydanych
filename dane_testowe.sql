-- ============================================================
-- Dane testowe: system oczyszczalni ścieków
-- Kolejność: słowniki → encje → urządzenia → relacje → zdarzenia
-- UWAGA: priorytet i typ_sterowania już są w bazie
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. Słowniki (jeszcze puste)
-- ------------------------------------------------------------

INSERT INTO typ_zbiornika (nazwa, opis) VALUES
    ('osadnik wstępny',    'Zbiornik do wstępnego osadzania zawiesin'),
    ('reaktor biologiczny', 'Zbiornik do biologicznego oczyszczania ścieków'),
    ('osadnik wtórny',     'Zbiornik do końcowego osadzania osadu czynnego'),
    ('zbiornik retencyjny','Zbiornik buforowy dla przepływów szczytowych');

INSERT INTO typ_czujnika (nazwa, opis) VALUES
    ('temperatury',         'Czujnik pomiaru temperatury cieczy'),
    ('pH',                  'Czujnik pomiaru odczynu pH'),
    ('tlenu rozpuszczonego','Czujnik pomiaru stężenia O2'),
    ('przepływu',           'Czujnik natężenia przepływu'),
    ('poziomu',             'Czujnik poziomu cieczy w zbiorniku');

INSERT INTO typ_sterownika (nazwa, opis) VALUES
    ('PLC Siemens S7',   'Sterownik PLC serii Siemens S7-300/400'),
    ('PLC Allen-Bradley','Sterownik PLC serii Allen-Bradley CompactLogix'),
    ('mikrosterownik RTU','Zdalny terminal jednostkowy RTU');

INSERT INTO typ_elementu_wykonawczego (nazwa, opis) VALUES
    ('pompa',    'Pompa do przepompowywania ścieków lub osadu'),
    ('zawór',    'Zawór sterowany elektrycznie'),
    ('dmuchawa', 'Dmuchawa do napowietrzania reaktora biologicznego'),
    ('mieszadło','Mieszadło mechaniczne');

INSERT INTO typ_reagenta (nazwa, opis) VALUES
    ('koagulant',           'Środek do koagulacji zawiesin'),
    ('flokulant',           'Środek do flokulacji cząstek'),
    ('środek dezynfekcyjny','Chlor do dezynfekcji ścieków'),
    ('neutralizator pH',    'Kwas lub zasada do regulacji pH');

INSERT INTO typ_zrodla_wplywu (nazwa, opis) VALUES
    ('komunalne',    'Ścieki z gospodarstw domowych'),
    ('przemysłowe',  'Ścieki z zakładów przemysłowych'),
    ('deszczowe',    'Wody opadowe z kanalizacji ogólnospławnej'),
    ('rolnicze',     'Spływy z terenów rolniczych');

-- ------------------------------------------------------------
-- 2. Encje niezależne
-- ------------------------------------------------------------

INSERT INTO region (nazwa, powierzchnia) VALUES
    ('Mazowieckie', 35558.00),
    ('Małopolskie',  15183.00),
    ('Śląskie',      12333.00);

INSERT INTO operator_systemu (imie, nazwisko) VALUES
    ('Jan',   'Kowalski'),
    ('Anna',  'Nowak'),
    ('Piotr', 'Wiśniewski'),
    ('Maria', 'Wójcik');

INSERT INTO technik (imie, nazwisko, harmonogram) VALUES
    ('Tomasz',    'Kowalczyk',   'pon-pt 06:00-14:00'),
    ('Krzysztof', 'Kaminski',    'pon-pt 14:00-22:00'),
    ('Marek',     'Lewandowski', 'wt-sob 08:00-16:00'),
    ('Agnieszka', 'Zielinska',   'pon-pt 07:00-15:00');

INSERT INTO laboratorium (nazwa, adres, kontakt) VALUES
    ('Laboratorium Główne Warszawa', 'ul. Oczyszczalna 1, 00-001 Warszawa',  'lab.warszawa@oczyszczalnia.pl'),
    ('Laboratorium Kraków',          'ul. Wodna 12, 30-001 Kraków',           'lab.krakow@oczyszczalnia.pl'),
    ('Laboratorium Katowice',        'ul. Przemysłowa 5, 40-001 Katowice',    'lab.katowice@oczyszczalnia.pl');

INSERT INTO wartosc_mierzona (typ_pomiaru, jednostka) VALUES
    ('temperatura',        '°C'),
    ('pH',                 'pH'),
    ('tlen rozpuszczony',  'mg/L'),
    ('natężenie przepływu','m³/h'),
    ('poziom cieczy',      'm'),
    ('zawiesina ogólna',   'mg/L');

INSERT INTO dostawca (nazwa, adres) VALUES
    ('ChemTech Sp. z o.o.',          'ul. Chemiczna 3, 02-001 Warszawa'),
    ('AquaSupply S.A.',               'ul. Wodna 8, 31-001 Kraków'),
    ('IndustrialParts Sp. z o.o.',   'ul. Fabryczna 17, 41-001 Katowice');

-- ------------------------------------------------------------
-- 3. Encje zależne od słowników i regionów
-- ------------------------------------------------------------

INSERT INTO reagent (nazwa, id_typ_reagenta) VALUES
    ('Siarczan glinu Al2(SO4)3',    (SELECT id_typ_reagenta FROM typ_reagenta WHERE nazwa = 'koagulant')),
    ('Polielektrolit kationowy PAX',(SELECT id_typ_reagenta FROM typ_reagenta WHERE nazwa = 'flokulant')),
    ('Podchloryn sodu NaClO',       (SELECT id_typ_reagenta FROM typ_reagenta WHERE nazwa = 'środek dezynfekcyjny')),
    ('Kwas solny HCl 30%',          (SELECT id_typ_reagenta FROM typ_reagenta WHERE nazwa = 'neutralizator pH')),
    ('Wodorotlenek sodu NaOH',      (SELECT id_typ_reagenta FROM typ_reagenta WHERE nazwa = 'neutralizator pH'));

INSERT INTO oczyszczalnia (nazwa, adres, id_region) VALUES
    ('Oczyszczalnia Warszawa-Południe', 'ul. Rzeczna 10, 02-100 Warszawa',   (SELECT id_region FROM region WHERE nazwa = 'Mazowieckie')),
    ('Oczyszczalnia Kraków-Wschód',     'ul. Wisłoka 3, 31-200 Kraków',      (SELECT id_region FROM region WHERE nazwa = 'Małopolskie')),
    ('Oczyszczalnia Katowice-Centrum',  'ul. Stawowa 22, 40-100 Katowice',   (SELECT id_region FROM region WHERE nazwa = 'Śląskie'));

INSERT INTO magazyn (nazwa, adres, pojemnosc, id_region) VALUES
    ('Magazyn Centralny Warszawa', 'ul. Magazynowa 1, 02-200 Warszawa', 5000.00, (SELECT id_region FROM region WHERE nazwa = 'Mazowieckie')),
    ('Magazyn Kraków',             'ul. Składowa 4, 31-300 Kraków',     2500.00, (SELECT id_region FROM region WHERE nazwa = 'Małopolskie')),
    ('Magazyn Śląsk',              'ul. Hurtowa 9, 40-200 Katowice',    3000.00, (SELECT id_region FROM region WHERE nazwa = 'Śląskie'));

-- ------------------------------------------------------------
-- 4. Urządzenia techniczne
-- ------------------------------------------------------------

-- 6 zbiorników (po 2 na oczyszczalnię)
INSERT INTO zbiornik (id_typ_zbiornika, objetosc, id_oczyszczalnia) VALUES
    ((SELECT id_typ_zbiornika FROM typ_zbiornika WHERE nazwa = 'osadnik wstępny'),    800.00,  (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Warszawa-Południe')),
    ((SELECT id_typ_zbiornika FROM typ_zbiornika WHERE nazwa = 'reaktor biologiczny'),2500.00, (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Warszawa-Południe')),
    ((SELECT id_typ_zbiornika FROM typ_zbiornika WHERE nazwa = 'osadnik wtórny'),     1200.00, (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Warszawa-Południe')),
    ((SELECT id_typ_zbiornika FROM typ_zbiornika WHERE nazwa = 'osadnik wstępny'),    600.00,  (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Kraków-Wschód')),
    ((SELECT id_typ_zbiornika FROM typ_zbiornika WHERE nazwa = 'reaktor biologiczny'),1800.00, (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Kraków-Wschód')),
    ((SELECT id_typ_zbiornika FROM typ_zbiornika WHERE nazwa = 'osadnik wstępny'),    700.00,  (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Katowice-Centrum'));

-- 6 sterowników (po 2 na oczyszczalnię)
INSERT INTO sterownik (id_typ_sterownika, czy_dziala, id_oczyszczalnia) VALUES
    ((SELECT id_typ_sterownika FROM typ_sterownika WHERE nazwa = 'PLC Siemens S7'),    TRUE,  (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Warszawa-Południe')),
    ((SELECT id_typ_sterownika FROM typ_sterownika WHERE nazwa = 'PLC Allen-Bradley'), TRUE,  (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Warszawa-Południe')),
    ((SELECT id_typ_sterownika FROM typ_sterownika WHERE nazwa = 'PLC Siemens S7'),    TRUE,  (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Kraków-Wschód')),
    ((SELECT id_typ_sterownika FROM typ_sterownika WHERE nazwa = 'mikrosterownik RTU'),FALSE, (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Kraków-Wschód')),
    ((SELECT id_typ_sterownika FROM typ_sterownika WHERE nazwa = 'PLC Siemens S7'),    TRUE,  (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Katowice-Centrum')),
    ((SELECT id_typ_sterownika FROM typ_sterownika WHERE nazwa = 'PLC Allen-Bradley'), TRUE,  (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Katowice-Centrum'));

-- 6 czujników (różne typy, przypisane do kolejnych sterowników)
INSERT INTO czujnik (id_typ_czujnika, odczyt, czy_dziala, id_sterownik, id_wartosc_mierzona) VALUES
    (
        (SELECT id_typ_czujnika FROM typ_czujnika WHERE nazwa = 'temperatury'),
        18.5, TRUE,
        (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 0),
        (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'temperatura')
    ),
    (
        (SELECT id_typ_czujnika FROM typ_czujnika WHERE nazwa = 'pH'),
        7.2, TRUE,
        (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 0),
        (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'pH')
    ),
    (
        (SELECT id_typ_czujnika FROM typ_czujnika WHERE nazwa = 'tlenu rozpuszczonego'),
        4.8, TRUE,
        (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 1),
        (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'tlen rozpuszczony')
    ),
    (
        (SELECT id_typ_czujnika FROM typ_czujnika WHERE nazwa = 'przepływu'),
        320.0, TRUE,
        (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 2),
        (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'natężenie przepływu')
    ),
    (
        (SELECT id_typ_czujnika FROM typ_czujnika WHERE nazwa = 'poziomu'),
        2.3, TRUE,
        (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 3),
        (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'poziom cieczy')
    ),
    (
        (SELECT id_typ_czujnika FROM typ_czujnika WHERE nazwa = 'pH'),
        6.9, FALSE,
        (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 4),
        (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'pH')
    );

-- 5 elementów wykonawczych
INSERT INTO element_wykonawczy (id_typ_elementu_wykonawczego, wysterowanie, czy_dziala, id_sterownik, id_zbiornik) VALUES
    (
        (SELECT id_typ_elementu_wykonawczego FROM typ_elementu_wykonawczego WHERE nazwa = 'pompa'),
        75.00, TRUE,
        (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 0),
        (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 0)
    ),
    (
        (SELECT id_typ_elementu_wykonawczego FROM typ_elementu_wykonawczego WHERE nazwa = 'dmuchawa'),
        60.00, TRUE,
        (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 1),
        (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 1)
    ),
    (
        (SELECT id_typ_elementu_wykonawczego FROM typ_elementu_wykonawczego WHERE nazwa = 'zawór'),
        100.00, TRUE,
        (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 2),
        (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 2)
    ),
    (
        (SELECT id_typ_elementu_wykonawczego FROM typ_elementu_wykonawczego WHERE nazwa = 'mieszadło'),
        50.00, FALSE,
        (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 3),
        (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 3)
    ),
    (
        (SELECT id_typ_elementu_wykonawczego FROM typ_elementu_wykonawczego WHERE nazwa = 'pompa'),
        80.00, TRUE,
        (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 4),
        (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 4)
    );

-- ------------------------------------------------------------
-- 5. Połączenia między zbiornikami (przepływ ścieków)
-- ------------------------------------------------------------

INSERT INTO polaczenie_zbiornikow (id_zbiornik_zrodlowy, id_zbiornik_docelowy) VALUES
    (
        (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 0),
        (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 1)
    ),
    (
        (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 1),
        (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 2)
    ),
    (
        (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 3),
        (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 4)
    );

-- ------------------------------------------------------------
-- 6. Powiązania z wartościami mierzonymi
-- ------------------------------------------------------------

INSERT INTO zbiornik_wartosc_mierzona (id_zbiornik, id_wartosc_mierzona) VALUES
    ((SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 0), (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'temperatura')),
    ((SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 0), (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'pH')),
    ((SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 1), (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'tlen rozpuszczony')),
    ((SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 1), (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'natężenie przepływu')),
    ((SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 2), (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'poziom cieczy'));

INSERT INTO sterownik_wartosc_mierzona (id_sterownik, id_wartosc_mierzona) VALUES
    ((SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 0), (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'temperatura')),
    ((SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 0), (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'pH')),
    ((SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 1), (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'tlen rozpuszczony')),
    ((SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 2), (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'natężenie przepływu'));

INSERT INTO laboratorium_wartosc_mierzona (id_laboratorium, id_wartosc_mierzona) VALUES
    ((SELECT id_laboratorium FROM laboratorium WHERE nazwa = 'Laboratorium Główne Warszawa'), (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'zawiesina ogólna')),
    ((SELECT id_laboratorium FROM laboratorium WHERE nazwa = 'Laboratorium Główne Warszawa'), (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'pH')),
    ((SELECT id_laboratorium FROM laboratorium WHERE nazwa = 'Laboratorium Kraków'),          (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'tlen rozpuszczony')),
    ((SELECT id_laboratorium FROM laboratorium WHERE nazwa = 'Laboratorium Katowice'),        (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'temperatura'));

-- ------------------------------------------------------------
-- 7. Reagenty w zbiornikach i magazynach
-- ------------------------------------------------------------

INSERT INTO zbiornik_reagent (id_zbiornik, id_reagent, aktualna_ilosc) VALUES
    ((SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 0), (SELECT id_reagent FROM reagent WHERE nazwa = 'Siarczan glinu Al2(SO4)3'),    150.00),
    ((SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 1), (SELECT id_reagent FROM reagent WHERE nazwa = 'Podchloryn sodu NaClO'),        80.00),
    ((SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 3), (SELECT id_reagent FROM reagent WHERE nazwa = 'Polielektrolit kationowy PAX'), 45.00);

INSERT INTO magazyn_reagent (id_magazyn, id_reagent, wolumen) VALUES
    ((SELECT id_magazyn FROM magazyn WHERE nazwa = 'Magazyn Centralny Warszawa'), (SELECT id_reagent FROM reagent WHERE nazwa = 'Siarczan glinu Al2(SO4)3'),    2000.00),
    ((SELECT id_magazyn FROM magazyn WHERE nazwa = 'Magazyn Centralny Warszawa'), (SELECT id_reagent FROM reagent WHERE nazwa = 'Podchloryn sodu NaClO'),        500.00),
    ((SELECT id_magazyn FROM magazyn WHERE nazwa = 'Magazyn Kraków'),             (SELECT id_reagent FROM reagent WHERE nazwa = 'Polielektrolit kationowy PAX'), 300.00),
    ((SELECT id_magazyn FROM magazyn WHERE nazwa = 'Magazyn Śląsk'),              (SELECT id_reagent FROM reagent WHERE nazwa = 'Kwas solny HCl 30%'),           100.00);

INSERT INTO magazyn_czujnik (id_magazyn, id_czujnik, ilosc) VALUES
    ((SELECT id_magazyn FROM magazyn WHERE nazwa = 'Magazyn Centralny Warszawa'), (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 0), 3),
    ((SELECT id_magazyn FROM magazyn WHERE nazwa = 'Magazyn Centralny Warszawa'), (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 1), 2),
    ((SELECT id_magazyn FROM magazyn WHERE nazwa = 'Magazyn Kraków'),             (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 2), 1);

INSERT INTO magazyn_sterownik (id_magazyn, id_sterownik, ilosc) VALUES
    ((SELECT id_magazyn FROM magazyn WHERE nazwa = 'Magazyn Centralny Warszawa'), (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 0), 1),
    ((SELECT id_magazyn FROM magazyn WHERE nazwa = 'Magazyn Kraków'),             (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 2), 1);

INSERT INTO magazyn_element_wykonawczy (id_magazyn, id_element_wykonawczy, ilosc) VALUES
    ((SELECT id_magazyn FROM magazyn WHERE nazwa = 'Magazyn Centralny Warszawa'), (SELECT id_element_wykonawczy FROM element_wykonawczy ORDER BY id_element_wykonawczy LIMIT 1 OFFSET 0), 2),
    ((SELECT id_magazyn FROM magazyn WHERE nazwa = 'Magazyn Kraków'),             (SELECT id_element_wykonawczy FROM element_wykonawczy ORDER BY id_element_wykonawczy LIMIT 1 OFFSET 2), 1),
    ((SELECT id_magazyn FROM magazyn WHERE nazwa = 'Magazyn Śląsk'),              (SELECT id_element_wykonawczy FROM element_wykonawczy ORDER BY id_element_wykonawczy LIMIT 1 OFFSET 4), 3);

-- ------------------------------------------------------------
-- 8. Dostawcy - relacje
-- ------------------------------------------------------------

INSERT INTO dostawca_reagent (id_dostawca, id_reagent, cena, czas_oczekiwania_dni) VALUES
    ((SELECT id_dostawca FROM dostawca WHERE nazwa = 'ChemTech Sp. z o.o.'), (SELECT id_reagent FROM reagent WHERE nazwa = 'Siarczan glinu Al2(SO4)3'),    1200.00, 3),
    ((SELECT id_dostawca FROM dostawca WHERE nazwa = 'ChemTech Sp. z o.o.'), (SELECT id_reagent FROM reagent WHERE nazwa = 'Podchloryn sodu NaClO'),        850.00,  5),
    ((SELECT id_dostawca FROM dostawca WHERE nazwa = 'AquaSupply S.A.'),      (SELECT id_reagent FROM reagent WHERE nazwa = 'Polielektrolit kationowy PAX'),2300.00, 7),
    ((SELECT id_dostawca FROM dostawca WHERE nazwa = 'AquaSupply S.A.'),      (SELECT id_reagent FROM reagent WHERE nazwa = 'Kwas solny HCl 30%'),          400.00,  2);

INSERT INTO dostawca_czujnik (id_dostawca, id_czujnik, cena, czas_oczekiwania_dni) VALUES
    ((SELECT id_dostawca FROM dostawca WHERE nazwa = 'IndustrialParts Sp. z o.o.'), (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 0), 3200.00, 14),
    ((SELECT id_dostawca FROM dostawca WHERE nazwa = 'IndustrialParts Sp. z o.o.'), (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 1), 4100.00, 14),
    ((SELECT id_dostawca FROM dostawca WHERE nazwa = 'AquaSupply S.A.'),             (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 2), 2800.00, 10);

INSERT INTO dostawca_sterownik (id_dostawca, id_sterownik, cena, czas_oczekiwania_dni) VALUES
    ((SELECT id_dostawca FROM dostawca WHERE nazwa = 'IndustrialParts Sp. z o.o.'), (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 0), 18000.00, 30),
    ((SELECT id_dostawca FROM dostawca WHERE nazwa = 'IndustrialParts Sp. z o.o.'), (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 1), 15000.00, 21);

INSERT INTO dostawca_element_wykonawczy (id_dostawca, id_element_wykonawczy, cena, czas_oczekiwania_dni) VALUES
    ((SELECT id_dostawca FROM dostawca WHERE nazwa = 'IndustrialParts Sp. z o.o.'), (SELECT id_element_wykonawczy FROM element_wykonawczy ORDER BY id_element_wykonawczy LIMIT 1 OFFSET 0), 5500.00, 7),
    ((SELECT id_dostawca FROM dostawca WHERE nazwa = 'AquaSupply S.A.'),             (SELECT id_element_wykonawczy FROM element_wykonawczy ORDER BY id_element_wykonawczy LIMIT 1 OFFSET 1), 3200.00, 5),
    ((SELECT id_dostawca FROM dostawca WHERE nazwa = 'ChemTech Sp. z o.o.'),        (SELECT id_element_wykonawczy FROM element_wykonawczy ORDER BY id_element_wykonawczy LIMIT 1 OFFSET 2), 1800.00, 3);

-- ------------------------------------------------------------
-- 9. Operatorzy i technicy - przypisania
-- ------------------------------------------------------------

INSERT INTO operator_oczyszczalnia (id_operator, id_oczyszczalnia) VALUES
    ((SELECT id_operator FROM operator_systemu WHERE imie = 'Jan'   AND nazwisko = 'Kowalski'),   (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Warszawa-Południe')),
    ((SELECT id_operator FROM operator_systemu WHERE imie = 'Anna'  AND nazwisko = 'Nowak'),      (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Warszawa-Południe')),
    ((SELECT id_operator FROM operator_systemu WHERE imie = 'Piotr' AND nazwisko = 'Wiśniewski'),(SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Kraków-Wschód')),
    ((SELECT id_operator FROM operator_systemu WHERE imie = 'Maria' AND nazwisko = 'Wójcik'),    (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Katowice-Centrum'));

INSERT INTO technik_region (id_technik, id_region) VALUES
    ((SELECT id_technik FROM technik WHERE imie = 'Tomasz'    AND nazwisko = 'Kowalczyk'),   (SELECT id_region FROM region WHERE nazwa = 'Mazowieckie')),
    ((SELECT id_technik FROM technik WHERE imie = 'Krzysztof' AND nazwisko = 'Kaminski'),    (SELECT id_region FROM region WHERE nazwa = 'Mazowieckie')),
    ((SELECT id_technik FROM technik WHERE imie = 'Marek'     AND nazwisko = 'Lewandowski'), (SELECT id_region FROM region WHERE nazwa = 'Małopolskie')),
    ((SELECT id_technik FROM technik WHERE imie = 'Agnieszka' AND nazwisko = 'Zielinska'),   (SELECT id_region FROM region WHERE nazwa = 'Śląskie'));

-- ------------------------------------------------------------
-- 10. Programy i historia sterowania
-- ------------------------------------------------------------

INSERT INTO program (autor, opis) VALUES
    ('Jan Kowalski',   'Program sterowania napowietrzaniem reaktora biologicznego'),
    ('Piotr Wiśniewski','Program dozowania koagulantu w osadniku wstępnym'),
    ('Anna Nowak',     'Program alarmowy dla przekroczeń pH');

INSERT INTO program_sterownik (id_program, id_sterownik) VALUES
    ((SELECT id_program FROM program WHERE autor = 'Jan Kowalski'),    (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 0)),
    ((SELECT id_program FROM program WHERE autor = 'Piotr Wiśniewski'),(SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 2)),
    ((SELECT id_program FROM program WHERE autor = 'Anna Nowak'),      (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 4));

INSERT INTO historia_sterowania (id_typ_sterowania, wartosc_sterowania, data_sterowania, id_sterownik) VALUES
    ((SELECT id_typ_sterowania FROM typ_sterowania WHERE nazwa = 'automatyczne'), '75%',  '2026-06-01 08:00:00', (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 0)),
    ((SELECT id_typ_sterowania FROM typ_sterowania WHERE nazwa = 'ręczne'),       '60%',  '2026-06-05 14:30:00', (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 1)),
    ((SELECT id_typ_sterowania FROM typ_sterowania WHERE nazwa = 'awaryjne'),     'STOP', '2026-06-10 03:15:00', (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 3)),
    ((SELECT id_typ_sterowania FROM typ_sterowania WHERE nazwa = 'automatyczne'), '80%',  '2026-06-15 09:00:00', (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 4)),
    ((SELECT id_typ_sterowania FROM typ_sterowania WHERE nazwa = 'ręczne'),       '45%',  '2026-06-18 11:00:00', (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 5));

-- ------------------------------------------------------------
-- 11. Źródła wpływu, wartości mierzone i prognozy
-- ------------------------------------------------------------

INSERT INTO zrodlo_wplywu (nazwa, id_typ_zrodla_wplywu, czas_wystapienia, id_zbiornik) VALUES
    ('Kolektor główny Warszawa', (SELECT id_typ_zrodla_wplywu FROM typ_zrodla_wplywu WHERE nazwa = 'komunalne'),   '2026-06-01 06:00:00', (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 0)),
    ('Zakład przemysłowy ABC',   (SELECT id_typ_zrodla_wplywu FROM typ_zrodla_wplywu WHERE nazwa = 'przemysłowe'),'2026-06-10 12:00:00', (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 0)),
    ('Kolektor burzowy Kraków',  (SELECT id_typ_zrodla_wplywu FROM typ_zrodla_wplywu WHERE nazwa = 'deszczowe'),  '2026-06-12 18:00:00', (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 3)),
    ('Spływ rolniczy Katowice',  (SELECT id_typ_zrodla_wplywu FROM typ_zrodla_wplywu WHERE nazwa = 'rolnicze'),   '2026-06-15 09:00:00', (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 5));

INSERT INTO zrodlo_wplywu_wartosc_mierzona (id_zrodlo_wplywu, id_wartosc_mierzona) VALUES
    ((SELECT id_zrodlo_wplywu FROM zrodlo_wplywu WHERE nazwa = 'Kolektor główny Warszawa'), (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'natężenie przepływu')),
    ((SELECT id_zrodlo_wplywu FROM zrodlo_wplywu WHERE nazwa = 'Zakład przemysłowy ABC'),   (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'pH')),
    ((SELECT id_zrodlo_wplywu FROM zrodlo_wplywu WHERE nazwa = 'Kolektor burzowy Kraków'),  (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'natężenie przepływu')),
    ((SELECT id_zrodlo_wplywu FROM zrodlo_wplywu WHERE nazwa = 'Spływ rolniczy Katowice'),  (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'zawiesina ogólna'));

INSERT INTO prognoza_wplywu (czas_prognozy, prognozowana_ilosc, program_prognozujacy, id_zrodlo_wplywu) VALUES
    ('2026-06-20 06:00:00', 1200.00, 'HydroForecast v2.1',  (SELECT id_zrodlo_wplywu FROM zrodlo_wplywu WHERE nazwa = 'Kolektor główny Warszawa')),
    ('2026-06-20 18:00:00',  800.00, 'HydroForecast v2.1',  (SELECT id_zrodlo_wplywu FROM zrodlo_wplywu WHERE nazwa = 'Kolektor główny Warszawa')),
    ('2026-06-21 06:00:00',  350.00, 'IndustrialPredictor', (SELECT id_zrodlo_wplywu FROM zrodlo_wplywu WHERE nazwa = 'Zakład przemysłowy ABC')),
    ('2026-06-20 12:00:00',  500.00, 'HydroForecast v2.1',  (SELECT id_zrodlo_wplywu FROM zrodlo_wplywu WHERE nazwa = 'Kolektor burzowy Kraków'));

-- ------------------------------------------------------------
-- 12. Próbki (pomiary)
-- ------------------------------------------------------------

INSERT INTO probka (czas_pomiaru, jednostka, wartosc, id_czujnik, id_laboratorium, id_prognoza_wplywu, id_wartosc_mierzona) VALUES
    ('2026-06-01 08:00:00', '°C',   17.8, (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 0), NULL, NULL, (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'temperatura')),
    ('2026-06-01 08:00:00', 'pH',    7.1, (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 1), NULL, NULL, (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'pH')),
    ('2026-06-05 10:00:00', 'mg/L',  5.2, NULL, (SELECT id_laboratorium FROM laboratorium WHERE nazwa = 'Laboratorium Główne Warszawa'), NULL, (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'tlen rozpuszczony')),
    ('2026-06-10 14:00:00', 'mg/L', 48.0, NULL, (SELECT id_laboratorium FROM laboratorium WHERE nazwa = 'Laboratorium Główne Warszawa'), NULL, (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'zawiesina ogólna')),
    ('2026-06-15 09:30:00', 'm³/h',310.0, (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 3), NULL, NULL, (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'natężenie przepływu')),
    ('2026-06-18 07:00:00', 'm',     2.1, (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 4), NULL, NULL, (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'poziom cieczy'));

-- ------------------------------------------------------------
-- 13. Awarie i alarmy
-- ------------------------------------------------------------

INSERT INTO awaria (data_awarii, id_priorytet, opis) VALUES
    ('2026-06-10 03:00:00', (SELECT id_priorytet FROM priorytet WHERE nazwa = 'wysoki'),    'Awaria sterownika RTU - utrata komunikacji'),
    ('2026-06-12 15:30:00', (SELECT id_priorytet FROM priorytet WHERE nazwa = 'średni'),    'Awaria czujnika pH - odczyt poza zakresem'),
    ('2026-06-17 22:00:00', (SELECT id_priorytet FROM priorytet WHERE nazwa = 'krytyczny'), 'Awaria pompy głównej - zatrzymanie przepływu');

INSERT INTO alarm (data_alarmu, id_priorytet, opis, id_wartosc_mierzona, id_awaria) VALUES
    ('2026-06-10 03:05:00', (SELECT id_priorytet FROM priorytet WHERE nazwa = 'wysoki'),    'Przekroczenie progu pH > 8.5',           (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'pH'),                 (SELECT id_awaria FROM awaria WHERE opis LIKE 'Awaria sterownika%')),
    ('2026-06-12 15:35:00', (SELECT id_priorytet FROM priorytet WHERE nazwa = 'średni'),    'Czujnik pH poza zakresem kalibracji',    (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'pH'),                 (SELECT id_awaria FROM awaria WHERE opis LIKE 'Awaria czujnika%')),
    ('2026-06-17 22:05:00', (SELECT id_priorytet FROM priorytet WHERE nazwa = 'krytyczny'), 'Brak przepływu przez reaktor biologiczny',(SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'natężenie przepływu'),(SELECT id_awaria FROM awaria WHERE opis LIKE 'Awaria pompy%')),
    ('2026-06-18 06:00:00', (SELECT id_priorytet FROM priorytet WHERE nazwa = 'niski'),     'Niski poziom reagentu w zbiorniku',      (SELECT id_wartosc_mierzona FROM wartosc_mierzona WHERE typ_pomiaru = 'poziom cieczy'),      NULL);

INSERT INTO awaria_czujnik (id_awaria, id_czujnik) VALUES
    ((SELECT id_awaria FROM awaria WHERE opis LIKE 'Awaria czujnika%'), (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 1)),
    ((SELECT id_awaria FROM awaria WHERE opis LIKE 'Awaria czujnika%'), (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 5));

INSERT INTO awaria_sterownik (id_awaria, id_sterownik) VALUES
    ((SELECT id_awaria FROM awaria WHERE opis LIKE 'Awaria sterownika%'), (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 3));

INSERT INTO awaria_element_wykonawczy (id_awaria, id_element_wykonawczy) VALUES
    ((SELECT id_awaria FROM awaria WHERE opis LIKE 'Awaria pompy%'), (SELECT id_element_wykonawczy FROM element_wykonawczy ORDER BY id_element_wykonawczy LIMIT 1 OFFSET 0)),
    ((SELECT id_awaria FROM awaria WHERE opis LIKE 'Awaria pompy%'), (SELECT id_element_wykonawczy FROM element_wykonawczy ORDER BY id_element_wykonawczy LIMIT 1 OFFSET 4));

INSERT INTO naprawa (data_naprawy, opis, id_awaria, id_technik) VALUES
    ('2026-06-10 06:00:00', 'Restart sterownika, przywrócenie komunikacji',    (SELECT id_awaria FROM awaria WHERE opis LIKE 'Awaria sterownika%'), (SELECT id_technik FROM technik WHERE imie = 'Tomasz'    AND nazwisko = 'Kowalczyk')),
    ('2026-06-13 09:00:00', 'Wymiana czujnika pH na nowy',                     (SELECT id_awaria FROM awaria WHERE opis LIKE 'Awaria czujnika%'),   (SELECT id_technik FROM technik WHERE imie = 'Krzysztof' AND nazwisko = 'Kaminski')),
    ('2026-06-18 04:30:00', 'Wymiana uszczelki pompy, przywrócenie przepływu', (SELECT id_awaria FROM awaria WHERE opis LIKE 'Awaria pompy%'),      (SELECT id_technik FROM technik WHERE imie = 'Marek'     AND nazwisko = 'Lewandowski'));

-- ------------------------------------------------------------
-- 14. Dokumentacja
-- ------------------------------------------------------------

INSERT INTO dokumentacja (autor, wersja, data_dokumentu, plik) VALUES
    ('Jan Kowalski',      '1.0', '2025-01-15', 'dok_oczyszczalnia_warszawa_v1.pdf'),
    ('Piotr Wiśniewski',  '2.1', '2025-06-01', 'dok_zbiorniki_krakow_v2.1.pdf'),
    ('Anna Nowak',        '1.3', '2026-03-10', 'dok_czujniki_v1.3.pdf'),
    ('Marek Lewandowski', '1.0', '2026-05-20', 'dok_sterowniki_v1.0.pdf');

INSERT INTO dokumentacja_oczyszczalnia (id_dokumentacja, id_oczyszczalnia) VALUES
    ((SELECT id_dokumentacja FROM dokumentacja WHERE plik = 'dok_oczyszczalnia_warszawa_v1.pdf'), (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Warszawa-Południe')),
    ((SELECT id_dokumentacja FROM dokumentacja WHERE plik = 'dok_zbiorniki_krakow_v2.1.pdf'),     (SELECT id_oczyszczalnia FROM oczyszczalnia WHERE nazwa = 'Oczyszczalnia Kraków-Wschód'));

INSERT INTO dokumentacja_zbiornik (id_dokumentacja, id_zbiornik) VALUES
    ((SELECT id_dokumentacja FROM dokumentacja WHERE plik = 'dok_zbiorniki_krakow_v2.1.pdf'), (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 3)),
    ((SELECT id_dokumentacja FROM dokumentacja WHERE plik = 'dok_zbiorniki_krakow_v2.1.pdf'), (SELECT id_zbiornik FROM zbiornik ORDER BY id_zbiornik LIMIT 1 OFFSET 4));

INSERT INTO dokumentacja_czujnik (id_dokumentacja, id_czujnik) VALUES
    ((SELECT id_dokumentacja FROM dokumentacja WHERE plik = 'dok_czujniki_v1.3.pdf'), (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 0)),
    ((SELECT id_dokumentacja FROM dokumentacja WHERE plik = 'dok_czujniki_v1.3.pdf'), (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 1)),
    ((SELECT id_dokumentacja FROM dokumentacja WHERE plik = 'dok_czujniki_v1.3.pdf'), (SELECT id_czujnik FROM czujnik ORDER BY id_czujnik LIMIT 1 OFFSET 2));

INSERT INTO dokumentacja_sterownik (id_dokumentacja, id_sterownik) VALUES
    ((SELECT id_dokumentacja FROM dokumentacja WHERE plik = 'dok_sterowniki_v1.0.pdf'), (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 0)),
    ((SELECT id_dokumentacja FROM dokumentacja WHERE plik = 'dok_sterowniki_v1.0.pdf'), (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 1)),
    ((SELECT id_dokumentacja FROM dokumentacja WHERE plik = 'dok_sterowniki_v1.0.pdf'), (SELECT id_sterownik FROM sterownik ORDER BY id_sterownik LIMIT 1 OFFSET 2));

INSERT INTO dokumentacja_element_wykonawczy (id_dokumentacja, id_element_wykonawczy) VALUES
    ((SELECT id_dokumentacja FROM dokumentacja WHERE plik = 'dok_sterowniki_v1.0.pdf'), (SELECT id_element_wykonawczy FROM element_wykonawczy ORDER BY id_element_wykonawczy LIMIT 1 OFFSET 0)),
    ((SELECT id_dokumentacja FROM dokumentacja WHERE plik = 'dok_sterowniki_v1.0.pdf'), (SELECT id_element_wykonawczy FROM element_wykonawczy ORDER BY id_element_wykonawczy LIMIT 1 OFFSET 1));

COMMIT;

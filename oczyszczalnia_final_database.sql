-- ============================================================
-- Fizyczna baza danych PostgreSQL na podstawie aktualnego EER
-- Projekt: system oczyszczalni ścieków
-- Wersja: odtworzenie bazy od zera
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. Usunięcie starej wersji tabel
-- ------------------------------------------------------------
DROP TABLE IF EXISTS
    dokumentacja_element_wykonawczy,
    dokumentacja_sterownik,
    dokumentacja_czujnik,
    dokumentacja_zbiornik,
    dokumentacja_oczyszczalnia,
    dokumentacja,

    alarm,
    naprawa,
    awaria_element_wykonawczy,
    awaria_sterownik,
    awaria_czujnik,
    awaria,

    probka,
    prognoza_wplywu,
    zrodlo_wplywu_wartosc_mierzona,
    zrodlo_wplywu,

    historia_sterowania,
    program_sterownik,
    program,

    dostawca_element_wykonawczy,
    dostawca_sterownik,
    dostawca_czujnik,
    dostawca_reagent,
    dostawca,

    magazyn_element_wykonawczy,
    magazyn_sterownik,
    magazyn_czujnik,
    magazyn_reagent,
    magazyn,

    zbiornik_reagent,
    zbiornik_wartosc_mierzona,
    polaczenie_zbiornikow,
    element_wykonawczy,
    czujnik,
    sterownik_wartosc_mierzona,
    sterownik,
    zbiornik,
    oczyszczalnia,
    operator_oczyszczalnia,
    technik_region,
    laboratorium_wartosc_mierzona,
    laboratorium,
    wartosc_mierzona,
    reagent,
    technik,
    operator_systemu,
    region,

    typ_zbiornika,
    typ_czujnika,
    typ_sterownika,
    typ_elementu_wykonawczego,
    typ_reagenta,
    typ_zrodla_wplywu,
    typ_sterowania,
    priorytet
CASCADE;

-- ------------------------------------------------------------
-- 2. Tabele słownikowe
-- Pola typu „typ” i „priorytet” nie są zwykłym tekstem,
-- tylko wartościami ze słowników.
-- ------------------------------------------------------------
CREATE TABLE typ_zbiornika (
    id_typ_zbiornika INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL UNIQUE,
    opis TEXT
);

CREATE TABLE typ_czujnika (
    id_typ_czujnika INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL UNIQUE,
    opis TEXT
);

CREATE TABLE typ_sterownika (
    id_typ_sterownika INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL UNIQUE,
    opis TEXT
);

CREATE TABLE typ_elementu_wykonawczego (
    id_typ_elementu_wykonawczego INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL UNIQUE,
    opis TEXT
);

CREATE TABLE typ_reagenta (
    id_typ_reagenta INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL UNIQUE,
    opis TEXT
);

CREATE TABLE typ_zrodla_wplywu (
    id_typ_zrodla_wplywu INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL UNIQUE,
    opis TEXT
);

CREATE TABLE typ_sterowania (
    id_typ_sterowania INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL UNIQUE,
    opis TEXT
);

CREATE TABLE priorytet (
    id_priorytet INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(50) NOT NULL UNIQUE,
    opis TEXT
);

-- ------------------------------------------------------------
-- 3. Główne encje organizacyjne
-- ------------------------------------------------------------
CREATE TABLE region (
    id_region INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL UNIQUE,
    powierzchnia NUMERIC(12,2),
    CHECK (powierzchnia IS NULL OR powierzchnia >= 0)
);

CREATE TABLE operator_systemu (
    id_operator INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    imie VARCHAR(60) NOT NULL,
    nazwisko VARCHAR(80) NOT NULL
);

CREATE TABLE technik (
    id_technik INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    imie VARCHAR(60) NOT NULL,
    nazwisko VARCHAR(80) NOT NULL,
    harmonogram TEXT
);

CREATE TABLE laboratorium (
    id_laboratorium INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(120) NOT NULL,
    adres VARCHAR(200),
    kontakt VARCHAR(120)
);

CREATE TABLE wartosc_mierzona (
    id_wartosc_mierzona INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    typ_pomiaru VARCHAR(100) NOT NULL,
    jednostka VARCHAR(30) NOT NULL,
    CONSTRAINT uq_wartosc_mierzona_typ_jednostka UNIQUE (typ_pomiaru, jednostka)
);

CREATE TABLE reagent (
    id_reagent INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(120) NOT NULL,
    id_typ_reagenta INTEGER NOT NULL,

    FOREIGN KEY (id_typ_reagenta)
        REFERENCES typ_reagenta(id_typ_reagenta)
);

CREATE TABLE oczyszczalnia (
    id_oczyszczalnia INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(120) NOT NULL,
    adres VARCHAR(200) NOT NULL,
    id_region INTEGER NOT NULL,

    FOREIGN KEY (id_region)
        REFERENCES region(id_region)
);

CREATE TABLE magazyn (
    id_magazyn INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(120) NOT NULL,
    adres VARCHAR(200),
    pojemnosc NUMERIC(12,2),
    id_region INTEGER NOT NULL,

    FOREIGN KEY (id_region)
        REFERENCES region(id_region),

    CHECK (pojemnosc IS NULL OR pojemnosc >= 0)
);

-- ------------------------------------------------------------
-- 4. Urządzenia i obiekty techniczne
-- ------------------------------------------------------------
CREATE TABLE zbiornik (
    id_zbiornik INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_typ_zbiornika INTEGER NOT NULL,
    objetosc NUMERIC(12,2),
    id_oczyszczalnia INTEGER NOT NULL,

    FOREIGN KEY (id_typ_zbiornika)
        REFERENCES typ_zbiornika(id_typ_zbiornika),

    FOREIGN KEY (id_oczyszczalnia)
        REFERENCES oczyszczalnia(id_oczyszczalnia)
        ON DELETE CASCADE,

    CHECK (objetosc IS NULL OR objetosc >= 0)
);

CREATE TABLE sterownik (
    id_sterownik INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_typ_sterownika INTEGER NOT NULL,
    czy_dziala BOOLEAN NOT NULL DEFAULT TRUE,
    id_oczyszczalnia INTEGER NOT NULL,

    FOREIGN KEY (id_typ_sterownika)
        REFERENCES typ_sterownika(id_typ_sterownika),

    FOREIGN KEY (id_oczyszczalnia)
        REFERENCES oczyszczalnia(id_oczyszczalnia)
        ON DELETE CASCADE
);

CREATE TABLE czujnik (
    id_czujnik INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_typ_czujnika INTEGER NOT NULL,
    odczyt NUMERIC(12,4),
    czy_dziala BOOLEAN NOT NULL DEFAULT TRUE,
    id_sterownik INTEGER NOT NULL,
    id_wartosc_mierzona INTEGER NOT NULL,

    FOREIGN KEY (id_typ_czujnika)
        REFERENCES typ_czujnika(id_typ_czujnika),

    FOREIGN KEY (id_sterownik)
        REFERENCES sterownik(id_sterownik)
        ON DELETE CASCADE,

    FOREIGN KEY (id_wartosc_mierzona)
        REFERENCES wartosc_mierzona(id_wartosc_mierzona)
);

CREATE TABLE element_wykonawczy (
    id_element_wykonawczy INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_typ_elementu_wykonawczego INTEGER NOT NULL,
    wysterowanie NUMERIC(5,2),
    czy_dziala BOOLEAN NOT NULL DEFAULT TRUE,
    id_sterownik INTEGER NOT NULL,
    id_zbiornik INTEGER NOT NULL,

    FOREIGN KEY (id_typ_elementu_wykonawczego)
        REFERENCES typ_elementu_wykonawczego(id_typ_elementu_wykonawczego),

    FOREIGN KEY (id_sterownik)
        REFERENCES sterownik(id_sterownik)
        ON DELETE CASCADE,

    FOREIGN KEY (id_zbiornik)
        REFERENCES zbiornik(id_zbiornik)
        ON DELETE CASCADE,

    CHECK (wysterowanie IS NULL OR (wysterowanie >= 0 AND wysterowanie <= 100))
);

-- Związek rekurencyjny ZBIORNIK -- ŁĄCZY SIĘ Z -- ZBIORNIK
CREATE TABLE polaczenie_zbiornikow (
    id_zbiornik_zrodlowy INTEGER NOT NULL,
    id_zbiornik_docelowy INTEGER NOT NULL,

    PRIMARY KEY (id_zbiornik_zrodlowy, id_zbiornik_docelowy),

    FOREIGN KEY (id_zbiornik_zrodlowy)
        REFERENCES zbiornik(id_zbiornik)
        ON DELETE CASCADE,

    FOREIGN KEY (id_zbiornik_docelowy)
        REFERENCES zbiornik(id_zbiornik)
        ON DELETE CASCADE,

    CHECK (id_zbiornik_zrodlowy <> id_zbiornik_docelowy)
);

-- ------------------------------------------------------------
-- 5. Relacje użytkowania, przechowywania i stanu magazynowego
-- ------------------------------------------------------------
CREATE TABLE zbiornik_reagent (
    id_zbiornik INTEGER NOT NULL,
    id_reagent INTEGER NOT NULL,
    aktualna_ilosc NUMERIC(12,2) NOT NULL DEFAULT 0,

    PRIMARY KEY (id_zbiornik, id_reagent),

    FOREIGN KEY (id_zbiornik)
        REFERENCES zbiornik(id_zbiornik)
        ON DELETE CASCADE,

    FOREIGN KEY (id_reagent)
        REFERENCES reagent(id_reagent)
        ON DELETE CASCADE,

    CHECK (aktualna_ilosc >= 0)
);

CREATE TABLE magazyn_reagent (
    id_magazyn INTEGER NOT NULL,
    id_reagent INTEGER NOT NULL,
    wolumen NUMERIC(12,2) NOT NULL DEFAULT 0,

    PRIMARY KEY (id_magazyn, id_reagent),

    FOREIGN KEY (id_magazyn)
        REFERENCES magazyn(id_magazyn)
        ON DELETE CASCADE,

    FOREIGN KEY (id_reagent)
        REFERENCES reagent(id_reagent)
        ON DELETE CASCADE,

    CHECK (wolumen >= 0)
);

CREATE TABLE magazyn_czujnik (
    id_magazyn INTEGER NOT NULL,
    id_czujnik INTEGER NOT NULL,
    ilosc INTEGER NOT NULL DEFAULT 0,

    PRIMARY KEY (id_magazyn, id_czujnik),

    FOREIGN KEY (id_magazyn)
        REFERENCES magazyn(id_magazyn)
        ON DELETE CASCADE,

    FOREIGN KEY (id_czujnik)
        REFERENCES czujnik(id_czujnik)
        ON DELETE CASCADE,

    CHECK (ilosc >= 0)
);

CREATE TABLE magazyn_sterownik (
    id_magazyn INTEGER NOT NULL,
    id_sterownik INTEGER NOT NULL,
    ilosc INTEGER NOT NULL DEFAULT 0,

    PRIMARY KEY (id_magazyn, id_sterownik),

    FOREIGN KEY (id_magazyn)
        REFERENCES magazyn(id_magazyn)
        ON DELETE CASCADE,

    FOREIGN KEY (id_sterownik)
        REFERENCES sterownik(id_sterownik)
        ON DELETE CASCADE,

    CHECK (ilosc >= 0)
);

CREATE TABLE magazyn_element_wykonawczy (
    id_magazyn INTEGER NOT NULL,
    id_element_wykonawczy INTEGER NOT NULL,
    ilosc INTEGER NOT NULL DEFAULT 0,

    PRIMARY KEY (id_magazyn, id_element_wykonawczy),

    FOREIGN KEY (id_magazyn)
        REFERENCES magazyn(id_magazyn)
        ON DELETE CASCADE,

    FOREIGN KEY (id_element_wykonawczy)
        REFERENCES element_wykonawczy(id_element_wykonawczy)
        ON DELETE CASCADE,

    CHECK (ilosc >= 0)
);

-- ------------------------------------------------------------
-- 6. Dostawcy i relacje dostarczania
-- ------------------------------------------------------------
CREATE TABLE dostawca (
    id_dostawca INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(120) NOT NULL,
    adres VARCHAR(200)
);

CREATE TABLE dostawca_reagent (
    id_dostawca INTEGER NOT NULL,
    id_reagent INTEGER NOT NULL,
    cena NUMERIC(12,2),
    czas_oczekiwania_dni INTEGER,

    PRIMARY KEY (id_dostawca, id_reagent),

    FOREIGN KEY (id_dostawca)
        REFERENCES dostawca(id_dostawca)
        ON DELETE CASCADE,

    FOREIGN KEY (id_reagent)
        REFERENCES reagent(id_reagent)
        ON DELETE CASCADE,

    CHECK (cena IS NULL OR cena >= 0),
    CHECK (czas_oczekiwania_dni IS NULL OR czas_oczekiwania_dni >= 0)
);

CREATE TABLE dostawca_czujnik (
    id_dostawca INTEGER NOT NULL,
    id_czujnik INTEGER NOT NULL,
    cena NUMERIC(12,2),
    czas_oczekiwania_dni INTEGER,

    PRIMARY KEY (id_dostawca, id_czujnik),

    FOREIGN KEY (id_dostawca)
        REFERENCES dostawca(id_dostawca)
        ON DELETE CASCADE,

    FOREIGN KEY (id_czujnik)
        REFERENCES czujnik(id_czujnik)
        ON DELETE CASCADE,

    CHECK (cena IS NULL OR cena >= 0),
    CHECK (czas_oczekiwania_dni IS NULL OR czas_oczekiwania_dni >= 0)
);

CREATE TABLE dostawca_sterownik (
    id_dostawca INTEGER NOT NULL,
    id_sterownik INTEGER NOT NULL,
    cena NUMERIC(12,2),
    czas_oczekiwania_dni INTEGER,

    PRIMARY KEY (id_dostawca, id_sterownik),

    FOREIGN KEY (id_dostawca)
        REFERENCES dostawca(id_dostawca)
        ON DELETE CASCADE,

    FOREIGN KEY (id_sterownik)
        REFERENCES sterownik(id_sterownik)
        ON DELETE CASCADE,

    CHECK (cena IS NULL OR cena >= 0),
    CHECK (czas_oczekiwania_dni IS NULL OR czas_oczekiwania_dni >= 0)
);

CREATE TABLE dostawca_element_wykonawczy (
    id_dostawca INTEGER NOT NULL,
    id_element_wykonawczy INTEGER NOT NULL,
    cena NUMERIC(12,2),
    czas_oczekiwania_dni INTEGER,

    PRIMARY KEY (id_dostawca, id_element_wykonawczy),

    FOREIGN KEY (id_dostawca)
        REFERENCES dostawca(id_dostawca)
        ON DELETE CASCADE,

    FOREIGN KEY (id_element_wykonawczy)
        REFERENCES element_wykonawczy(id_element_wykonawczy)
        ON DELETE CASCADE,

    CHECK (cena IS NULL OR cena >= 0),
    CHECK (czas_oczekiwania_dni IS NULL OR czas_oczekiwania_dni >= 0)
);

-- ------------------------------------------------------------
-- 7. Programy i historia sterowania
-- ------------------------------------------------------------
CREATE TABLE program (
    id_program INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    autor VARCHAR(120) NOT NULL,
    opis TEXT
);

CREATE TABLE program_sterownik (
    id_program INTEGER NOT NULL,
    id_sterownik INTEGER NOT NULL,

    PRIMARY KEY (id_program, id_sterownik),

    FOREIGN KEY (id_program)
        REFERENCES program(id_program)
        ON DELETE CASCADE,

    FOREIGN KEY (id_sterownik)
        REFERENCES sterownik(id_sterownik)
        ON DELETE CASCADE
);

CREATE TABLE historia_sterowania (
    id_historia_sterowania INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_typ_sterowania INTEGER NOT NULL,
    wartosc_sterowania VARCHAR(100),
    data_sterowania TIMESTAMP NOT NULL,
    id_sterownik INTEGER NOT NULL,

    FOREIGN KEY (id_typ_sterowania)
        REFERENCES typ_sterowania(id_typ_sterowania),

    FOREIGN KEY (id_sterownik)
        REFERENCES sterownik(id_sterownik)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 8. Źródła wpływu, prognozy i próbki/pomiary
-- ------------------------------------------------------------
CREATE TABLE zrodlo_wplywu (
    id_zrodlo_wplywu INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa VARCHAR(120) NOT NULL,
    id_typ_zrodla_wplywu INTEGER NOT NULL,
    czas_wystapienia TIMESTAMP,
    id_zbiornik INTEGER NOT NULL,

    FOREIGN KEY (id_typ_zrodla_wplywu)
        REFERENCES typ_zrodla_wplywu(id_typ_zrodla_wplywu),

    FOREIGN KEY (id_zbiornik)
        REFERENCES zbiornik(id_zbiornik)
        ON DELETE CASCADE
);

CREATE TABLE prognoza_wplywu (
    id_prognoza_wplywu INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    czas_prognozy TIMESTAMP NOT NULL,
    prognozowana_ilosc NUMERIC(12,2),
    program_prognozujacy VARCHAR(120),
    id_zrodlo_wplywu INTEGER NOT NULL,

    FOREIGN KEY (id_zrodlo_wplywu)
        REFERENCES zrodlo_wplywu(id_zrodlo_wplywu)
        ON DELETE CASCADE,

    CHECK (prognozowana_ilosc IS NULL OR prognozowana_ilosc >= 0)
);

CREATE TABLE probka (
    id_probka INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    czas_pomiaru TIMESTAMP NOT NULL,
    jednostka VARCHAR(30) NOT NULL,
    wartosc NUMERIC(12,4) NOT NULL,
    id_czujnik INTEGER,
    id_laboratorium INTEGER,
    id_prognoza_wplywu INTEGER,
    id_wartosc_mierzona INTEGER NOT NULL,

    FOREIGN KEY (id_czujnik)
        REFERENCES czujnik(id_czujnik)
        ON DELETE SET NULL,

    FOREIGN KEY (id_laboratorium)
        REFERENCES laboratorium(id_laboratorium)
        ON DELETE SET NULL,

    FOREIGN KEY (id_prognoza_wplywu)
        REFERENCES prognoza_wplywu(id_prognoza_wplywu)
        ON DELETE SET NULL,

    FOREIGN KEY (id_wartosc_mierzona)
        REFERENCES wartosc_mierzona(id_wartosc_mierzona)
);

-- Relacje „dotyczy / za pomocą / pobiera” dla wartości mierzonych
CREATE TABLE zbiornik_wartosc_mierzona (
    id_zbiornik INTEGER NOT NULL,
    id_wartosc_mierzona INTEGER NOT NULL,

    PRIMARY KEY (id_zbiornik, id_wartosc_mierzona),

    FOREIGN KEY (id_zbiornik)
        REFERENCES zbiornik(id_zbiornik)
        ON DELETE CASCADE,

    FOREIGN KEY (id_wartosc_mierzona)
        REFERENCES wartosc_mierzona(id_wartosc_mierzona)
        ON DELETE CASCADE
);

CREATE TABLE sterownik_wartosc_mierzona (
    id_sterownik INTEGER NOT NULL,
    id_wartosc_mierzona INTEGER NOT NULL,

    PRIMARY KEY (id_sterownik, id_wartosc_mierzona),

    FOREIGN KEY (id_sterownik)
        REFERENCES sterownik(id_sterownik)
        ON DELETE CASCADE,

    FOREIGN KEY (id_wartosc_mierzona)
        REFERENCES wartosc_mierzona(id_wartosc_mierzona)
        ON DELETE CASCADE
);

CREATE TABLE laboratorium_wartosc_mierzona (
    id_laboratorium INTEGER NOT NULL,
    id_wartosc_mierzona INTEGER NOT NULL,

    PRIMARY KEY (id_laboratorium, id_wartosc_mierzona),

    FOREIGN KEY (id_laboratorium)
        REFERENCES laboratorium(id_laboratorium)
        ON DELETE CASCADE,

    FOREIGN KEY (id_wartosc_mierzona)
        REFERENCES wartosc_mierzona(id_wartosc_mierzona)
        ON DELETE CASCADE
);

CREATE TABLE zrodlo_wplywu_wartosc_mierzona (
    id_zrodlo_wplywu INTEGER NOT NULL,
    id_wartosc_mierzona INTEGER NOT NULL,

    PRIMARY KEY (id_zrodlo_wplywu, id_wartosc_mierzona),

    FOREIGN KEY (id_zrodlo_wplywu)
        REFERENCES zrodlo_wplywu(id_zrodlo_wplywu)
        ON DELETE CASCADE,

    FOREIGN KEY (id_wartosc_mierzona)
        REFERENCES wartosc_mierzona(id_wartosc_mierzona)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 9. Alarmy, awarie i naprawy
-- ------------------------------------------------------------
CREATE TABLE awaria (
    id_awaria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    data_awarii TIMESTAMP NOT NULL,
    id_priorytet INTEGER NOT NULL,
    opis TEXT,

    FOREIGN KEY (id_priorytet)
        REFERENCES priorytet(id_priorytet)
);

CREATE TABLE alarm (
    id_alarm INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    data_alarmu TIMESTAMP NOT NULL,
    id_priorytet INTEGER NOT NULL,
    opis TEXT,
    id_wartosc_mierzona INTEGER,
    id_awaria INTEGER,

    FOREIGN KEY (id_priorytet)
        REFERENCES priorytet(id_priorytet),

    FOREIGN KEY (id_wartosc_mierzona)
        REFERENCES wartosc_mierzona(id_wartosc_mierzona)
        ON DELETE SET NULL,

    FOREIGN KEY (id_awaria)
        REFERENCES awaria(id_awaria)
        ON DELETE SET NULL
);

CREATE TABLE awaria_czujnik (
    id_awaria INTEGER NOT NULL,
    id_czujnik INTEGER NOT NULL,

    PRIMARY KEY (id_awaria, id_czujnik),

    FOREIGN KEY (id_awaria)
        REFERENCES awaria(id_awaria)
        ON DELETE CASCADE,

    FOREIGN KEY (id_czujnik)
        REFERENCES czujnik(id_czujnik)
        ON DELETE CASCADE
);

CREATE TABLE awaria_sterownik (
    id_awaria INTEGER NOT NULL,
    id_sterownik INTEGER NOT NULL,

    PRIMARY KEY (id_awaria, id_sterownik),

    FOREIGN KEY (id_awaria)
        REFERENCES awaria(id_awaria)
        ON DELETE CASCADE,

    FOREIGN KEY (id_sterownik)
        REFERENCES sterownik(id_sterownik)
        ON DELETE CASCADE
);

CREATE TABLE awaria_element_wykonawczy (
    id_awaria INTEGER NOT NULL,
    id_element_wykonawczy INTEGER NOT NULL,

    PRIMARY KEY (id_awaria, id_element_wykonawczy),

    FOREIGN KEY (id_awaria)
        REFERENCES awaria(id_awaria)
        ON DELETE CASCADE,

    FOREIGN KEY (id_element_wykonawczy)
        REFERENCES element_wykonawczy(id_element_wykonawczy)
        ON DELETE CASCADE
);

CREATE TABLE naprawa (
    id_naprawa INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    data_naprawy TIMESTAMP NOT NULL,
    opis TEXT,
    id_awaria INTEGER NOT NULL,
    id_technik INTEGER NOT NULL,

    FOREIGN KEY (id_awaria)
        REFERENCES awaria(id_awaria)
        ON DELETE CASCADE,

    FOREIGN KEY (id_technik)
        REFERENCES technik(id_technik)
);

-- ------------------------------------------------------------
-- 10. Operatorzy, technicy i obsługa regionów/oczyszczalni
-- ------------------------------------------------------------
CREATE TABLE operator_oczyszczalnia (
    id_operator INTEGER NOT NULL,
    id_oczyszczalnia INTEGER NOT NULL,

    PRIMARY KEY (id_operator, id_oczyszczalnia),

    FOREIGN KEY (id_operator)
        REFERENCES operator_systemu(id_operator)
        ON DELETE CASCADE,

    FOREIGN KEY (id_oczyszczalnia)
        REFERENCES oczyszczalnia(id_oczyszczalnia)
        ON DELETE CASCADE
);

CREATE TABLE technik_region (
    id_technik INTEGER NOT NULL,
    id_region INTEGER NOT NULL,

    PRIMARY KEY (id_technik, id_region),

    FOREIGN KEY (id_technik)
        REFERENCES technik(id_technik)
        ON DELETE CASCADE,

    FOREIGN KEY (id_region)
        REFERENCES region(id_region)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 11. Dokumentacja
-- ------------------------------------------------------------
CREATE TABLE dokumentacja (
    id_dokumentacja INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    autor VARCHAR(120) NOT NULL,
    wersja VARCHAR(30),
    data_dokumentu DATE,
    plik VARCHAR(255)
);

CREATE TABLE dokumentacja_oczyszczalnia (
    id_dokumentacja INTEGER NOT NULL,
    id_oczyszczalnia INTEGER NOT NULL,

    PRIMARY KEY (id_dokumentacja, id_oczyszczalnia),

    FOREIGN KEY (id_dokumentacja)
        REFERENCES dokumentacja(id_dokumentacja)
        ON DELETE CASCADE,

    FOREIGN KEY (id_oczyszczalnia)
        REFERENCES oczyszczalnia(id_oczyszczalnia)
        ON DELETE CASCADE
);

CREATE TABLE dokumentacja_zbiornik (
    id_dokumentacja INTEGER NOT NULL,
    id_zbiornik INTEGER NOT NULL,

    PRIMARY KEY (id_dokumentacja, id_zbiornik),

    FOREIGN KEY (id_dokumentacja)
        REFERENCES dokumentacja(id_dokumentacja)
        ON DELETE CASCADE,

    FOREIGN KEY (id_zbiornik)
        REFERENCES zbiornik(id_zbiornik)
        ON DELETE CASCADE
);

CREATE TABLE dokumentacja_czujnik (
    id_dokumentacja INTEGER NOT NULL,
    id_czujnik INTEGER NOT NULL,

    PRIMARY KEY (id_dokumentacja, id_czujnik),

    FOREIGN KEY (id_dokumentacja)
        REFERENCES dokumentacja(id_dokumentacja)
        ON DELETE CASCADE,

    FOREIGN KEY (id_czujnik)
        REFERENCES czujnik(id_czujnik)
        ON DELETE CASCADE
);

CREATE TABLE dokumentacja_sterownik (
    id_dokumentacja INTEGER NOT NULL,
    id_sterownik INTEGER NOT NULL,

    PRIMARY KEY (id_dokumentacja, id_sterownik),

    FOREIGN KEY (id_dokumentacja)
        REFERENCES dokumentacja(id_dokumentacja)
        ON DELETE CASCADE,

    FOREIGN KEY (id_sterownik)
        REFERENCES sterownik(id_sterownik)
        ON DELETE CASCADE
);

CREATE TABLE dokumentacja_element_wykonawczy (
    id_dokumentacja INTEGER NOT NULL,
    id_element_wykonawczy INTEGER NOT NULL,

    PRIMARY KEY (id_dokumentacja, id_element_wykonawczy),

    FOREIGN KEY (id_dokumentacja)
        REFERENCES dokumentacja(id_dokumentacja)
        ON DELETE CASCADE,

    FOREIGN KEY (id_element_wykonawczy)
        REFERENCES element_wykonawczy(id_element_wykonawczy)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 12. Indeksy pomocnicze dla kluczy obcych
-- ------------------------------------------------------------
CREATE INDEX idx_oczyszczalnia_region ON oczyszczalnia(id_region);
CREATE INDEX idx_magazyn_region ON magazyn(id_region);
CREATE INDEX idx_zbiornik_oczyszczalnia ON zbiornik(id_oczyszczalnia);
CREATE INDEX idx_sterownik_oczyszczalnia ON sterownik(id_oczyszczalnia);
CREATE INDEX idx_czujnik_sterownik ON czujnik(id_sterownik);
CREATE INDEX idx_element_sterownik ON element_wykonawczy(id_sterownik);
CREATE INDEX idx_element_zbiornik ON element_wykonawczy(id_zbiornik);
CREATE INDEX idx_zrodlo_zbiornik ON zrodlo_wplywu(id_zbiornik);
CREATE INDEX idx_prognoza_zrodlo ON prognoza_wplywu(id_zrodlo_wplywu);
CREATE INDEX idx_probka_czujnik ON probka(id_czujnik);
CREATE INDEX idx_probka_laboratorium ON probka(id_laboratorium);
CREATE INDEX idx_probka_prognoza ON probka(id_prognoza_wplywu);
CREATE INDEX idx_probka_wartosc_mierzona ON probka(id_wartosc_mierzona);
CREATE INDEX idx_alarm_awaria ON alarm(id_awaria);
CREATE INDEX idx_alarm_wartosc_mierzona ON alarm(id_wartosc_mierzona);
CREATE INDEX idx_naprawa_awaria ON naprawa(id_awaria);
CREATE INDEX idx_naprawa_technik ON naprawa(id_technik);

-- ------------------------------------------------------------
-- 13. Minimalne wartości słownikowe, żeby baza od razu była używalna
-- ------------------------------------------------------------
INSERT INTO priorytet (nazwa) VALUES
    ('niski'),
    ('średni'),
    ('wysoki'),
    ('krytyczny');

INSERT INTO typ_sterowania (nazwa) VALUES
    ('automatyczne'),
    ('ręczne'),
    ('awaryjne');

COMMIT;

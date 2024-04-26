CREATE TABLE Penzermek (
    PenzID INT PRIMARY KEY,
    Orszag NVARCHAR(255),
    Ara INT,
    Evszam INT,
    Anyaga NVARCHAR(255),
    RaktMenny INT
);

CREATE TABLE Foglalasok (
    FoglalasID INT PRIMARY KEY,
    Darabszam INT,
    Statusz NVARCHAR(255),  PenzID INT,
);
CREATE TABLE Vasarlok (
    VasarlokID INT PRIMARY KEY IDENTITY,
    Email NVARCHAR(255),
    Nev NVARCHAR(255),
);
CREATE TABLE Vasarlasok (
    VasarlasID INT PRIMARY KEY IDENTITY(1, 1),
    VasarlokID INT,
    Datum DATE,
    Osszeg INT,
    FOREIGN KEY (VasarlokID) REFERENCES Vasarlok(VasarlokID)
   
);
CREATE TABLE vasarol (
    PenzID INT,
    VasarlasID INT,
    Menny INT,
    ReszOssz INT,
    PRIMARY KEY (PenzID, VasarlasID),
    FOREIGN KEY (PenzID) REFERENCES Penzermek(PenzID),
    FOREIGN KEY (VasarlasID) REFERENCES Vasarlasok(VasarlasID)
);


CREATE TABLE Szallitasok (
    SzallitasID INT PRIMARY KEY,
    Datum DATE, 
    PenzID INT,
    
    UtolsoVasarlasID INT, 
    FOREIGN KEY (UtolsoVasarlasID) REFERENCES Vasarlasok(VasarlasID)
);

CREATE TABLE Beszallitok (
    BeszallitokID INT PRIMARY KEY,
    kontaktinfo NVARCHAR(255),
    Nev NVARCHAR(255),
    UtolsoVasarlasID INT,  
    FOREIGN KEY (UtolsoVasarlasID) REFERENCES Szallitasok(SzallitasID)
);


CREATE TABLE foglal (
    PenzID INT,
    FoglalasID INT,
    PRIMARY KEY (PenzID, FoglalasID),
    FOREIGN KEY (PenzID) REFERENCES Penzermek(PenzID),
    FOREIGN KEY (FoglalasID) REFERENCES Foglalasok(FoglalasID)
);

CREATE TABLE beszallit (
    PenzID INT,
    SzallitasID INT,
    PRIMARY KEY (PenzID, SzallitasID),
    FOREIGN KEY (PenzID) REFERENCES Penzermek(PenzID),
    FOREIGN KEY (SzallitasID) REFERENCES Szallitasok(SzallitasID)
);
-- example
ALTER TABLE Vasarlasok
ALTER COLUMN VasarlasID INT IDENTITY(1, 1);



-- examples
INSERT INTO Penzermek (PenzID, Orszag, Ara, Evszam, Anyaga, RaktMenny)
VALUES 
    (1, 'Magyarország', 500, 2022, 'arany', 100),
    (2, 'USA', 300, 2021, 'ezüst', 200),
    (3, 'Németország', 700, 2023, 'arany', 50),
    (4, 'Oroszország', 250, 2020, 'réz', 300),
    (5, 'Japán', 600, 2022, 'platinum', 150);

-- insert
INSERT INTO Vasarlok (Email, Nev)
VALUES
    ('peter.kovacs@example.com', 'Kovács Péter'),
    ('julia.nagy@example.com', 'Nagy Júlia'),
    ('tamas.szabo@example.com', 'Szabó Tamás'),
    ('zoltan.kiss@example.com', 'Kiss Zoltán'),
    ('lilla.veszpremi@example.com', 'Veszprémi Lilla');
--for chechking the data
SELECT *
FROM Penzermek
SELECT *
FROM Vasarlok
SELECT *
FROM Vasarlasok
SELECT *
FROM vasarol

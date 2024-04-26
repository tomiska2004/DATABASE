--using transaction this procedure create purchases of coins.
--if the customer is not in the database, it will be created.
--if something is wrong than the transaction will be rollbacked.

--if everything is ok, the transaction will be commited.

DROP PROCEDURE IF EXISTS Purchases

CREATE PROCEDURE Purchases(
    @VasarlokID INT,
    @Datum DATE,
    @TermekKodok VARCHAR(255),
    @TermekMennyisegek VARCHAR(255),
    @Nev NVARCHAR(255),
    @Email NVARCHAR(255)
)
AS
BEGIN
    DECLARE @VevoLetezik INT;
    DECLARE @VasarlasID INT;
    DECLARE @OsszAr INT = 0;
    DECLARE @TVA FLOAT = 0.24; -- ÁFA százalék
    DECLARE @Index INT = 1;
    DECLARE @End INT;
    DECLARE @TermekKod NVARCHAR(255);
    DECLARE @TermekMennyiseg INT;
    DECLARE @EladasiAr INT;
    DECLARE @ReszOsszeg INT;
    DECLARE @TVAsReszosszeg INT;

    

    -- Ellen
    SELECT @VevoLetezik = COUNT(*)
    FROM Vasarlok
    WHERE VasarlokID = @VasarlokID;

    --beszur
    IF @VevoLetezik = 0
    BEGIN
       
        INSERT INTO Vasarlok (Nev, Email)
        VALUES (@Nev, @Email);
        
      
        SET @VasarlokID = SCOPE_IDENTITY();
    END
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Új vásárlás hozzáadása a Vasarlasok táblához
        INSERT INTO Vasarlasok (VasarlokID, Datum, Osszeg)
        VALUES (@VasarlokID, @Datum, 0);

        -- A vásárlás azonosítója lekérése
        SET @VasarlasID = SCOPE_IDENTITY();

        -- A termék kódok és mennyiségek feldolgozása
        WHILE @Index <= LEN(@TermekKodok) AND @Index <= LEN(@TermekMennyisegek)
        BEGIN
            -- Kiválasztjuk a termék kódját és mennyiségét
            SET @End = CHARINDEX(',', @TermekKodok + ',', @Index);
            SET @TermekKod = LTRIM(SUBSTRING(@TermekKodok, @Index, @End - @Index));
            SET @End = CHARINDEX(',', @TermekMennyisegek + ',', @Index);
            SET @TermekMennyiseg = LTRIM(SUBSTRING(@TermekMennyisegek, @Index, @End - @Index));

            -- Ellenőrzés a raktáron lévő mennyiség alapján
            DECLARE @RaktMenny INT;
            SELECT @RaktMenny = RaktMenny
            FROM Penzermek
            WHERE PenzID = @TermekKod;

            -- Ha nincs elég raktáron
            IF @RaktMenny < @TermekMennyiseg
            BEGIN
                ROLLBACK TRANSACTION;
                RETURN 1; -- Sikertelen
            END

            -- Eladási ár lekérése és részösszeg számítása
            SELECT @EladasiAr = Ara
            FROM Penzermek
            WHERE PenzID = @TermekKod;

            SET @ReszOsszeg = @TermekMennyiseg * @EladasiAr;
            SET @TVAsReszosszeg = @ReszOsszeg + (@ReszOsszeg * @TVA);
            SET @OsszAr += @TVAsReszosszeg;

            -- Vásárlás részleteinek hozzáadása a vasarol táblához
            INSERT INTO vasarol (PenzID, VasarlasID, Menny, ReszOssz)
            VALUES (@TermekKod, @VasarlasID, @TermekMennyiseg, @ReszOsszeg);

            -- Raktár mennyiség frissítése
            UPDATE Penzermek
            SET RaktMenny = RaktMenny - @TermekMennyiseg
            WHERE PenzID = @TermekKod;

            SET @Index = @End + 1;
        END

        -- Frissítjük az összértéket a Vasarlasok táblában
        UPDATE Vasarlasok
        SET Osszeg = @OsszAr
        WHERE VasarlasID = @VasarlasID;

        COMMIT TRANSACTION;
        RETURN 0; -- Sikeres
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1; -- Sikertelen
    END CATCH;
END;










DECLARE @ReturnCode INT;

EXEC @ReturnCode = Purchases @VasarlokID = 10, 
                      @Datum = '2024-04-22', 
                      @TermekKodok = '1', 
                      @TermekMennyisegek = '3',
                      @Nev = 'Péter',
                      @Email = 'peter@example.com';

PRINT 'Return code: ' + CONVERT(VARCHAR, @ReturnCode);

DECLARE @ReturnCode INT;
EXEC @ReturnCode = Purchases @VasarlokID = 1, 
                      @Datum = '2024-04-20', 
                      @TermekKodok = '1,4', 
                      @TermekMennyisegek = '3,20',
                      @Nev = 'Kovács Péter',
                      @Email = 'peter.kovacs@example.com';

PRINT 'Return code: ' + CONVERT(VARCHAR, @ReturnCode);

DECLARE @ReturnCode INT;
EXEC @ReturnCode = Purchases @VasarlokID = 4, 
                      @Datum = '2024-04-20', 
                      @TermekKodok = '4,2', 
                      @TermekMennyisegek = '3,2000',
                      @Nev = 'Gizella',
                      @Email = 'gizike@example.com';

PRINT 'Return code: ' + CONVERT(VARCHAR, @ReturnCode);

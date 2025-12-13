--
-- PostgreSQL database dump
--

\restrict eVbGzEd6zCTJlSPkUdyRD2ThnCXafC4ZA5uRFxB6SN2ccRxYoeoBqLLNqDFhyxd

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: AvmYonetimSistemi; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "AvmYonetimSistemi" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';


ALTER DATABASE "AvmYonetimSistemi" OWNER TO postgres;

\unrestrict eVbGzEd6zCTJlSPkUdyRD2ThnCXafC4ZA5uRFxB6SN2ccRxYoeoBqLLNqDFhyxd
\connect "AvmYonetimSistemi"
\restrict eVbGzEd6zCTJlSPkUdyRD2ThnCXafC4ZA5uRFxB6SN2ccRxYoeoBqLLNqDFhyxd

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: avm_yoneticisi_ekle_engelle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.avm_yoneticisi_ekle_engelle() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION 'AVM yöneticisi eklenemez!';
    RETURN NEW; 
END;
$$;


ALTER FUNCTION public.avm_yoneticisi_ekle_engelle() OWNER TO postgres;

--
-- Name: avm_yoneticisi_silme_engelle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.avm_yoneticisi_silme_engelle() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION 'AVM yöneticisi silinemez!';
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.avm_yoneticisi_silme_engelle() OWNER TO postgres;

--
-- Name: check_gelir_gider(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_gelir_gider() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_gider numeric;
BEGIN
    SELECT COALESCE(SUM(gidermiktari),0) INTO total_gider
    FROM gider
    WHERE magazano = NEW.magazano;

    IF NEW.gelirmiktari > total_gider THEN
        RAISE EXCEPTION 'Bu mağazanın geliri giderinden fazla olamaz!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_gelir_gider() OWNER TO postgres;

--
-- Name: check_magaza_magazaelemani_sayisi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_magaza_magazaelemani_sayisi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_magazaelemani integer;
BEGIN
    SELECT COUNT(*) INTO total_magazaelemani
    FROM magazaelemani
    WHERE magazano = NEW.magazano;

    IF total_magazaelemani < 3 THEN
        RAISE EXCEPTION 'Bu mağazada en az 3 çalışan olmalıdır!';
    ELSIF total_magazaelemani > 5 THEN
        RAISE EXCEPTION 'Bu mağazada en fazla 5 çalışan olabilir!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_magaza_magazaelemani_sayisi() OWNER TO postgres;

--
-- Name: check_magaza_sayisi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_magaza_sayisi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (SELECT COUNT(*) FROM magaza WHERE katno = NEW.katno) >= 5 THEN
        RAISE EXCEPTION 'Bu katta en fazla 5 mağaza olabilir';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_magaza_sayisi() OWNER TO postgres;

--
-- Name: check_max_magaza_kat(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_max_magaza_kat() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_magaza integer;
BEGIN
    SELECT COUNT(*) INTO total_magaza
    FROM magaza
    WHERE katno = NEW.katno;

    IF total_magaza >= 10 THEN
        RAISE EXCEPTION 'Bu katta en fazla 10 mağaza olabilir!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_max_magaza_kat() OWNER TO postgres;

--
-- Name: check_max_personel_kat(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_max_personel_kat() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_personel integer;
BEGIN
    SELECT COUNT(*) INTO total_personel
    FROM personel
    WHERE katno = NEW.katno;

    IF total_personel >= 5 THEN
        RAISE EXCEPTION 'Bu katta en fazla 5 personel olabilir!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_max_personel_kat() OWNER TO postgres;

--
-- Name: check_min_max_magaza_kat(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_min_max_magaza_kat() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_magaza integer;
BEGIN
    SELECT COUNT(*) INTO total_magaza
    FROM magaza
    WHERE katno = NEW.katno;

    IF total_magaza < 1 THEN
        RAISE EXCEPTION 'Bu katta en az 1 mağaza olmalıdır!';
    ELSIF total_magaza > 5 THEN
        RAISE EXCEPTION 'Bu katta en fazla 5 mağaza olabilir!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_min_max_magaza_kat() OWNER TO postgres;

--
-- Name: check_min_max_urunler_magaza(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_min_max_urunler_magaza() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_urunler integer;
BEGIN
    -- Bu mağazadaki toplam ürün sayısını al
    SELECT COUNT(*) INTO total_urunler
    FROM magazaurun
    WHERE magazano = NEW.magazano;

    -- Eğer 1’den az veya 10’dan fazla ise hata fırlat
    IF total_urunler < 1 THEN
        RAISE EXCEPTION 'Bu mağazada en az 1 ürün olmalıdır!';
    ELSIF total_urunler > 10 THEN
        RAISE EXCEPTION 'Bu mağazada en fazla 10 ürün olabilir!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_min_max_urunler_magaza() OWNER TO postgres;

--
-- Name: delete_kisi_when_magazaelemani_deleted(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_kisi_when_magazaelemani_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM kisi
    WHERE id = OLD.kisino;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_kisi_when_magazaelemani_deleted() OWNER TO postgres;

--
-- Name: delete_kisi_when_magazamuduru_deleted(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_kisi_when_magazamuduru_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM kisi
    WHERE id = OLD.kisino;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_kisi_when_magazamuduru_deleted() OWNER TO postgres;

--
-- Name: delete_kisi_when_magazasahibi_deleted(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_kisi_when_magazasahibi_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM kisi
    WHERE id = OLD.kisino;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_kisi_when_magazasahibi_deleted() OWNER TO postgres;

--
-- Name: delete_kisi_when_musteri_deleted(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_kisi_when_musteri_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM kisi
    WHERE id = OLD.kisino;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_kisi_when_musteri_deleted() OWNER TO postgres;

--
-- Name: delete_kisi_when_personel_deleted(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_kisi_when_personel_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM kisi
    WHERE id = OLD.kisino;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_kisi_when_personel_deleted() OWNER TO postgres;

--
-- Name: delete_kisi_when_tedarikci_deleted(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_kisi_when_tedarikci_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM kisi
    WHERE id = OLD.kisino;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_kisi_when_tedarikci_deleted() OWNER TO postgres;

--
-- Name: enforce_single_manager(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.enforce_single_manager() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   
    IF EXISTS (
        SELECT 1 
        FROM magazamuduru
        WHERE magazano = NEW.magazano
          AND no <> NEW.no 
    ) THEN
        RAISE EXCEPTION 'Bu mağazanın zaten bir müdürü var!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.enforce_single_manager() OWNER TO postgres;

--
-- Name: enforce_single_sahip(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.enforce_single_sahip() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM magazasahibi
        WHERE magazano= NEW.magazano
          AND no <> NEW.no   
    ) THEN
        RAISE EXCEPTION 'Bu mağazanın zaten bir sahibi var!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.enforce_single_sahip() OWNER TO postgres;

--
-- Name: f_magazatedarikci_eklendi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_magazatedarikci_eklendi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO magazatedarikci (tedarikcino, magazano)
    SELECT DISTINCT NEW.tedarikcino, m.magazano 
    FROM magaza m
    ON CONFLICT (tedarikcino, magazano) DO NOTHING; 

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.f_magazatedarikci_eklendi() OWNER TO postgres;

--
-- Name: fn_kat_personel_kontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_kat_personel_kontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_sayi INT;
BEGIN
    
    IF TG_OP = 'INSERT' THEN
        SELECT COUNT(*) INTO v_sayi
        FROM personel
        WHERE katno = NEW.katno;

        IF v_sayi >= 6 THEN
            RAISE EXCEPTION 'Bu katta zaten 6 personel var. Daha fazla eklenemez.';
        END IF;

        RETURN NEW;
    END IF;

    -- DELETE (Personel silme durumunda)
    IF TG_OP = 'DELETE' THEN
        SELECT COUNT(*) INTO v_sayi
        FROM personel
        WHERE katno = OLD.katno;

        IF v_sayi <= 1 THEN
            RAISE EXCEPTION 'Bu katta en az 1 personel bulunmalı. Silme işlemi engellendi.';
        END IF;

        RETURN OLD;
    END IF;

END;
$$;


ALTER FUNCTION public.fn_kat_personel_kontrol() OWNER TO postgres;

--
-- Name: fn_magazaelemani_kontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_magazaelemani_kontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_sayi INT;
BEGIN
    
    IF TG_OP = 'INSERT' THEN
        SELECT COUNT(*) INTO v_sayi
        FROM magazaelemani
        WHERE magazano = NEW.magazano;

        IF v_sayi >= 6 THEN
            RAISE EXCEPTION 'Bu mağazada zaten 6 eleman var. Daha fazla eklenemez.';
        END IF;

        RETURN NEW;
    END IF;

    
    IF TG_OP = 'DELETE' THEN
        SELECT COUNT(*) INTO v_sayi
        FROM magazaelemani
        WHERE magazano = OLD.magazano;

        IF v_sayi <= 1 THEN
            RAISE EXCEPTION 'Bu mağazada en az 1 eleman bulunmak zorunda. Silme işlemi engellendi.';
        END IF;

        RETURN OLD;
    END IF;

END;
$$;


ALTER FUNCTION public.fn_magazaelemani_kontrol() OWNER TO postgres;

--
-- Name: fn_magazaelemani_silme(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_magazaelemani_silme() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM kisi
    WHERE id = OLD.kisino;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.fn_magazaelemani_silme() OWNER TO postgres;

--
-- Name: fn_magazatedarikci_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_magazatedarikci_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   
    INSERT INTO magazatedarikci (magazano, tedarikcino)
    SELECT magazano, NEW.tedarikcino
    FROM magaza; 
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_magazatedarikci_insert() OWNER TO postgres;

--
-- Name: fn_personel_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_personel_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM kisi
    WHERE id = OLD.id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.fn_personel_delete() OWNER TO postgres;

--
-- Name: fn_personel_silme(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_personel_silme() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD.kisino IS NOT NULL THEN
        DELETE FROM kisi
        WHERE id = OLD.kisino;
    END IF;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.fn_personel_silme() OWNER TO postgres;

--
-- Name: fn_tedarikci_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_tedarikci_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM magazatedarikci
    WHERE tedarikcino = OLD.tedarikcino;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.fn_tedarikci_delete() OWNER TO postgres;

--
-- Name: fn_tedarikci_silme(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_tedarikci_silme() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM kisi
    WHERE id = OLD.kisino;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.fn_tedarikci_silme() OWNER TO postgres;

--
-- Name: magazaelemani_eklendi_kisi_ekle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.magazaelemani_eklendi_kisi_ekle() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    yeni_id INT;
BEGIN
    
    INSERT INTO kisi (ad, soyad, kisituru)
    VALUES (NEW.adi, NEW.soyadi, 'Mağaza Elemanı')
    RETURNING id INTO yeni_id;

    NEW.kisino := yeni_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.magazaelemani_eklendi_kisi_ekle() OWNER TO postgres;

--
-- Name: magazaelemani_guncellendi_kisi_guncelle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.magazaelemani_guncellendi_kisi_guncelle() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE kisi
    SET 
        ad = NEW.adi,
        soyad = NEW.soyadi
    WHERE id = OLD.kisino; 

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.magazaelemani_guncellendi_kisi_guncelle() OWNER TO postgres;

--
-- Name: musteri_eklendi_kisi_ekle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.musteri_eklendi_kisi_ekle() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    yeni_id INT;
BEGIN
    
    INSERT INTO kisi (ad, soyad, kisituru)
    VALUES (NEW.ad, NEW.soyad, 'Müşteri')
    RETURNING id INTO yeni_id;

    NEW.kisino := yeni_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.musteri_eklendi_kisi_ekle() OWNER TO postgres;

--
-- Name: personel_eklendi_kisi_ekle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.personel_eklendi_kisi_ekle() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    yeni_id INT;
BEGIN
    
    INSERT INTO kisi (ad, soyad, kisituru)
    VALUES (NEW.adi, NEW.soyadi, 'Personel')
    RETURNING id INTO yeni_id;

    NEW.kisino := yeni_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.personel_eklendi_kisi_ekle() OWNER TO postgres;

--
-- Name: prevent_kat_ekle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_kat_ekle() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION 'avm ye yeni kat eklenemez!';
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.prevent_kat_ekle() OWNER TO postgres;

--
-- Name: prevent_kat_sil(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_kat_sil() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION  'avm den kat silinemez!';
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.prevent_kat_sil() OWNER TO postgres;

--
-- Name: silmeyi_onle_otopark(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.silmeyi_onle_otopark() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION 'Otopark silinemez';
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.silmeyi_onle_otopark() OWNER TO postgres;

--
-- Name: spmagazaekle(text, integer, text, text, character, text, text, character, text, numeric, integer, text, text, character); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.spmagazaekle(IN p_magaza_adi text, IN p_katno integer, IN p_mudur_ad text, IN p_mudur_soyad text, IN p_mudur_cinsiyet character, IN p_sahip_ad text, IN p_sahip_soyad text, IN p_sahip_cinsiyet character, IN p_urun_adi text, IN p_urun_fiyat numeric, IN p_stok integer, IN p_eleman_ad text, IN p_eleman_soyad text, IN p_eleman_cinsiyet character)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_mudur_kisi_id INT;
    v_sahip_kisi_id INT;
    v_eleman_kisi_id INT;
    
    v_mudur_id INT;
    v_sahip_id INT;
    v_magaza_id INT;
    v_urun_id INT;
BEGIN
    
    INSERT INTO kisi (ad, soyad, cinsiyet, kisituru) 
    VALUES (p_mudur_ad, p_mudur_soyad, p_mudur_cinsiyet, 'Mudur')
    RETURNING id INTO v_mudur_kisi_id;

    INSERT INTO kisi (ad, soyad, cinsiyet, kisituru) 
    VALUES (p_sahip_ad, p_sahip_soyad, p_sahip_cinsiyet, 'Sahip')
    RETURNING id INTO v_sahip_kisi_id;

    INSERT INTO magazamuduru (kisino, adi, soyadi, cinsiyet, profilfoto)
    VALUES (v_mudur_kisi_id, p_mudur_ad, p_mudur_soyad, p_mudur_cinsiyet, 'default.jpg')
    RETURNING magazamuduruno INTO v_mudur_id;

    INSERT INTO magazasahibi (kisino, adi, soyadi, cinsiyet, profilfoto)
    VALUES (v_sahip_kisi_id, p_sahip_ad, p_sahip_soyad, p_sahip_cinsiyet, 'default.jpg')
    RETURNING magazasahibino INTO v_sahip_id;

    INSERT INTO magaza (adi, katno, magazamuduruno, magazasahibino)
    VALUES (p_magaza_adi, p_katno, v_mudur_id, v_sahip_id)
    RETURNING magazano INTO v_magaza_id;

    INSERT INTO urunler (adi, fiyat, stok)
    VALUES (p_urun_adi, p_urun_fiyat, p_stok)
    RETURNING urunno INTO v_urun_id;

    INSERT INTO magazaurun (magazano, urunno)
    VALUES (v_magaza_id, v_urun_id);

    INSERT INTO kisi (ad, soyad, cinsiyet, kisituru)
    VALUES (p_eleman_ad, p_eleman_soyad, p_eleman_cinsiyet, 'Eleman')
    RETURNING id INTO v_eleman_kisi_id;

    INSERT INTO magazaelemani (magazano, kisino, adi, soyadi, cinsiyet, profilfoto)
    VALUES (v_magaza_id, v_eleman_kisi_id, p_eleman_ad, p_eleman_soyad, p_eleman_cinsiyet, 'default.jpg');

    RAISE NOTICE 'Mağaza % (No: %) başarıyla açıldı. Müdür: %, Sahip: %', 
                 p_magaza_adi, v_magaza_id, p_mudur_ad, p_sahip_ad;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Mağaza ekleme işlemi başarısız oldu: %', SQLERRM;
END;
$$;


ALTER PROCEDURE public.spmagazaekle(IN p_magaza_adi text, IN p_katno integer, IN p_mudur_ad text, IN p_mudur_soyad text, IN p_mudur_cinsiyet character, IN p_sahip_ad text, IN p_sahip_soyad text, IN p_sahip_cinsiyet character, IN p_urun_adi text, IN p_urun_fiyat numeric, IN p_stok integer, IN p_eleman_ad text, IN p_eleman_soyad text, IN p_eleman_cinsiyet character) OWNER TO postgres;

--
-- Name: spmagazaekle_coklu(text, integer, text, text, text, text, numeric, numeric, text[], integer[], text[], text[]); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.spmagazaekle_coklu(IN p_magaza_adi text, IN p_katno integer, IN p_mudur_ad text, IN p_mudur_soyad text, IN p_sahip_ad text, IN p_sahip_soyad text, IN p_gelir_miktari numeric, IN p_gider_miktari numeric, IN p_urun_adlari text[], IN p_stoklar integer[], IN p_eleman_adlari text[], IN p_eleman_soyadlari text[])
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_magaza_id INT;
    v_mudur_kisi_id INT; v_sahip_kisi_id INT; v_eleman_kisi_id INT;
    v_mudur_id INT; v_sahip_id INT; v_urun_id INT;
    i INT;
BEGIN
    
    INSERT INTO kisi (ad, soyad, kisituru) VALUES (p_mudur_ad, p_mudur_soyad, 'Mağaza Müdürü') RETURNING id INTO v_mudur_kisi_id;
    INSERT INTO magazamuduru (kisino, adi, soyadi) VALUES (v_mudur_kisi_id, p_mudur_ad, p_mudur_soyad) RETURNING magazamuduruno INTO v_mudur_id;

    INSERT INTO kisi (ad, soyad, kisituru) VALUES (p_sahip_ad, p_sahip_soyad, 'Mağaza Sahibi') RETURNING id INTO v_sahip_kisi_id;
    INSERT INTO magazasahibi (kisino, adi, soyadi) VALUES (v_sahip_kisi_id, p_sahip_ad, p_sahip_soyad) RETURNING magazasahibino INTO v_sahip_id;

    INSERT INTO magaza (adi, katno, magazamuduruno, magazasahibino) VALUES (p_magaza_adi, p_katno, v_mudur_id, v_sahip_id) RETURNING magazano INTO v_magaza_id;

    IF p_gelir_miktari IS NOT NULL THEN
        INSERT INTO gelir (magazano, gelirmiktari) VALUES (v_magaza_id, p_gelir_miktari);
    END IF;

    IF p_gider_miktari IS NOT NULL THEN
        INSERT INTO gider (magazano, gidermiktari) VALUES (v_magaza_id, p_gider_miktari);
    END IF;

    FOR i IN 1..array_length(p_urun_adlari, 1) LOOP
        INSERT INTO urunler (adi,stok) VALUES (p_urun_adlari[i],p_stoklar[i]) RETURNING urunno INTO v_urun_id;
        INSERT INTO magazaurun (magazano, urunno) VALUES (v_magaza_id, v_urun_id);
    END LOOP;

    FOR i IN 1..array_length(p_eleman_adlari, 1) LOOP
        INSERT INTO kisi (ad, soyad, kisituru) VALUES (p_eleman_adlari[i], p_eleman_soyadlari[i], 'Mağaza Elemanı') RETURNING id INTO v_eleman_kisi_id;
        INSERT INTO magazaelemani (magazano, kisino, adi, soyadi) VALUES (v_magaza_id, v_eleman_kisi_id, p_eleman_adlari[i], p_eleman_soyadlari[i]);
    END LOOP;

    RAISE NOTICE 'Mağaza % oluşturuldu.', p_magaza_adi;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Hata oluştu: %', SQLERRM;
END;
$$;


ALTER PROCEDURE public.spmagazaekle_coklu(IN p_magaza_adi text, IN p_katno integer, IN p_mudur_ad text, IN p_mudur_soyad text, IN p_sahip_ad text, IN p_sahip_soyad text, IN p_gelir_miktari numeric, IN p_gider_miktari numeric, IN p_urun_adlari text[], IN p_stoklar integer[], IN p_eleman_adlari text[], IN p_eleman_soyadlari text[]) OWNER TO postgres;

--
-- Name: sptedarikciekle(text, text, text, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sptedarikciekle(IN p_ad text, IN p_soyad text, IN p_profil_foto text, IN p_secilen_magaza_no integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_kisi_id INT;
    v_tedarikci_id INT;
BEGIN
    INSERT INTO kisi (ad, soyad, kisituru) 
    VALUES (p_ad, p_soyad, 'Tedarikçi') 
    RETURNING id INTO v_kisi_id;

    INSERT INTO tedarikci (kisino, adi, soyadi, profilfoto) 
    VALUES (v_kisi_id, p_ad, p_soyad, p_profil_foto) 
    RETURNING tedarikcino INTO v_tedarikci_id;

    INSERT INTO magazatedarikci (magazano, tedarikcino)
    VALUES (p_secilen_magaza_no, v_tedarikci_id);

    RAISE NOTICE 'Tedarikçi % % eklendi.', p_ad, p_soyad;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Hata: %', SQLERRM;
END;
$$;


ALTER PROCEDURE public.sptedarikciekle(IN p_ad text, IN p_soyad text, IN p_profil_foto text, IN p_secilen_magaza_no integer) OWNER TO postgres;

--
-- Name: sptedarikcisil(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sptedarikcisil(IN p_tedarikci_no integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_kisi_id INT;
BEGIN
    SELECT kisino INTO v_kisi_id 
    FROM tedarikci 
    WHERE tedarikcino = p_tedarikci_no;

    IF v_kisi_id IS NULL THEN
        RAISE NOTICE 'Tedarikçi bulunamadı (ID: %)', p_tedarikci_no;
        RETURN;
    END IF;

    DELETE FROM magazatedarikci WHERE tedarikcino = p_tedarikci_no;

    DELETE FROM tedarikci WHERE tedarikcino = p_tedarikci_no;

    DELETE FROM kisi WHERE id = v_kisi_id;

    RAISE NOTICE 'Tedarikçi (No: %) ve Kişi kaydı (No: %) başarıyla silindi.', p_tedarikci_no, v_kisi_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Silme işlemi sırasında hata oluştu: %', SQLERRM;
END;
$$;


ALTER PROCEDURE public.sptedarikcisil(IN p_tedarikci_no integer) OWNER TO postgres;

--
-- Name: tedarikci_eklendi_kisi_ekle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.tedarikci_eklendi_kisi_ekle() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    yeni_id INT;
BEGIN
    INSERT INTO kisi (ad, soyad, kisituru)
    VALUES (NEW.adi, NEW.soyadi, 'Tedarikçi')
    RETURNING id INTO yeni_id;

    UPDATE tedarikci
    SET kisino = yeni_id
    WHERE tedarikcino = NEW.tedarikcino;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.tedarikci_eklendi_kisi_ekle() OWNER TO postgres;

--
-- Name: tedarikci_guncellendi_kisi_guncelle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.tedarikci_guncellendi_kisi_guncelle() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE kisi
    SET ad = NEW.adi,
        soyad = NEW.soyadi
    WHERE id = OLD.kisino; 

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.tedarikci_guncellendi_kisi_guncelle() OWNER TO postgres;

--
-- Name: trg_kontrol_kapasite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_kontrol_kapasite() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.otoparkkapasite < 50 OR NEW.otoparkkapasite > 500 THEN
        RAISE EXCEPTION 
            'Kapasite 50 ile 500 arasında olmalıdır (girilen: %).', NEW.otoparkkapasite;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_kontrol_kapasite() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: avm; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.avm (
    avmno integer NOT NULL,
    adi character varying(15) NOT NULL,
    avmyoneticisino integer NOT NULL
);


ALTER TABLE public.avm OWNER TO postgres;

--
-- Name: avm_avmno_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.avm_avmno_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.avm_avmno_seq OWNER TO postgres;

--
-- Name: avm_avmno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.avm_avmno_seq OWNED BY public.avm.avmno;


--
-- Name: avmyoneticisi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.avmyoneticisi (
    avmyoneticisino integer NOT NULL,
    adi character varying(15) NOT NULL,
    soyadi character varying(20) NOT NULL,
    kisino integer NOT NULL,
    profilfoto character varying(100)
);


ALTER TABLE public.avmyoneticisi OWNER TO postgres;

--
-- Name: avmyoneticisi_avmyoneticisino_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.avmyoneticisi_avmyoneticisino_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.avmyoneticisi_avmyoneticisino_seq OWNER TO postgres;

--
-- Name: avmyoneticisi_avmyoneticisino_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.avmyoneticisi_avmyoneticisino_seq OWNED BY public.avmyoneticisi.avmyoneticisino;


--
-- Name: eglencemerkezi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.eglencemerkezi (
    oyuncakno integer CONSTRAINT eglencemerkezi_eglencemerkezino_not_null NOT NULL,
    avmno integer NOT NULL,
    katno integer NOT NULL,
    eglencemerkezino integer CONSTRAINT eglencemerkezi_eglencemerkezino_not_null1 NOT NULL,
    oyuncaklar character varying NOT NULL
);


ALTER TABLE public.eglencemerkezi OWNER TO postgres;

--
-- Name: eglencemerkezi_eglencemerkezino_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.eglencemerkezi_eglencemerkezino_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.eglencemerkezi_eglencemerkezino_seq OWNER TO postgres;

--
-- Name: eglencemerkezi_eglencemerkezino_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.eglencemerkezi_eglencemerkezino_seq OWNED BY public.eglencemerkezi.oyuncakno;


--
-- Name: gelir; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gelir (
    gelirno integer NOT NULL,
    gelirmiktari integer NOT NULL,
    magazano integer NOT NULL
);


ALTER TABLE public.gelir OWNER TO postgres;

--
-- Name: gelir_gelirno_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.gelir_gelirno_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gelir_gelirno_seq OWNER TO postgres;

--
-- Name: gelir_gelirno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.gelir_gelirno_seq OWNED BY public.gelir.gelirno;


--
-- Name: gider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gider (
    giderno integer NOT NULL,
    gidermiktari integer NOT NULL,
    magazano integer NOT NULL
);


ALTER TABLE public.gider OWNER TO postgres;

--
-- Name: gider_giderno_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.gider_giderno_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gider_giderno_seq OWNER TO postgres;

--
-- Name: gider_giderno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.gider_giderno_seq OWNED BY public.gider.giderno;


--
-- Name: kat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kat (
    katno integer NOT NULL,
    avmno integer NOT NULL
);


ALTER TABLE public.kat OWNER TO postgres;

--
-- Name: kat_katno_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kat_katno_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kat_katno_seq OWNER TO postgres;

--
-- Name: kat_katno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kat_katno_seq OWNED BY public.kat.katno;


--
-- Name: kisi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kisi (
    id integer NOT NULL,
    ad character varying(15) NOT NULL,
    soyad character varying(20) NOT NULL,
    kisituru character varying(15) NOT NULL
);


ALTER TABLE public.kisi OWNER TO postgres;

--
-- Name: kisi_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kisi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kisi_id_seq OWNER TO postgres;

--
-- Name: kisi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kisi_id_seq OWNED BY public.kisi.id;


--
-- Name: magaza; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.magaza (
    magazano integer NOT NULL,
    adi character varying(20) NOT NULL,
    katno integer NOT NULL,
    magazamuduruno integer NOT NULL,
    magazasahibino integer NOT NULL
);


ALTER TABLE public.magaza OWNER TO postgres;

--
-- Name: magaza_magazano_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.magaza_magazano_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.magaza_magazano_seq OWNER TO postgres;

--
-- Name: magaza_magazano_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.magaza_magazano_seq OWNED BY public.magaza.magazano;


--
-- Name: magazaelemani; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.magazaelemani (
    magazaelemanno integer NOT NULL,
    adi character varying(15) NOT NULL,
    soyadi character varying(20) NOT NULL,
    magazano integer NOT NULL,
    kisino integer NOT NULL,
    profilfoto character varying(100)
);


ALTER TABLE public.magazaelemani OWNER TO postgres;

--
-- Name: magazaelemani_magazaelemanno_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.magazaelemani_magazaelemanno_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.magazaelemani_magazaelemanno_seq OWNER TO postgres;

--
-- Name: magazaelemani_magazaelemanno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.magazaelemani_magazaelemanno_seq OWNED BY public.magazaelemani.magazaelemanno;


--
-- Name: magazamuduru; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.magazamuduru (
    magazamuduruno integer NOT NULL,
    adi character varying(15),
    soyadi character varying(20),
    kisino integer NOT NULL,
    profilfoto character varying(100)
);


ALTER TABLE public.magazamuduru OWNER TO postgres;

--
-- Name: magazamuduru_magazamuduruno_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.magazamuduru_magazamuduruno_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.magazamuduru_magazamuduruno_seq OWNER TO postgres;

--
-- Name: magazamuduru_magazamuduruno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.magazamuduru_magazamuduruno_seq OWNED BY public.magazamuduru.magazamuduruno;


--
-- Name: magazamusteri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.magazamusteri (
    musterino integer NOT NULL,
    magazano integer NOT NULL
);


ALTER TABLE public.magazamusteri OWNER TO postgres;

--
-- Name: magazasahibi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.magazasahibi (
    magazasahibino integer NOT NULL,
    adi character varying(15),
    soyadi character varying(20),
    kisino integer NOT NULL,
    profilfoto character varying(100)
);


ALTER TABLE public.magazasahibi OWNER TO postgres;

--
-- Name: magazasahibi_magazasahibino_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.magazasahibi_magazasahibino_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.magazasahibi_magazasahibino_seq OWNER TO postgres;

--
-- Name: magazasahibi_magazasahibino_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.magazasahibi_magazasahibino_seq OWNED BY public.magazasahibi.magazasahibino;


--
-- Name: magazatedarikci; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.magazatedarikci (
    tedarikcino integer NOT NULL,
    magazano integer NOT NULL
);


ALTER TABLE public.magazatedarikci OWNER TO postgres;

--
-- Name: magazaurun; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.magazaurun (
    magazano integer NOT NULL,
    urunno integer NOT NULL
);


ALTER TABLE public.magazaurun OWNER TO postgres;

--
-- Name: musteri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.musteri (
    musterino integer NOT NULL,
    ad character varying(15),
    soyad character varying(20),
    kisino integer NOT NULL
);


ALTER TABLE public.musteri OWNER TO postgres;

--
-- Name: musteri_musterino_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.musteri_musterino_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.musteri_musterino_seq OWNER TO postgres;

--
-- Name: musteri_musterino_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.musteri_musterino_seq OWNED BY public.musteri.musterino;


--
-- Name: otopark; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.otopark (
    otoparkno integer NOT NULL,
    avmno integer,
    katno integer,
    otoparkkapasite integer
);


ALTER TABLE public.otopark OWNER TO postgres;

--
-- Name: otopark_otoparkno_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.otopark_otoparkno_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.otopark_otoparkno_seq OWNER TO postgres;

--
-- Name: otopark_otoparkno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.otopark_otoparkno_seq OWNED BY public.otopark.otoparkno;


--
-- Name: personel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personel (
    personelno integer NOT NULL,
    adi character varying(15),
    soyadi character varying(20),
    katno integer,
    kisino integer NOT NULL,
    profilfoto character varying(100)
);


ALTER TABLE public.personel OWNER TO postgres;

--
-- Name: personel_personelno_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personel_personelno_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personel_personelno_seq OWNER TO postgres;

--
-- Name: personel_personelno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personel_personelno_seq OWNED BY public.personel.personelno;


--
-- Name: tedarikci; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tedarikci (
    tedarikcino integer CONSTRAINT tedarikci_id_not_null NOT NULL,
    adi character varying(15),
    soyadi character varying(20),
    kisino integer NOT NULL,
    profilfoto character varying(100)
);


ALTER TABLE public.tedarikci OWNER TO postgres;

--
-- Name: tedarikci_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tedarikci_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tedarikci_id_seq OWNER TO postgres;

--
-- Name: tedarikci_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tedarikci_id_seq OWNED BY public.tedarikci.tedarikcino;


--
-- Name: urunler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.urunler (
    urunno integer NOT NULL,
    adi character varying(15),
    fiyat integer,
    stok integer
);


ALTER TABLE public.urunler OWNER TO postgres;

--
-- Name: urunler_urunno_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.urunler_urunno_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.urunler_urunno_seq OWNER TO postgres;

--
-- Name: urunler_urunno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.urunler_urunno_seq OWNED BY public.urunler.urunno;


--
-- Name: avm avmno; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avm ALTER COLUMN avmno SET DEFAULT nextval('public.avm_avmno_seq'::regclass);


--
-- Name: avmyoneticisi avmyoneticisino; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avmyoneticisi ALTER COLUMN avmyoneticisino SET DEFAULT nextval('public.avmyoneticisi_avmyoneticisino_seq'::regclass);


--
-- Name: eglencemerkezi oyuncakno; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eglencemerkezi ALTER COLUMN oyuncakno SET DEFAULT nextval('public.eglencemerkezi_eglencemerkezino_seq'::regclass);


--
-- Name: gelir gelirno; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gelir ALTER COLUMN gelirno SET DEFAULT nextval('public.gelir_gelirno_seq'::regclass);


--
-- Name: gider giderno; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gider ALTER COLUMN giderno SET DEFAULT nextval('public.gider_giderno_seq'::regclass);


--
-- Name: kat katno; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kat ALTER COLUMN katno SET DEFAULT nextval('public.kat_katno_seq'::regclass);


--
-- Name: kisi id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kisi ALTER COLUMN id SET DEFAULT nextval('public.kisi_id_seq'::regclass);


--
-- Name: magaza magazano; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magaza ALTER COLUMN magazano SET DEFAULT nextval('public.magaza_magazano_seq'::regclass);


--
-- Name: magazaelemani magazaelemanno; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazaelemani ALTER COLUMN magazaelemanno SET DEFAULT nextval('public.magazaelemani_magazaelemanno_seq'::regclass);


--
-- Name: magazamuduru magazamuduruno; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazamuduru ALTER COLUMN magazamuduruno SET DEFAULT nextval('public.magazamuduru_magazamuduruno_seq'::regclass);


--
-- Name: magazasahibi magazasahibino; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazasahibi ALTER COLUMN magazasahibino SET DEFAULT nextval('public.magazasahibi_magazasahibino_seq'::regclass);


--
-- Name: musteri musterino; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri ALTER COLUMN musterino SET DEFAULT nextval('public.musteri_musterino_seq'::regclass);


--
-- Name: otopark otoparkno; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otopark ALTER COLUMN otoparkno SET DEFAULT nextval('public.otopark_otoparkno_seq'::regclass);


--
-- Name: personel personelno; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel ALTER COLUMN personelno SET DEFAULT nextval('public.personel_personelno_seq'::regclass);


--
-- Name: tedarikci tedarikcino; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tedarikci ALTER COLUMN tedarikcino SET DEFAULT nextval('public.tedarikci_id_seq'::regclass);


--
-- Name: urunler urunno; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urunler ALTER COLUMN urunno SET DEFAULT nextval('public.urunler_urunno_seq'::regclass);


--
-- Data for Name: avm; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.avm VALUES
	(1, 'BPM', 1);


--
-- Data for Name: avmyoneticisi; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.avmyoneticisi VALUES
	(1, 'Ismali', 'Öztel', 1, '4365c51d-5d0c-4615-beee-289d0d2951f2.jpg');


--
-- Data for Name: eglencemerkezi; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.eglencemerkezi VALUES
	(2, 1, 2, 1, 'Roller Coaster'),
	(3, 1, 2, 1, 'Gondol'),
	(5, 1, 2, 1, 'Korku Tüneli'),
	(6, 1, 2, 1, 'Langırt'),
	(7, 1, 2, 1, 'Bowling'),
	(9, 1, 2, 1, 'Crazy Dance'),
	(10, 1, 2, 1, 'Salıncak'),
	(11, 1, 2, 1, 'Çarpışan Araba'),
	(4, 1, 2, 1, 'Atlı Karınca');


--
-- Data for Name: gelir; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.gelir VALUES
	(3, 65151515, 3),
	(4, 51115515, 4),
	(5, 15156151, 5),
	(6, 15155200, 6),
	(7, 1234567, 7),
	(8, 7987654, 8),
	(9, 1472583, 9),
	(10, 2589632, 10),
	(11, 1515115, 11),
	(13, 1511321, 13),
	(14, 8785415, 14),
	(2, 23215520, 2),
	(1, 99998520, 1);


--
-- Data for Name: gider; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.gider VALUES
	(2, 215515, 2),
	(3, 151515, 3),
	(4, 115515, 4),
	(5, 156151, 5),
	(6, 155200, 6),
	(7, 34567, 7),
	(8, 87654, 8),
	(9, 72583, 9),
	(10, 89632, 10),
	(11, 1515115, 11),
	(13, 511321, 13),
	(14, 85415, 14),
	(1, 998520, 1);


--
-- Data for Name: kat; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.kat VALUES
	(-2, 1),
	(-1, 1),
	(0, 1),
	(1, 1),
	(2, 1);


--
-- Data for Name: kisi; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.kisi VALUES
	(420, 'ali', 'burger', 'Mağaza Elemanı'),
	(93, 'Eren', 'Polat', 'Mağaza Elemanı'),
	(94, 'Miray', 'Kurt', 'Mağaza Elemanı'),
	(95, 'Arçın', 'Demiralp', 'Mağaza Elemanı'),
	(96, 'Yaren', 'Koç', 'Mağaza Elemanı'),
	(97, 'Emir', 'Tutar', 'Mağaza Elemanı'),
	(98, 'Sare', 'Ergün', 'Mağaza Elemanı'),
	(99, 'Anıl', 'Karakuş', 'Mağaza Elemanı'),
	(100, 'Defne', 'Mersoy', 'Mağaza Elemanı'),
	(101, 'Poyraz', 'Tanrıverdi', 'Mağaza Elemanı'),
	(657, 'Emir', 'Uzun', 'Personel'),
	(1, 'Ismail', 'Öztel', 'Avm Yöneticisi'),
	(2, 'Mira', 'Kara', 'Mağaza Müdürü'),
	(3, 'Caner', 'Kılıç', 'Mağaza Müdürü'),
	(4, 'Elvan', 'Tunç', 'Mağaza Müdürü'),
	(5, 'Yiğit', 'Özdemir', 'Mağaza Müdürü'),
	(6, 'Duru', 'Sancak', 'Mağaza Müdürü'),
	(7, 'Alper', 'Yüzün', 'Mağaza Müdürü'),
	(8, 'Irem', 'Kaya', 'Mağaza Müdürü'),
	(9, 'Ozan', 'Erol', 'Mağaza Müdürü'),
	(10, 'Beren', 'Sarı', 'Mağaza Müdürü'),
	(11, 'Tolga', 'Yüce', 'Mağaza Müdürü'),
	(12, 'Ayşe', 'Demirci', 'Mağaza Müdürü'),
	(14, 'Melike', 'Baran', 'Mağaza Müdürü'),
	(15, 'Ömer', 'Akbaş', 'Mağaza Müdürü'),
	(16, 'Nazlı', 'Gül', 'Mağaza Müdürü'),
	(17, 'Rüveyda', 'Arslan', 'Mağaza Sahibi'),
	(18, 'Elif Sena', 'Sönmez', 'Mağaza Sahibi'),
	(19, 'Rümeysa', 'Ceran', 'Mağaza Sahibi'),
	(20, 'Mert', 'Özkaya', 'Mağaza Sahibi'),
	(21, 'Zeynep', 'Gür', 'Mağaza Sahibi'),
	(22, 'Arda', 'Taş', 'Mağaza Sahibi'),
	(23, 'Defne', 'Koç', 'Mağaza Sahibi'),
	(24, 'Batu', 'Yüce', 'Mağaza Sahibi'),
	(25, 'Asya', 'Tunç', 'Mağaza Sahibi'),
	(26, 'Umut', 'Yılmaz', 'Mağaza Sahibi'),
	(27, 'Sude', 'Acar', 'Mağaza Sahibi'),
	(29, 'Mira', 'Yıldırım', 'Mağaza Sahibi'),
	(30, 'Burak', 'Top', 'Mağaza Sahibi'),
	(31, 'Azra', 'Sezer', 'Mağaza Sahibi'),
	(108, 'Esila', 'Demir', 'Tedarikçi'),
	(109, 'Doruk', 'Erkan', 'Tedarikçi'),
	(110, 'Nehir', 'Alkan', 'Tedarikçi'),
	(33, 'Ceren', 'Soylu', 'Mağaza Elemanı'),
	(34, 'Tunç', 'Erdemir', 'Mağaza Elemanı'),
	(37, 'Nehir', 'Akgör', 'Mağaza Elemanı'),
	(38, 'Tamer', 'Gürkan', 'Mağaza Elemanı'),
	(39, 'Serra', 'Ilbey', 'Mağaza Elemanı'),
	(40, 'Oğuz', 'Erel', 'Mağaza Elemanı'),
	(41, 'Lina', 'Gürsoy', 'Mağaza Elemanı'),
	(42, 'Eray', 'Akpınar', 'Mağaza Elemanı'),
	(43, 'Miraç', 'Yalman', 'Mağaza Elemanı'),
	(44, 'Asya', 'Durukan', 'Mağaza Elemanı'),
	(45, 'Yiğit', 'Karabey', 'Mağaza Elemanı'),
	(46, 'Alara', 'Sungur', 'Mağaza Elemanı'),
	(48, 'Beste', 'Oral', 'Mağaza Elemanı'),
	(49, 'Emirhan', 'Narlı', 'Mağaza Elemanı'),
	(50, 'Su', 'Aral', 'Mağaza Elemanı'),
	(51, 'Doruk', 'Kalkan', 'Mağaza Elemanı'),
	(52, 'Bade', 'Yüce', 'Mağaza Elemanı'),
	(53, 'Kayra', 'Önder', 'Mağaza Elemanı'),
	(54, 'Idil', 'Köseoğlu', 'Mağaza Elemanı'),
	(55, 'Alp', 'Güvercin', 'Mağaza Elemanı'),
	(56, 'Melodi', 'Aktaş', 'Mağaza Elemanı'),
	(57, 'Arın', 'Yalman', 'Mağaza Elemanı'),
	(58, 'Deren', 'Baltacı', 'Mağaza Elemanı'),
	(59, 'Onur', 'Türen', 'Mağaza Elemanı'),
	(60, 'Misa', 'Gürbüz', 'Mağaza Elemanı'),
	(61, 'Batu', 'Eren', 'Mağaza Elemanı'),
	(62, 'Selinay', 'Koru', 'Mağaza Elemanı'),
	(63, 'Tan', 'Arslanbay', 'Mağaza Elemanı'),
	(64, 'Kayra', 'Özçelik', 'Mağaza Elemanı'),
	(65, 'Tuana', 'Serengil', 'Mağaza Elemanı'),
	(67, 'Ada', 'Şenel', 'Mağaza Elemanı'),
	(68, 'Kuzey', 'Taşkent', 'Mağaza Elemanı'),
	(69, 'Mavi', 'Hoşafçı', 'Mağaza Elemanı'),
	(70, 'Ela', 'Uzun', 'Mağaza Elemanı'),
	(71, 'Aras', 'Tunçay', 'Mağaza Elemanı'),
	(72, 'Şimay', 'Tokgöz', 'Mağaza Elemanı'),
	(73, 'Emircan', 'Çetin', 'Mağaza Elemanı'),
	(74, 'Nisa', 'Güner', 'Mağaza Elemanı'),
	(75, 'Kerim', 'Solmaz', 'Mağaza Elemanı'),
	(76, 'Alin', 'Karadayı', 'Mağaza Elemanı'),
	(77, 'Metehan', 'Sönmez', 'Mağaza Elemanı'),
	(78, 'Melina', 'Kocaboş', 'Mağaza Elemanı'),
	(79, 'Remzi', 'Kural', 'Mağaza Elemanı'),
	(80, 'Eylül', 'Baydar', 'Mağaza Elemanı'),
	(81, 'Ayberk', 'Şenkal', 'Mağaza Elemanı'),
	(82, 'Yağmur', 'Selek', 'Mağaza Elemanı'),
	(83, 'Mahir', 'Bulur', 'Mağaza Elemanı'),
	(84, 'Liva', 'Tanju', 'Mağaza Elemanı'),
	(85, 'Atlas', 'Günal', 'Mağaza Elemanı'),
	(92, 'Lal', 'Şahin', 'Mağaza Elemanı'),
	(113, 'Tan', 'Cem', 'Tedarikçi'),
	(114, 'Beren', 'Ata', 'Tedarikçi'),
	(115, 'Kaan', 'Önal', 'Tedarikçi'),
	(116, 'Yaren', 'Öztürk', 'Tedarikçi'),
	(120, 'Mert', 'Aksoy', 'Personel'),
	(121, 'Selin', 'Demir', 'Personel'),
	(653, 'lllllllll', '', 'Personel'),
	(125, 'Emre', 'Acar', 'Personel'),
	(126, 'Derya', 'Çetin', 'Personel'),
	(127, 'Melis', 'Bulut', 'Personel'),
	(129, 'Ece', 'Karaca', 'Personel'),
	(147, 'Zeynep', 'Taş', 'Müşteri'),
	(149, 'Idil', 'Önal', 'Müşteri'),
	(150, 'Rüzgar', 'Uçar', 'Müşteri'),
	(151, 'Ceren', 'Altun', 'Müşteri'),
	(152, 'Hakan', 'Demirtaş', 'Müşteri'),
	(153, 'Sude', 'Aksoy', 'Müşteri'),
	(154, 'Alp', 'Arslan', 'Müşteri'),
	(155, 'Liva', 'Tekli', 'Müşteri'),
	(156, 'Taner', 'Güner', 'Müşteri'),
	(157, 'Beste', 'Acar', 'Müşteri'),
	(158, 'Onur', 'Baran', 'Müşteri'),
	(159, 'Dilara', 'Gür', 'Müşteri'),
	(160, 'Selin', 'Erdem', 'Müşteri'),
	(658, 'tan', 'pul', 'Müşteri'),
	(112, 'Cereniii', 'Yurt', 'Tedarikçi'),
	(32, 'Aylaaaa', 'Tekin', 'Mağaza Elemanı'),
	(162, 'Aras', 'Demir', 'Müşteri'),
	(47, 'Efe', 'Çakırhan', 'Mağaza Elemanı'),
	(66, 'Barın', 'Çeltik', 'Mağaza Elemanı'),
	(86, 'Ipek', 'Mersin', 'Mağaza Elemanı');


--
-- Data for Name: magaza; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.magaza VALUES
	(1, 'FLO', 0, 1, 1),
	(2, 'H&M', 0, 2, 2),
	(3, 'BEYMEN', 0, 3, 3),
	(4, 'DEFACTO', 0, 4, 4),
	(5, 'LCW', 0, 5, 5),
	(6, 'ATASUN OPTİK', 1, 6, 6),
	(7, 'GRATİS', 1, 7, 7),
	(8, 'TEKNOSA', 1, 8, 8),
	(9, 'MEDİA MARKT', 1, 9, 9),
	(10, 'TURKCELL', 1, 10, 10),
	(13, 'TOYZZ SHOP', 2, 13, 13),
	(14, 'WAFFLE TOWN', 2, 14, 14),
	(15, 'BURGER AKADEMİ', 2, 15, 15),
	(11, 'MIGROSIII', 2, 11, 11);


--
-- Data for Name: magazaelemani; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.magazaelemani VALUES
	(2, 'Ceren', 'Soylu', 1, 33, '64.jpg'),
	(3, 'Tunç', 'Erdemir', 1, 34, '65.jpg'),
	(6, 'Nehir', 'Akgör', 2, 37, '66.jpg'),
	(8, 'Serra', 'Ilbey', 2, 39, '67.jpg'),
	(10, 'Lina', 'Gürsoy', 2, 41, '68.jpg'),
	(12, 'Miraç', 'Yalman', 3, 43, '69.jpg'),
	(13, 'Asya', 'Durukan', 3, 44, '70.jpg'),
	(15, 'Alara', 'Sungur', 3, 46, '71.jpg'),
	(17, 'Beste', 'Oral', 4, 48, '72.jpg'),
	(19, 'Su', 'Aral', 4, 50, '73.jpg'),
	(21, 'Bade', 'Yüce', 5, 52, '74.jpg'),
	(23, 'Idil', 'Köseoğlu', 5, 54, '75.jpg'),
	(25, 'Melodi', 'Aktaş', 5, 56, '76.jpg'),
	(27, 'Deren', 'Baltacı', 6, 58, '77.jpg'),
	(29, 'Misa', 'Gürbüz', 6, 60, '78.jpg'),
	(31, 'Selinay', 'Koru', 7, 62, '79.jpg'),
	(34, 'Tuana', 'Serengil', 7, 65, '80.jpg'),
	(36, 'Ada', 'Şenel', 8, 67, '81.jpg'),
	(38, 'Mavi', 'Hoşafçı', 8, 69, '82.jpg'),
	(39, 'Ela', 'Uzun', 8, 70, '83.jpg'),
	(41, 'Şimay', 'Tokgöz', 9, 72, '84.jpg'),
	(43, 'Nisa', 'Güner', 9, 74, '85.jpg'),
	(45, 'Alin', 'Karadayı', 9, 76, '86.jpg'),
	(47, 'Melina', 'Kocaboş', 10, 78, '87.jpg'),
	(49, 'Eylül', 'Baydar', 10, 80, '88.jpg'),
	(51, 'Yağmur', 'Selek', 11, 82, '89.jpg'),
	(53, 'Liva', 'Tanju', 11, 84, '90.jpg'),
	(55, 'Ipek', 'Mersin', 11, 86, '91.jpg'),
	(61, 'Lal', 'Şahin', 13, 92, '95.jpg'),
	(63, 'Miray', 'Kurt', 13, 94, '96.jpg'),
	(65, 'Yaren', 'Koç', 13, 96, '97.jpg'),
	(67, 'Sare', 'Ergün', 14, 98, '98.jpg'),
	(69, 'Defne', 'Mersoy', 14, 100, '99.jpg'),
	(71, 'ali', 'hamburger', 15, 420, '36.jpg'),
	(1, 'Aylaaaa', 'Tekin', 2, 32, '63.jpg'),
	(7, 'Tamer', 'Gürkan', 2, 38, '5.jpg'),
	(9, 'Oğuz', 'Erel', 2, 40, '6.jpg'),
	(11, 'Eray', 'Akpınar', 3, 42, '7.jpg'),
	(14, 'Yiğit', 'Karabey', 3, 45, '8.jpg'),
	(16, 'Efe', 'Çakırhan', 4, 47, '9.jpg'),
	(18, 'Emirhan', 'Narlı', 4, 49, '10.jpg'),
	(20, 'Doruk', 'Kalkan', 4, 51, '11.jpg'),
	(22, 'Kayra', 'Önder', 5, 53, '12.jpg'),
	(24, 'Alp', 'Güvercin', 5, 55, '13.jpg'),
	(26, 'Arın', 'Yalman', 6, 57, '14.jpg'),
	(28, 'Onur', 'Türen', 6, 59, '15.jpg'),
	(30, 'Batu', 'Eren', 6, 61, '16.jpg'),
	(32, 'Tan', 'Arslanbay', 7, 63, '17.jpg'),
	(33, 'Kayra', 'Özçelik', 7, 64, '18.jpg'),
	(35, 'Barın', 'Çeltik', 7, 66, '19.jpg'),
	(37, 'Kuzey', 'Taşkent', 8, 68, '20.jpg'),
	(40, 'Aras', 'Tunçay', 8, 71, '21.jpg'),
	(42, 'Emircan', 'Çetin', 9, 73, '22.jpg'),
	(44, 'Kerim', 'Solmaz', 9, 75, '23.jpg'),
	(46, 'Metehan', 'Sönmez', 10, 77, '24.jpg'),
	(48, 'Remzi', 'Kural', 10, 79, '25.jpg'),
	(50, 'Ayberk', 'Şenkal', 10, 81, '26.jpg'),
	(52, 'Mahir', 'Bulur', 11, 83, '27.jpg'),
	(54, 'Atlas', 'Günal', 11, 85, '28.jpg'),
	(62, 'Eren', 'Polat', 13, 93, '31.jpg'),
	(64, 'Arçın', 'Demiralp', 13, 95, '32.jpg'),
	(66, 'Emir', 'Tutar', 14, 97, '33.jpg'),
	(68, 'Anıl', 'Karakuş', 14, 99, '34.jpg'),
	(70, 'Poyraz', 'Tanrıverdi', 14, 101, '35.jpg');


--
-- Data for Name: magazamuduru; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.magazamuduru VALUES
	(10, 'Tolga', 'Yüce', 11, '41.jpg'),
	(14, 'Ömer', 'Akbaş', 15, '43.jpg'),
	(1, 'Mira', 'Kara', 2, '104.jpg'),
	(3, 'Elvan', 'Tunç', 4, '105.jpg'),
	(5, 'Duru', 'Sancak', 6, '106.jpg'),
	(7, 'Irem', 'Kaya', 8, '107.jpg'),
	(9, 'Beren', 'Sarı', 10, '108.jpg'),
	(11, 'Ayşe', 'Demirci', 12, '109.jpg'),
	(13, 'Melike', 'Baran', 14, '110.jpg'),
	(15, 'Nazlı', 'Güle', 16, '111.jpg'),
	(6, 'Alperiii', 'Yüzün', 7, '39.jpg'),
	(4, 'halit', 'Kaplan', 5, 'cc83d171-69ec-4755-8cd2-002d60519e66.jpg'),
	(2, 'Caner', 'Öztel', 3, '37.jpg'),
	(8, 'Ozaniii', 'Erolii', 9, '40.jpg');


--
-- Data for Name: magazamusteri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.magazamusteri VALUES
	(19, 8),
	(29, 10),
	(23, 9),
	(30, 10),
	(20, 2),
	(24, 9),
	(21, 4),
	(28, 9),
	(22, 9),
	(20, 9),
	(19, 9),
	(18, 3),
	(26, 10),
	(25, 9),
	(19, 1),
	(26, 9),
	(27, 9),
	(29, 9),
	(18, 9),
	(22, 5),
	(30, 9),
	(21, 9),
	(33, 4);


--
-- Data for Name: magazasahibi; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.magazasahibi VALUES
	(4, 'Mert', 'Özkaya', 20, '44.jpg'),
	(6, 'Arda', 'Taş', 22, '45.jpg'),
	(14, 'Burak', 'Top', 30, '49.jpg'),
	(2, 'Elif Sena', 'Sönmez', 18, '113.jpg'),
	(3, 'Rümeysa', 'Ceran', 19, '114.jpg'),
	(7, 'Defne', 'Koç', 23, '116.jpg'),
	(8, 'Batu', 'Yüce', 24, '46.jpg'),
	(10, 'Umut', 'Yılmaz', 26, '47.jpg'),
	(9, 'Asya', 'Tunç', 25, '117.jpg'),
	(11, 'Sude', 'Acar', 27, '118.jpg'),
	(13, 'Mira', 'Yıldırım', 29, '119.jpg'),
	(15, 'Azra', 'Sezer', 31, '120.jpg'),
	(1, 'Rüveyda', 'Arslan', 17, '112.jpg'),
	(5, 'Zeynep', 'Gür', 21, '2b4bad8e-a128-48ca-b360-a66f349f21ce.jpg');


--
-- Data for Name: magazatedarikci; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.magazatedarikci VALUES
	(6, 2),
	(4, 3),
	(3, 6),
	(10, 7),
	(6, 8),
	(10, 9),
	(10, 10),
	(8, 11),
	(4, 13),
	(9, 14),
	(9, 15),
	(3, 4);


--
-- Data for Name: magazaurun; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.magazaurun VALUES
	(1, 5),
	(1, 4),
	(1, 3),
	(1, 2),
	(1, 1),
	(2, 10),
	(2, 9),
	(2, 8),
	(2, 7),
	(2, 6),
	(3, 15),
	(3, 14),
	(3, 13),
	(3, 12),
	(3, 11),
	(4, 20),
	(4, 19),
	(4, 18),
	(4, 17),
	(4, 16),
	(5, 25),
	(5, 24),
	(5, 23),
	(5, 22),
	(5, 21),
	(6, 30),
	(6, 29),
	(6, 28),
	(6, 27),
	(6, 26),
	(7, 35),
	(7, 34),
	(7, 33),
	(7, 32),
	(7, 31),
	(8, 40),
	(8, 39),
	(8, 38),
	(8, 37),
	(8, 36),
	(9, 45),
	(9, 44),
	(9, 43),
	(9, 42),
	(9, 41),
	(10, 50),
	(10, 49),
	(10, 48),
	(10, 47),
	(10, 46),
	(11, 55),
	(11, 54),
	(11, 53),
	(11, 52),
	(11, 51),
	(13, 65),
	(13, 64),
	(13, 63),
	(13, 62),
	(13, 61),
	(14, 70),
	(14, 69),
	(14, 68),
	(14, 67),
	(14, 66),
	(15, 75),
	(15, 74),
	(15, 73),
	(15, 72),
	(15, 71);


--
-- Data for Name: musteri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.musteri VALUES
	(33, 'tan', 'pul', 658),
	(18, 'Idıl', 'Önal', 149),
	(19, 'Rüzgar', 'Uçar', 150),
	(20, 'Ceren', 'Altun', 151),
	(21, 'Hakan', 'Demirtaş', 152),
	(22, 'Sude', 'Aksoy', 153),
	(23, 'Alp', 'Arslan', 154),
	(24, 'Liva', 'Tekli', 155),
	(25, 'Taner', 'Güner', 156),
	(26, 'Beste', 'Acar', 157),
	(27, 'Onur', 'Baran', 158),
	(28, 'Dilara', 'Gür', 159),
	(29, 'Selin', 'Erdem', 160),
	(30, 'Aras', 'Demir', 162);


--
-- Data for Name: otopark; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.otopark VALUES
	(3, 1, -1, 50),
	(4, 1, -2, 50);


--
-- Data for Name: personel; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.personel VALUES
	(5, 'Selin', 'Demir', 2, 121, '121.jpg'),
	(10, 'Derya', 'Çetin', 1, 126, '122.jpg'),
	(11, 'Melis', 'Bulut', 2, 127, '123.jpg'),
	(13, 'Ece', 'Karaca', 1, 129, '124.jpg'),
	(14, 'lllllllll', '', 2, 653, '87c4795f-00c7-49e1-bd9a-f898f1470649.jpg'),
	(4, 'Mert', 'Aksoyii', 1, 120, '52.jpg'),
	(17, 'Emir', 'Uzun', 0, 657, '2613f1d2-9df6-4b58-890f-feda9b0346d3.jpg'),
	(9, 'Emre', 'Acer', 1, 125, '53.jpg');


--
-- Data for Name: tedarikci; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tedarikci VALUES
	(3, 'Dorukkkii', 'Erkan', 109, '59.jpg'),
	(6, 'Cereniii', 'Yurt', 112, '130.jpg'),
	(7, 'Tan', 'Cem', 113, '61.jpg'),
	(9, 'Kaan', 'Önal', 115, '62.jpg'),
	(2, 'Esila', 'Demir', 108, '128.jpg'),
	(4, 'Nehir', 'Alkan', 110, '129.jpg'),
	(8, 'Beren', 'Ata', 114, '131.jpg'),
	(10, 'Yaren', 'Öztürk', 116, '132.jpg');


--
-- Data for Name: urunler; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.urunler VALUES
	(6, 'Ceket', 2499, 10),
	(7, 'Kazak', 1499, 20),
	(8, 'Sweatshirt', 899, 40),
	(9, 'Kaban', 3499, 30),
	(10, 'Gömlek', 1299, 45),
	(11, 'Deri Ceket', 2199, 28),
	(12, 'Hırka', 799, 57),
	(13, 'Triko', 1299, 43),
	(14, 'Mont', 2999, 32),
	(15, 'Blazer Ceket', 5999, 26),
	(16, 'Jean', 1299, 48),
	(17, 'Kürk', 1499, 12),
	(18, 'Pantalon', 699, 13),
	(19, 'Kemer', 299, 87),
	(20, 'Şapka', 199, 59),
	(21, 'Çorap', 99, 120),
	(22, 'Pijama Takımı', 599, 59),
	(23, 'Eşofman Takımı', 999, 59),
	(24, 'Çanta', 699, 78),
	(25, 'Kravat', 299, 42),
	(26, 'Güneş Gözlüğü', 5999, 24),
	(27, 'Lens', 4999, 21),
	(28, 'Gözlük Kılıfı', 199, 45),
	(63, 'Lego', 3999, 111),
	(29, 'Bakım Seti', 299, 89),
	(30, 'Gözlük Ipi', 99, 36),
	(31, 'Kapatıcı', 159, 99),
	(32, 'El Kremi', 59, 120),
	(33, 'Ruj', 399, 100),
	(34, 'Şampuan', 179, 200),
	(35, 'Sabun', 49, 400),
	(36, 'Mouse', 299, 80),
	(37, 'Klavye', 899, 45),
	(39, 'Powerbank', 1299, 59),
	(40, 'Kulaklık', 1599, 62),
	(41, 'Flash Bellek', 399, 87),
	(42, 'Fırın', 13999, 26),
	(43, 'Kahve Makinesi', 34999, 14),
	(44, 'Televizyon', 44999, 12),
	(45, 'Süpürge', 12999, 17),
	(46, 'Telefon', 33999, 19),
	(64, 'Barbie', 1299, 100),
	(47, 'Tablet', 19999, 25),
	(48, 'Kılıf', 299, 45),
	(49, 'Laptop', 49999, 21),
	(50, 'SIM Kart', 159, 78),
	(51, 'Çikolata', 29, 588),
	(52, 'Dondurma', 49, 421),
	(53, 'Peçete', 129, 453),
	(54, 'Yumuşatıcı', 199, 145),
	(55, 'Çiçek', 89, 46),
	(56, 'Yastık', 399, 49),
	(57, 'Nevresim', 699, 78),
	(58, 'Yorgan', 599, 48),
	(59, 'Battaniye', 499, 32),
	(60, 'Havlu', 199, 87),
	(61, 'Puzzle', 2999, 159),
	(62, 'Satranç', 899, 147),
	(65, 'Peluş', 1199, 178),
	(66, 'Waffle', 299, 466),
	(67, 'Kahve', 199, 788),
	(68, 'Çay', 30, 999),
	(69, 'Kruvasan', 399, 411),
	(70, 'Cupp', 149, 321),
	(71, 'Hamburger', 199, 185),
	(72, 'Cheeseburger', 149, 142),
	(73, 'Kanat', 119, 189),
	(74, 'Şnitzel', 99, 288),
	(75, 'Kola', 49, 753),
	(38, 'Şarj Aleti', 499, 88),
	(1, 'Spor Ayakkabı', 1999, 1000),
	(2, 'Kadın Bot', 3299, 1200),
	(3, 'Erkek Bot', 2199, 1200),
	(4, 'Sneaker', 2599, 80),
	(5, 'Terlik', 499, 50);


--
-- Name: avm_avmno_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.avm_avmno_seq', 3, true);


--
-- Name: avmyoneticisi_avmyoneticisino_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.avmyoneticisi_avmyoneticisino_seq', 9, true);


--
-- Name: eglencemerkezi_eglencemerkezino_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.eglencemerkezi_eglencemerkezino_seq', 33, true);


--
-- Name: gelir_gelirno_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.gelir_gelirno_seq', 17, true);


--
-- Name: gider_giderno_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.gider_giderno_seq', 17, true);


--
-- Name: kat_katno_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kat_katno_seq', 1, true);


--
-- Name: kisi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kisi_id_seq', 658, true);


--
-- Name: magaza_magazano_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.magaza_magazano_seq', 17, true);


--
-- Name: magazaelemani_magazaelemanno_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.magazaelemani_magazaelemanno_seq', 204, true);


--
-- Name: magazamuduru_magazamuduruno_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.magazamuduru_magazamuduruno_seq', 20, true);


--
-- Name: magazasahibi_magazasahibino_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.magazasahibi_magazasahibino_seq', 17, true);


--
-- Name: musteri_musterino_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.musteri_musterino_seq', 33, true);


--
-- Name: otopark_otoparkno_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.otopark_otoparkno_seq', 4, true);


--
-- Name: personel_personelno_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personel_personelno_seq', 22, true);


--
-- Name: tedarikci_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tedarikci_id_seq', 119, true);


--
-- Name: urunler_urunno_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.urunler_urunno_seq', 85, true);


--
-- Name: avm avm_adi_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avm
    ADD CONSTRAINT avm_adi_key UNIQUE (adi);


--
-- Name: avm avm_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avm
    ADD CONSTRAINT avm_pkey PRIMARY KEY (avmno);


--
-- Name: avmyoneticisi avmyoneticisi_adi_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avmyoneticisi
    ADD CONSTRAINT avmyoneticisi_adi_key UNIQUE (adi);


--
-- Name: avmyoneticisi avmyoneticisi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avmyoneticisi
    ADD CONSTRAINT avmyoneticisi_pkey PRIMARY KEY (avmyoneticisino);


--
-- Name: eglencemerkezi eglencemerkezi_oyuncaklar_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eglencemerkezi
    ADD CONSTRAINT eglencemerkezi_oyuncaklar_key UNIQUE (oyuncaklar);


--
-- Name: eglencemerkezi eglencemerkezi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eglencemerkezi
    ADD CONSTRAINT eglencemerkezi_pkey PRIMARY KEY (oyuncakno);


--
-- Name: gelir gelir_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gelir
    ADD CONSTRAINT gelir_pkey PRIMARY KEY (gelirno);


--
-- Name: gider gider_magazano_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gider
    ADD CONSTRAINT gider_magazano_key UNIQUE (magazano);


--
-- Name: gider gider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gider
    ADD CONSTRAINT gider_pkey PRIMARY KEY (giderno);


--
-- Name: kat kat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kat
    ADD CONSTRAINT kat_pkey PRIMARY KEY (katno);


--
-- Name: kisi kisi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kisi
    ADD CONSTRAINT kisi_pkey PRIMARY KEY (id);


--
-- Name: magaza magaza_adi_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magaza
    ADD CONSTRAINT magaza_adi_key UNIQUE (adi);


--
-- Name: magaza magaza_magazamuduruno_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magaza
    ADD CONSTRAINT magaza_magazamuduruno_key UNIQUE (magazamuduruno);


--
-- Name: magaza magaza_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magaza
    ADD CONSTRAINT magaza_pkey PRIMARY KEY (magazano);


--
-- Name: magazaelemani magazaelemani_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazaelemani
    ADD CONSTRAINT magazaelemani_pkey PRIMARY KEY (magazaelemanno);


--
-- Name: magazamuduru magazamuduru_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazamuduru
    ADD CONSTRAINT magazamuduru_pkey PRIMARY KEY (magazamuduruno);


--
-- Name: magazamusteri magazamusteri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazamusteri
    ADD CONSTRAINT magazamusteri_pkey PRIMARY KEY (musterino, magazano);


--
-- Name: magazasahibi magazasahibi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazasahibi
    ADD CONSTRAINT magazasahibi_pkey PRIMARY KEY (magazasahibino);


--
-- Name: magazatedarikci magazatedarikci_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazatedarikci
    ADD CONSTRAINT magazatedarikci_pkey PRIMARY KEY (tedarikcino, magazano);


--
-- Name: magazaurun magazaurun_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazaurun
    ADD CONSTRAINT magazaurun_pkey PRIMARY KEY (magazano, urunno);


--
-- Name: musteri musteri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri
    ADD CONSTRAINT musteri_pkey PRIMARY KEY (musterino);


--
-- Name: otopark otopark_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otopark
    ADD CONSTRAINT otopark_pkey PRIMARY KEY (otoparkno);


--
-- Name: personel personel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT personel_pkey PRIMARY KEY (personelno);


--
-- Name: tedarikci tedarikci_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tedarikci
    ADD CONSTRAINT tedarikci_pkey PRIMARY KEY (tedarikcino);


--
-- Name: avm uq_avm_avmyoneticisi; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avm
    ADD CONSTRAINT uq_avm_avmyoneticisi UNIQUE (avmyoneticisino);


--
-- Name: gelir uq_gelir_magazano; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gelir
    ADD CONSTRAINT uq_gelir_magazano UNIQUE (magazano);


--
-- Name: magaza uq_magaza_adi; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magaza
    ADD CONSTRAINT uq_magaza_adi UNIQUE (katno, adi);


--
-- Name: magaza uq_magaza_magazasahibino; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magaza
    ADD CONSTRAINT uq_magaza_magazasahibino UNIQUE (magazasahibino);


--
-- Name: magaza uq_magazasahibi; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magaza
    ADD CONSTRAINT uq_magazasahibi UNIQUE (magazasahibino);


--
-- Name: urunler urunler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urunler
    ADD CONSTRAINT urunler_pkey PRIMARY KEY (urunno);


--
-- Name: avm_adi_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX avm_adi_idx ON public.avm USING btree (adi);


--
-- Name: avmyoneticisi_adi_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX avmyoneticisi_adi_idx ON public.avmyoneticisi USING btree (adi);


--
-- Name: eglencemerkezi_avmno_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX eglencemerkezi_avmno_idx ON public.eglencemerkezi USING btree (avmno);


--
-- Name: eglencemerkezi_eglencemerkezino_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX eglencemerkezi_eglencemerkezino_idx ON public.eglencemerkezi USING btree (eglencemerkezino);


--
-- Name: eglencemerkezi_oyuncaklar_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX eglencemerkezi_oyuncaklar_idx ON public.eglencemerkezi USING btree (oyuncaklar);


--
-- Name: gelir_gelirmiktari_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX gelir_gelirmiktari_idx ON public.gelir USING btree (gelirmiktari);


--
-- Name: gider_gidermiktari_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX gider_gidermiktari_idx ON public.gider USING btree (gidermiktari);


--
-- Name: gider_magazano_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX gider_magazano_idx ON public.gider USING btree (magazano);


--
-- Name: index_profilfoto; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_profilfoto ON public.magazaelemani USING btree (profilfoto);


--
-- Name: index_profilfoto1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_profilfoto1 ON public.avmyoneticisi USING btree (profilfoto);


--
-- Name: index_profilfoto2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_profilfoto2 ON public.magazamuduru USING btree (profilfoto);


--
-- Name: index_profilfoto3; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_profilfoto3 ON public.magazasahibi USING btree (profilfoto);


--
-- Name: index_profilfoto4; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_profilfoto4 ON public.personel USING btree (profilfoto);


--
-- Name: index_profilfoto5; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_profilfoto5 ON public.tedarikci USING btree (profilfoto);


--
-- Name: kat_avmno_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX kat_avmno_idx ON public.kat USING btree (avmno);


--
-- Name: kisi_ad_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX kisi_ad_idx ON public.kisi USING btree (ad);


--
-- Name: kisi_kisituru_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX kisi_kisituru_idx ON public.kisi USING btree (kisituru);


--
-- Name: kisi_soyad_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX kisi_soyad_idx ON public.kisi USING btree (soyad);


--
-- Name: magaza_adi_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX magaza_adi_idx ON public.magaza USING btree (adi);


--
-- Name: magaza_katno_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX magaza_katno_idx ON public.magaza USING btree (katno);


--
-- Name: magaza_magazamuduruno_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX magaza_magazamuduruno_idx ON public.magaza USING btree (magazamuduruno);


--
-- Name: magazaelemani_adi_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX magazaelemani_adi_idx ON public.magazaelemani USING btree (adi);


--
-- Name: magazaelemani_magazano_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX magazaelemani_magazano_idx ON public.magazaelemani USING btree (magazano);


--
-- Name: magazaelemani_soyadi_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX magazaelemani_soyadi_idx ON public.magazaelemani USING btree (soyadi);


--
-- Name: avmyoneticisi trg_avm_yoneticisi_ekle; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_avm_yoneticisi_ekle BEFORE INSERT ON public.avmyoneticisi FOR EACH ROW EXECUTE FUNCTION public.avm_yoneticisi_ekle_engelle();


--
-- Name: avmyoneticisi trg_avm_yoneticisi_silme; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_avm_yoneticisi_silme BEFORE DELETE ON public.avmyoneticisi FOR EACH ROW EXECUTE FUNCTION public.avm_yoneticisi_silme_engelle();


--
-- Name: personel trg_kat_personel_kontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_kat_personel_kontrol BEFORE INSERT OR DELETE ON public.personel FOR EACH ROW EXECUTE FUNCTION public.fn_kat_personel_kontrol();


--
-- Name: magazaelemani trg_magazaelemani_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_magazaelemani_insert BEFORE INSERT ON public.magazaelemani FOR EACH ROW EXECUTE FUNCTION public.magazaelemani_eklendi_kisi_ekle();


--
-- Name: magazaelemani trg_magazaelemani_kontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_magazaelemani_kontrol BEFORE INSERT OR DELETE ON public.magazaelemani FOR EACH ROW EXECUTE FUNCTION public.fn_magazaelemani_kontrol();


--
-- Name: magazaelemani trg_magazaelemani_silme; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_magazaelemani_silme AFTER DELETE ON public.magazaelemani FOR EACH ROW EXECUTE FUNCTION public.fn_magazaelemani_silme();


--
-- Name: magazaelemani trg_magazaelemani_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_magazaelemani_update AFTER UPDATE ON public.magazaelemani FOR EACH ROW WHEN ((((old.adi)::text IS DISTINCT FROM (new.adi)::text) OR ((old.soyadi)::text IS DISTINCT FROM (new.soyadi)::text))) EXECUTE FUNCTION public.magazaelemani_guncellendi_kisi_guncelle();


--
-- Name: musteri trg_musteri_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_musteri_insert BEFORE INSERT ON public.musteri FOR EACH ROW EXECUTE FUNCTION public.musteri_eklendi_kisi_ekle();


--
-- Name: personel trg_personel_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_personel_insert BEFORE INSERT ON public.personel FOR EACH ROW EXECUTE FUNCTION public.personel_eklendi_kisi_ekle();


--
-- Name: personel trg_personel_silme; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_personel_silme AFTER DELETE ON public.personel FOR EACH ROW EXECUTE FUNCTION public.fn_personel_silme();


--
-- Name: kat trg_prevent_kat_ekle; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_prevent_kat_ekle BEFORE INSERT ON public.kat FOR EACH ROW EXECUTE FUNCTION public.prevent_kat_ekle();


--
-- Name: kat trg_prevent_kat_sil; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_prevent_kat_sil BEFORE DELETE ON public.kat FOR EACH ROW EXECUTE FUNCTION public.prevent_kat_sil();


--
-- Name: tedarikci trg_tedarikci_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_tedarikci_delete AFTER DELETE ON public.tedarikci FOR EACH ROW EXECUTE FUNCTION public.fn_tedarikci_delete();


--
-- Name: tedarikci trg_tedarikci_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_tedarikci_insert AFTER INSERT ON public.tedarikci FOR EACH ROW EXECUTE FUNCTION public.tedarikci_eklendi_kisi_ekle();


--
-- Name: tedarikci trg_tedarikci_silme; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_tedarikci_silme AFTER DELETE ON public.tedarikci FOR EACH ROW EXECUTE FUNCTION public.fn_tedarikci_silme();


--
-- Name: tedarikci trg_tedarikci_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_tedarikci_update AFTER UPDATE ON public.tedarikci FOR EACH ROW WHEN ((((old.adi)::text IS DISTINCT FROM (new.adi)::text) OR ((old.soyadi)::text IS DISTINCT FROM (new.soyadi)::text))) EXECUTE FUNCTION public.tedarikci_guncellendi_kisi_guncelle();


--
-- Name: avm fk_avm_avmyoneticisi; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avm
    ADD CONSTRAINT fk_avm_avmyoneticisi FOREIGN KEY (avmyoneticisino) REFERENCES public.avmyoneticisi(avmyoneticisino) ON DELETE RESTRICT;


--
-- Name: avm fk_avm_avmyoneticisino; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avm
    ADD CONSTRAINT fk_avm_avmyoneticisino FOREIGN KEY (avmyoneticisino) REFERENCES public.avmyoneticisi(avmyoneticisino) ON DELETE CASCADE;


--
-- Name: avmyoneticisi fk_avmyoneticisi_kisino; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avmyoneticisi
    ADD CONSTRAINT fk_avmyoneticisi_kisino FOREIGN KEY (kisino) REFERENCES public.kisi(id) ON DELETE CASCADE;


--
-- Name: eglencemerkezi fk_eglencemerkezi_avm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eglencemerkezi
    ADD CONSTRAINT fk_eglencemerkezi_avm FOREIGN KEY (avmno) REFERENCES public.avm(avmno) ON DELETE CASCADE;


--
-- Name: gelir fk_gelir_magaza; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gelir
    ADD CONSTRAINT fk_gelir_magaza FOREIGN KEY (magazano) REFERENCES public.magaza(magazano);


--
-- Name: gider fk_gider_magaza; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gider
    ADD CONSTRAINT fk_gider_magaza FOREIGN KEY (magazano) REFERENCES public.magaza(magazano);


--
-- Name: kat fk_kat_avm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kat
    ADD CONSTRAINT fk_kat_avm FOREIGN KEY (avmno) REFERENCES public.avm(avmno) ON DELETE CASCADE;


--
-- Name: magaza fk_magaza_magazamuduruno; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magaza
    ADD CONSTRAINT fk_magaza_magazamuduruno FOREIGN KEY (magazamuduruno) REFERENCES public.magazamuduru(magazamuduruno) ON DELETE CASCADE;


--
-- Name: magaza fk_magaza_magazasahibi; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magaza
    ADD CONSTRAINT fk_magaza_magazasahibi FOREIGN KEY (magazasahibino) REFERENCES public.magazasahibi(magazasahibino) ON DELETE CASCADE;


--
-- Name: magaza fk_magaza_magazasahibino; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magaza
    ADD CONSTRAINT fk_magaza_magazasahibino FOREIGN KEY (magazasahibino) REFERENCES public.magazasahibi(magazasahibino) ON DELETE CASCADE;


--
-- Name: magazaelemani fk_magazaelemani_kisino; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazaelemani
    ADD CONSTRAINT fk_magazaelemani_kisino FOREIGN KEY (kisino) REFERENCES public.kisi(id) ON DELETE CASCADE;


--
-- Name: magazaelemani fk_magazaelemani_magaza; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazaelemani
    ADD CONSTRAINT fk_magazaelemani_magaza FOREIGN KEY (magazano) REFERENCES public.magaza(magazano);


--
-- Name: magazaelemani fk_magazaelemani_magazano; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazaelemani
    ADD CONSTRAINT fk_magazaelemani_magazano FOREIGN KEY (magazano) REFERENCES public.magaza(magazano) ON DELETE CASCADE;


--
-- Name: magazamuduru fk_magazamuduru_kisino; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazamuduru
    ADD CONSTRAINT fk_magazamuduru_kisino FOREIGN KEY (kisino) REFERENCES public.kisi(id) ON DELETE CASCADE;


--
-- Name: magazamusteri fk_magazamusteri_magazano; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazamusteri
    ADD CONSTRAINT fk_magazamusteri_magazano FOREIGN KEY (magazano) REFERENCES public.magaza(magazano) ON DELETE CASCADE;


--
-- Name: magazamusteri fk_magazamusteri_musteri; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazamusteri
    ADD CONSTRAINT fk_magazamusteri_musteri FOREIGN KEY (musterino) REFERENCES public.musteri(musterino) ON DELETE CASCADE;


--
-- Name: magazasahibi fk_magazasahibi_kisino; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazasahibi
    ADD CONSTRAINT fk_magazasahibi_kisino FOREIGN KEY (kisino) REFERENCES public.kisi(id) ON DELETE CASCADE;


--
-- Name: magazatedarikci fk_magazatedarikci_magazano; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazatedarikci
    ADD CONSTRAINT fk_magazatedarikci_magazano FOREIGN KEY (magazano) REFERENCES public.magaza(magazano) ON DELETE CASCADE;


--
-- Name: magazatedarikci fk_magazatedarikci_tedarikcino; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazatedarikci
    ADD CONSTRAINT fk_magazatedarikci_tedarikcino FOREIGN KEY (tedarikcino) REFERENCES public.tedarikci(tedarikcino) ON DELETE CASCADE;


--
-- Name: magazaurun fk_magazaurun_magazano; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazaurun
    ADD CONSTRAINT fk_magazaurun_magazano FOREIGN KEY (magazano) REFERENCES public.magaza(magazano) ON DELETE CASCADE;


--
-- Name: magazaurun fk_magazaurun_urunno; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazaurun
    ADD CONSTRAINT fk_magazaurun_urunno FOREIGN KEY (urunno) REFERENCES public.urunler(urunno) ON DELETE CASCADE;


--
-- Name: musteri fk_musteri_kisino; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri
    ADD CONSTRAINT fk_musteri_kisino FOREIGN KEY (kisino) REFERENCES public.kisi(id) ON DELETE CASCADE;


--
-- Name: otopark fk_otopark_avm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otopark
    ADD CONSTRAINT fk_otopark_avm FOREIGN KEY (avmno) REFERENCES public.avm(avmno) ON DELETE CASCADE;


--
-- Name: otopark fk_otopark_kat; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otopark
    ADD CONSTRAINT fk_otopark_kat FOREIGN KEY (katno) REFERENCES public.kat(katno);


--
-- Name: personel fk_personel_kisino; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT fk_personel_kisino FOREIGN KEY (kisino) REFERENCES public.kisi(id) ON DELETE CASCADE;


--
-- Name: tedarikci fk_tedarikci_kisino; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tedarikci
    ADD CONSTRAINT fk_tedarikci_kisino FOREIGN KEY (kisino) REFERENCES public.kisi(id) ON DELETE CASCADE;


--
-- Name: magaza katno; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magaza
    ADD CONSTRAINT katno FOREIGN KEY (katno) REFERENCES public.kat(katno);


--
-- Name: personel katno; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT katno FOREIGN KEY (katno) REFERENCES public.kat(katno);


--
-- Name: magazamusteri magazamusteri_magazano_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazamusteri
    ADD CONSTRAINT magazamusteri_magazano_fkey FOREIGN KEY (magazano) REFERENCES public.magaza(magazano);


--
-- Name: magazamusteri magazamusteri_musterino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazamusteri
    ADD CONSTRAINT magazamusteri_musterino_fkey FOREIGN KEY (musterino) REFERENCES public.musteri(musterino);


--
-- Name: magazaurun magazaurun_magazano_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.magazaurun
    ADD CONSTRAINT magazaurun_magazano_fkey FOREIGN KEY (magazano) REFERENCES public.magaza(magazano);


--
-- PostgreSQL database dump complete
--

\unrestrict eVbGzEd6zCTJlSPkUdyRD2ThnCXafC4ZA5uRFxB6SN2ccRxYoeoBqLLNqDFhyxd


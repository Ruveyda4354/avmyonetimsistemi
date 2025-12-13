using Microsoft.AspNetCore.Mvc;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Npgsql;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace VeriTabaniProject.Controllers;

public class MagazaController : Controller
{
    private readonly IConfiguration _configuration;
    private readonly string _connectionString;
    private readonly AppDbContext _context;
    public MagazaController(AppDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
        _connectionString = _configuration.GetConnectionString("DefaultConnection");
        Console.WriteLine("Conn: " + _connectionString);


    }

    public IActionResult Index(string search)
    {
        _context.ChangeTracker.Clear();
        var Magazalar = _context.Magazas
            .Include(ms => ms.MagazasahibinoNavigation)
            .Include(mm => mm.MagazamudurunoNavigation)
            .Include(u => u.Urunnos)
            .Include(me => me.Magazaelemanis)
            .AsQueryable();

        if (!string.IsNullOrEmpty(search))
        {
            Magazalar = Magazalar.Where(x => x.Adi.Contains(search));
        }

        return View(Magazalar.OrderBy(x => x.Magazano).ToList());
    }

    public IActionResult MagazaIndex(int id)
    {
        var magaza = _context.Magazas.Include(ms => ms.MagazasahibinoNavigation).Include(mm => mm.MagazamudurunoNavigation).Include(u => u.Urunnos).Include(me => me.Magazaelemanis).FirstOrDefault(x => x.Magazano == id);


        return View(magaza);
    }

    [HttpGet]
    public IActionResult Create()
    {
        var model = new Magaza
        {
            MagazamudurunoNavigation = new Magazamuduru(),
            MagazasahibinoNavigation = new Magazasahibi(),
            Gelir = new Gelir(),
            Gider = new Gider(),

            Urunnos = new List<Urunler>(),
            Magazaelemanis = new List<Magazaelemani>()
        };

        for (int i = 0; i < 5; i++)
        {
            model.Urunnos.Add(new Urunler());
            model.Magazaelemanis.Add(new Magazaelemani());
        }

        return View(model);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Create(Magaza model)
    {
        // 1. Validasyon: Eğer bağlantı stringi yoksa hata dön
        if (string.IsNullOrEmpty(_connectionString))
        {
            TempData["Error"] = "Veritabanı bağlantı hatası!";
            return View(model);
        }
        try
        {
            // 2. Boş satırları filtrele (Kullanıcı 5 satırın sadece 2'sini doldurmuş olabilir)
            // Adı boş olmayan ürünleri ve elemanları alıyoruz.
            var doluUrunler = model.Urunnos.Where(u => !string.IsNullOrEmpty(u.Adi)).ToList();
            var doluElemanlar = model.Magazaelemanis.Where(e => !string.IsNullOrEmpty(e.Adi)).ToList();

            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();

                // 3. Saklı Yordamı Çağır
                string sql = "CALL spmagazaekle_coklu(@p_magaza_adi, @p_katno, @p_mudur_ad, @p_mudur_soyad, @p_sahip_ad, @p_sahip_soyad, @p_gelir_miktari, @p_gider_miktari, @p_urun_adlari, @p_stoklar, @p_eleman_adlari, @p_eleman_soyadlari)";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    // --- TEKİL PARAMETRELER ---
                    cmd.Parameters.AddWithValue("p_magaza_adi", model.Adi);
                    cmd.Parameters.AddWithValue("p_katno", model.Katno);

                    cmd.Parameters.AddWithValue("p_mudur_ad", model.MagazamudurunoNavigation.Adi);
                    cmd.Parameters.AddWithValue("p_mudur_soyad", model.MagazamudurunoNavigation.Soyadi);

                    cmd.Parameters.AddWithValue("p_gelir_miktari", model.Gelir.Gelirmiktari);
                    cmd.Parameters.AddWithValue("p_gider_miktari", model.Gider.Gidermiktari);

                    cmd.Parameters.AddWithValue("p_sahip_ad", model.MagazasahibinoNavigation.Adi);
                    cmd.Parameters.AddWithValue("p_sahip_soyad", model.MagazasahibinoNavigation.Soyadi);

                    // --- DİZİ PARAMETRELERİ (ÖNEMLİ KISIM) ---
                    // Listeyi parçalayıp Array (Dizi) olarak gönderiyoruz.

                    // Ürünler
                    cmd.Parameters.AddWithValue("p_urun_adlari", doluUrunler.Select(x => x.Adi).ToArray());
                    cmd.Parameters.AddWithValue("p_stoklar", doluUrunler.Select(x => x.Stok).ToArray());

                    // Elemanlar
                    cmd.Parameters.AddWithValue("p_eleman_adlari", doluElemanlar.Select(x => x.Adi).ToArray());
                    cmd.Parameters.AddWithValue("p_eleman_soyadlari", doluElemanlar.Select(x => x.Soyadi).ToArray());

                    // 4. Çalıştır
                    cmd.ExecuteNonQuery();
                }
            }

            TempData["Message"] = "Mağaza, ürünler ve personel başarıyla kaydedildi.";
            return RedirectToAction("Index");
        }
        catch (Exception ex)
        {
            TempData["Error"] = "Hata oluştu: " + ex.Message;
            return View(model);
        }
    }
    public IActionResult Edit(int id)
    {
        var magaza = _context.Magazas
            .Include(m => m.MagazasahibinoNavigation)
            .Include(m => m.MagazamudurunoNavigation)
            .Include(m => m.Urunnos)           // sadece o mağazaya ait ürünler
            .Include(m => m.Magazaelemanis)
            .FirstOrDefault(x => x.Magazano == id);

        if (magaza == null) return NotFound();

        var model = new MagazaEditViewModel
        {
            Adi = magaza.Adi,
            Magazano = magaza.Magazano,
            Katno = magaza.Katno,
            MagazamudurunoNavigation = magaza.MagazamudurunoNavigation,
            MagazasahibinoNavigation = magaza.MagazasahibinoNavigation,
            Magazaelemanis = magaza.Magazaelemanis.ToList(),

            // sadece o mağazaya ait ürünler
            UrunListesi = magaza.Urunnos.Select(u => new MagazaUrunItem
            {
                UrunId = u.Urunno,
                UrunAdi = u.Adi ?? "",
                Stok = u.Stok ?? 0,
                Fiyat = u.Fiyat ?? 0,
                SeciliMi = true
            }).ToList()
        };

        return View(model);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult EditConfirmed(MagazaEditViewModel model, int id)
    {
        var magaza = _context.Magazas
            .Include(m => m.Urunnos)
            .Include(m => m.Magazaelemanis)
            .FirstOrDefault(x => x.Magazano == id);

        if (magaza == null) return NotFound();

        // Mağaza bilgilerini güncelle
        magaza.Adi = model.Adi;
        magaza.Katno = model.Katno;

        // Ürün stoklarını güncelle
        foreach (var item in model.UrunListesi)
        {
            var urunDb = _context.Urunlers.Find(item.UrunId);
            if (urunDb != null && urunDb.Stok != item.Stok)
            {
                urunDb.Stok = item.Stok;
            }
             if (urunDb != null && urunDb.Adi != item.UrunAdi)
            {
               
                urunDb.Adi=item.UrunAdi;
               
            }
             if (urunDb != null && urunDb.Fiyat != item.Fiyat)
            {
               
               
                urunDb.Fiyat = item.Fiyat;
               
            }
              _context.Update(urunDb);
        }

        _context.SaveChanges();
        return RedirectToAction(nameof(Index));
    }
    public IActionResult Delete(int id)
    {

        var magaza = _context.Magazas
            .Include(ms => ms.MagazasahibinoNavigation)
            .Include(mm => mm.MagazamudurunoNavigation)
            .Include(u => u.Urunnos)
            .Include(me => me.Magazaelemanis)
            .Include(g => g.Gelir)
            .Include(g => g.Gider)
            .FirstOrDefault(x => x.Magazano == id);

        if (magaza == null)
        {
            return NotFound();
        }

        return View(magaza);
    }
    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int id)
    {

        if (string.IsNullOrEmpty(_connectionString))
        {
            TempData["Error"] = "Veritabanı bağlantı hatası: Connection String bulunamadı.";
            return RedirectToAction("Index");
        }

        try
        {
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();


                string sql = "CALL spmagazasil(@p_magazano)";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {

                    cmd.Parameters.AddWithValue("p_magazano", id);


                    cmd.ExecuteNonQuery();
                }
            }

            TempData["Message"] = "Mağaza ve ilişkili tüm veriler (Personel, Ürün, Stok, Gelir/Gider) başarıyla silindi.";
        }
        catch (PostgresException ex)
        {

            Console.WriteLine(">>> SQL Hatası: " + ex.MessageText);
            TempData["Error"] = "Veritabanı hatası: " + ex.MessageText;
        }
        catch (Exception ex)
        {

            Console.WriteLine(">>> Genel Hata: " + ex.Message);
            TempData["Error"] = "İşlem sırasında bir hata oluştu: " + ex.Message;
        }

        return RedirectToAction("Index");
    }
}
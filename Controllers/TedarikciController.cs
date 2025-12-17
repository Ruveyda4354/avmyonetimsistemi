using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;
using Microsoft.AspNetCore.Mvc.Rendering;
using VeriTabaniProje.Data;
using Npgsql;

namespace VeriTabaniProje.Controllers;

public class TedarikciController : Controller
{
    private readonly AppDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly string _connectionString;
    private readonly ILogger<TedarikciController> _logger;
    public TedarikciController(AppDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
        _connectionString = _configuration.GetConnectionString("DefaultConnection");


    }

    public IActionResult Index(String search)
    {
        _context.ChangeTracker.Clear();
        var liste = _context.Tedarikcis.AsQueryable();
        if (!string.IsNullOrEmpty(search))
        {
            search = search.ToLower();
            liste = liste
                .Where(p =>
                    p.Tedarikcino.ToString().Contains(search) ||
                    p.Tedarikcino.ToString().Contains(search) ||
                    p.Soyadi.ToLower().Contains(search) ||
                    (p.Adi + " " + p.Soyadi).ToLower().Contains(search));
        }
        return View(liste.OrderBy(p => p.Tedarikcino).Include(m => m.Magazanos).ToList());

    }

    public IActionResult Edit(int id)
    {
        var tedarikci = _context.Tedarikcis
            .Include(t => t.Magazanos)
            .FirstOrDefault(t => t.Tedarikcino == id);

        if (tedarikci == null)
            return NotFound();

        var model = new TedarikciEditViewModel
        {
            Id = tedarikci.Tedarikcino,
            Adi = tedarikci.Adi,
            Soyadi = tedarikci.Soyadi,
            Profilfoto = tedarikci.Profilfoto,

            SecilenMagazaIdList = tedarikci.Magazanos.Select(m => m.Magazano).ToList(),

            MagazaList = _context.Magazas
                .Select(m => new SelectListItem
                {
                    Value = m.Magazano.ToString(),
                    Text = m.Adi
                })
                .ToList()
        };

        return View(model);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(TedarikciEditViewModel model, IFormFile Foto)
    {
        // Veritabanından tedarikçiyi ve MEVCUT mağaza ilişkilerini çekiyoruz.
        var tedarikci = _context.Tedarikcis
            .Include(t => t.Magazanos) // İlişkili tabloyu dahil etmek şart
            .FirstOrDefault(t => t.Tedarikcino == model.Id);

        if (tedarikci == null)
        {
            return NotFound();
        }

        // 1. Temel Bilgileri Güncelle
        tedarikci.Adi = model.Adi;
        tedarikci.Soyadi = model.Soyadi;

        // 2. Fotoğraf Yükleme İşlemi
        if (Foto != null)
        {
            var fileName = Guid.NewGuid() + Path.GetExtension(Foto.FileName);
            var path = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/images/profil/profil", fileName);

            using (var stream = new FileStream(path, FileMode.Create))
            {
                await Foto.CopyToAsync(stream);
            }
            tedarikci.Profilfoto = fileName;
        }

        // 3. MAĞAZA İLİŞKİLERİNİ GÜNCELLEME (Many-to-Many Logic)

        // a) Mevcut ilişkileri temizle (Tedarikçinin tüm mağaza bağlarını kopar)
        tedarikci.Magazanos.Clear();

        // b) View'dan gelen seçili ID'lere göre yeni mağazaları bul ve ekle
        if (model.SecilenMagazaIdList != null && model.SecilenMagazaIdList.Count > 0)
        {
            // Distinct() kullanarak aynı mağazanın 2 kere seçilmesini engelliyoruz
            var secilenMagazaIdleri = model.SecilenMagazaIdList.Distinct().ToList();

            var eklenecekMagazalar = _context.Magazas
                .Where(m => secilenMagazaIdleri.Contains(m.Magazano))
                .ToList();

            foreach (var magaza in eklenecekMagazalar)
            {
                tedarikci.Magazanos.Add(magaza);
            }
        }

        try
        {
            _context.Update(tedarikci);
            await _context.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            // Hata durumunda listeyi tekrar doldurup sayfayı döndür
            ModelState.AddModelError("", "Hata: " + ex.Message);
            model.MagazaList = _context.Magazas
               .Select(m => new SelectListItem { Value = m.Magazano.ToString(), Text = m.Adi })
               .ToList();
            return View(model);
        }

        return RedirectToAction(nameof(Index));
    }
    [HttpGet]
    public IActionResult Create()
    {
        var model = new TedarikciEditViewModel
        {
            MagazaList = _context.Magazas
                .Select(m => new SelectListItem
                {
                    Value = m.Magazano.ToString(),
                    Text = m.Adi
                }).ToList()
        };
        return View(model);
    }
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(TedarikciEditViewModel model, IFormFile Foto)
    {
        // Debug için konsola yazalım (Output penceresinden takip edebilirsin)
        Console.WriteLine($"Kayıt Başladı -> Ad: {model.Adi}, MağazaNo: {model.Magazano}");

        // 1. KONTROL: Mağaza seçilmiş mi?
        if (model.Magazano == 0)
        {
            ModelState.AddModelError("Magazano", "Lütfen bir mağaza seçiniz.");
        }

        if (!ModelState.IsValid)
        {
            model.MagazaList = _context.Magazas
                .Select(m => new SelectListItem { Value = m.Magazano.ToString(), Text = m.Adi }).ToList();
            return View(model);
        }

        // --- Dosya İşlemleri ---
        string fileName = "1.jpg"; // Varsayılan resim
        if (Foto != null && Foto.Length > 0)
        {
            fileName = Guid.NewGuid().ToString() + Path.GetExtension(Foto.FileName);
            var filePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/images/profil/profil", fileName);

            if (!Directory.Exists(Path.GetDirectoryName(filePath)))
                Directory.CreateDirectory(Path.GetDirectoryName(filePath)!);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await Foto.CopyToAsync(stream);
            }
        }

        // !!! EKSİK OLAN KISIM BURASIYDI !!!
        // Dosya adını modele atamazsan veritabanına NULL gider.
        model.Profilfoto = fileName;

        try
        {
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();

                // SQL Çağrısı
                string sql = "CALL sptedarikciekle(@p_ad, @p_soyad, @p_profil_foto, @p_secilen_magaza_no)";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    // Parametreleri eklerken tipleri netleştirelim
                    cmd.Parameters.AddWithValue("p_ad", model.Adi);
                    cmd.Parameters.AddWithValue("p_soyad", model.Soyadi);
                    cmd.Parameters.AddWithValue("p_profil_foto", model.Profilfoto); // Artık fileName buraya dolu geliyor
                    cmd.Parameters.AddWithValue("p_secilen_magaza_no", model.Magazano);

                    cmd.ExecuteNonQuery();
                }
            }

            // Başarılı olursa Index'e dön
            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            // Hata mesajını ekrana bas
            TempData["Error"] = "Kayıt sırasında hata oluştu: " + ex.Message;

            // Listeyi tekrar doldur ki sayfa bozuk açılmasın
            model.MagazaList = _context.Magazas
                .Select(m => new SelectListItem { Value = m.Magazano.ToString(), Text = m.Adi }).ToList();

            return View(model);
        }
    }
    public IActionResult Delete(int id)
    {
        var tedarikci = _context.Tedarikcis
            .Include(m => m.Magazanos)
            .FirstOrDefault(k => k.Tedarikcino == id);

        if (tedarikci == null)
        {
            return NotFound();
        }

        return View(tedarikci);
    }

    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int id)
    {
        try
        {
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();
                string sql = "CALL sptedarikcisil(@p_tedarikci_no)";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("p_tedarikci_no", id);
                    cmd.ExecuteNonQuery();
                }
            }

            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            TempData["Error"] = "Silme işlemi başarısız: " + ex.Message;
            return RedirectToAction(nameof(Index));
        }
    }


}
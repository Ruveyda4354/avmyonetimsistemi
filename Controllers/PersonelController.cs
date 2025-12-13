using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;
using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace VeriTabaniProje.Controllers;

public class PersonelController : Controller
{
    private readonly AppDbContext _context;
    public PersonelController(AppDbContext context)
    {
        _context = context;
    }

    public IActionResult Index(string search)
    {
        _context.ChangeTracker.Clear();
        var liste = _context.Personels.AsQueryable();
        if (!string.IsNullOrEmpty(search))
        {
            search = search.ToLower();
            liste = liste
                .Where(p =>
                    p.Personelno.ToString().Contains(search) ||
                    p.Katno.ToString().Contains(search) ||
                    p.Adi.ToLower().Contains(search) ||
                    p.Soyadi.ToLower().Contains(search) ||
                    (p.Adi + " " + p.Soyadi).ToLower().Contains(search));
        }
        return View(liste.OrderBy(p => p.Personelno).ToList());
    }

    public IActionResult Edit(int id)
    {
        var personel = _context.Personels.Find(id);
        if (personel == null)
            return NotFound();
        ViewBag.AdSoyad = $"{personel.Adi} {personel.Soyadi}";
        return View(personel);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, IFormCollection form, IFormFile Foto)
    {
        var Personel = _context.Personels.FirstOrDefault(p => p.Personelno == id);
        if (Personel == null)
        {
            return NotFound();
        }
        string AdSoyad = form["AdSoyad"];
        var parts = AdSoyad.Split(' ', 2);
        Personel.Adi = parts[0];
        Personel.Soyadi = parts.Length > 1 ? parts[1] : "";
        Personel.Katno = int.Parse(form["Katno"]);

        if (Foto != null && Foto.Length > 0)
        {

            var fileName = Guid.NewGuid().ToString() + Path.GetExtension(Foto.FileName);


            var filePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/images/profil/profil", fileName);


            if (!Directory.Exists(Path.GetDirectoryName(filePath)))
            {
                Directory.CreateDirectory(Path.GetDirectoryName(filePath)!);
            }


            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await Foto.CopyToAsync(stream);
            }


            Personel.Profilfoto = fileName;
        }


        _context.Personels.Update(Personel);
        _context.SaveChanges();

        return RedirectToAction("Index");
    }
    public IActionResult Create()
    {
        ViewBag.Katlar = new List<int> { 0, 1, 2 };
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(IFormCollection form, IFormFile Foto)
    {


        string AdSoyad = form["AdSoyad"];
        string KatnoStr = form["Katno"];

        if (string.IsNullOrWhiteSpace(AdSoyad) || string.IsNullOrWhiteSpace(KatnoStr))
        {
            ModelState.AddModelError("", "Tüm alanları doldurmalısınız.");
            ViewBag.Katlar = new List<int> { 0, 1, 2 };
            return View();
        }
        if (!int.TryParse(KatnoStr, out int Katno))
        {
            ModelState.AddModelError("Katno", "Katno geçerli bir sayı olmalıdır.");
            ViewBag.Katlar = new List<int> { 0, 1, 2 };
            return View();
        }
        var parts = AdSoyad.Split(' ', 2);
        string adi = parts[0];
        string soyadi = parts.Length > 1 ? parts[1] : "";

        int maxPersonelNo = 0;
        if (_context.Personels.Any())
        {
            maxPersonelNo = _context.Personels.Max(p => p.Personelno);
        }
        int yeniPersonelNo = maxPersonelNo + 1;

        var personel = new Personel
        {
            Personelno = yeniPersonelNo,
            Adi = adi,
            Soyadi = soyadi,
            Katno = Katno
        };
        if (Foto != null && Foto.Length > 0)
        {

            var fileName = Guid.NewGuid().ToString() + Path.GetExtension(Foto.FileName);


            var filePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/images/profil/profil", fileName);


            if (!Directory.Exists(Path.GetDirectoryName(filePath)))
            {
                Directory.CreateDirectory(Path.GetDirectoryName(filePath)!);
            }


            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await Foto.CopyToAsync(stream);
            }


            personel.Profilfoto = fileName;
        }
        try
        {
            _context.Personels.Add(personel);
            _context.SaveChanges();

        }
        catch (DbUpdateException ex) // EF Core exception
        {
            if (ex.InnerException != null)
            {
                // PostgreSQL trigger exception mesajını alıyoruz
                TempData["Error"] = ex.InnerException.Message;
            }
            else
            {
                TempData["Error"] = ex.Message;
            }

            return RedirectToAction("Create");
        }
        return RedirectToAction("Index");
    }
    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult KatGuncelle(int Personelno, int YeniKat)
    {
        // 1. İlgili personeli veritabanından bul
        var personel = _context.Personels.Find(Personelno);

        if (personel == null)
        {
            return NotFound(); // Personel bulunamazsa hata dön
        }

        try
        {
            personel.Katno = YeniKat;

            _context.SaveChanges();
        }
        catch (Exception ex)
        {
            // Hata durumunda loglama yapılabilir
            ModelState.AddModelError("", "Güncelleme sırasında hata oluştu.");
        }

        // 4. İşlem bitince kullanıcıyı tekrar geldiği sayfaya gönder
        // "Referer" header'ı kullanıcının bu butona bastığı sayfadır (Kat/Edit sayfası)
        string referer = Request.Headers["Referer"].ToString();

        if (!string.IsNullOrEmpty(referer))
        {
            return Redirect(referer);
        }
        else
        {
            // Eğer referer yoksa güvenli liman olarak Kat Index'e git
            return RedirectToAction("Index", "Kat");
        }
    }
    public IActionResult Delete(int id)
    {
        var personel = _context.Personels.Find(id);
        if (personel == null)
            return BadRequest();
        return View(personel);

    }
    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int Personelno)
    {
        var personel = _context.Personels.Find(Personelno);

        // 1. Önce personel var mı kontrol et
        if (personel == null)
        {
            TempData["Error"] = "Personel bulunamadı.";

        }

        try
        {
            // 2. ASIL İŞLEM: Önce silmeyi yap
            _context.Personels.Remove(personel);
            _context.SaveChanges(); // Veritabanı işlemi burada yapılır

            TempData["Message"] = "Personel başarıyla silindi.";
        }
        catch (DbUpdateException ex)
        {
            // Hata varsa kullanıcıya göster ve çık
            if (ex.InnerException != null)
            {
                TempData["Error"] = ex.InnerException.Message;
            }
            else
            {
                TempData["Error"] = ex.Message;
            }
            // Hata durumunda Index'e dönmek en güvenlisidir

        }

        // 3. YÖNLENDİRME: İşlem başarıyla bittikten sonra nereye gideceğine karar ver

        return RedirectToAction("Index");
    }
}
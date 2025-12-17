using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;

using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;

namespace VeriTabaniProje.Controllers;

public class MagazaelemaniController : Controller
{
    private readonly AppDbContext _context;
    public MagazaelemaniController(AppDbContext context)
    {
        _context = context;
    }

    public IActionResult Index(String search)
    {
        _context.ChangeTracker.Clear();
        var liste = _context.Magazaelemanis.AsQueryable();
        if (!string.IsNullOrEmpty(search))
        {
            search = search.ToLower();
            liste = liste
                .Where(p =>
                    p.Magazaelemanno.ToString().Contains(search) ||
                    p.Adi.ToLower().Contains(search) ||
                    p.Soyadi.ToLower().Contains(search) ||
                    (p.Adi + " " + p.Soyadi).ToLower().Contains(search));
        }
        return View(liste.OrderBy(p => p.Magazaelemanno).Include(p => p.MagazanoNavigation).ToList());
    }

    public IActionResult Edit(int id)
    {
        var magazaElemani = _context.Magazaelemanis.Include(m => m.MagazanoNavigation).FirstOrDefault(k => k.Magazaelemanno == id);
        if (magazaElemani == null)
            return NotFound();

        var model = new MagazaElemanEditViewModel
        {
            Id = magazaElemani.Magazaelemanno,
            Adi = magazaElemani.Adi,
            Soyadi = magazaElemani.Soyadi,
            Profilfoto = magazaElemani.Profilfoto,
            Magazano = magazaElemani.Magazano,
            MagazaList = _context.Magazas.Select(m => new SelectListItem { Value = m.Magazano.ToString(), Text = m.Adi }).ToList()
        };
        return View(model);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int Id, MagazaElemanEditViewModel model, IFormFile Foto)
    {
        // 1. Validasyon engellerini kaldır (Trigger çalışsın diye)
        ModelState.Clear();

        var magazaElemani = _context.Magazaelemanis.FirstOrDefault(p => p.Magazaelemanno == Id);
        if (magazaElemani == null)
        {
            return NotFound();
        }

        // 2. Fotoğraf İşlemleri
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

            // Yeni fotoğrafı modele ata
            magazaElemani.Profilfoto = fileName;
        }
        // Fotoğraf yüklenmediyse eskisini koru (Zaten nesnede eski veri duruyor, bir şey yapmaya gerek yok)

        // 3. Diğer Bilgileri Güncelle
        magazaElemani.Adi = model.Adi;
        magazaElemani.Soyadi = model.Soyadi;

        // Mağaza değişimi varsa güncelle
        if (model.Magazano != null && model.Magazano != 0)
        {
            magazaElemani.Magazano = model.Magazano;
        }

        try
        {
            _context.Update(magazaElemani);

            // Bu satır çalıştığında PostgreSQL'deki UPDATE Trigger'ın devreye girecek
            // ve Kişi tablosundaki Ad/Soyad'ı da güncelleyecek.
            await _context.SaveChangesAsync();

            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            // Hata olursa sayfada göster
            ViewBag.Errors = new List<string> { "Hata: " + ex.Message + (ex.InnerException != null ? " | " + ex.InnerException.Message : "") };

            // Listeyi tekrar doldurmak gerekir yoksa selectbox boş gelir
            model.MagazaList = _context.Magazas.Select(m => new SelectListItem { Value = m.Magazano.ToString(), Text = m.Adi }).ToList();
            return View(model);
        }
    }
    public IActionResult Create()
    {

        var model = new MagazaElemanEditViewModel
        {

            MagazaList = _context.Magazas.Select(m => new SelectListItem { Value = m.Magazano.ToString(), Text = m.Adi }).ToList()
        };
        return View(model);

    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(MagazaElemanEditViewModel model, IFormCollection form, IFormFile Foto)
    {
        var magazaElemani = new Magazaelemani();
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                        .SelectMany(v => v.Errors)
                        .Select(e => e.ErrorMessage)
                        .ToList();


            string Ad = form["Adi"];
            string Soyad = form["Soyadi"];

            model.Adi = Ad;
            model.Soyadi = Soyad;
            ViewBag.Errors = errors;
            return View("Edit", model);
        }
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


            magazaElemani.Profilfoto = fileName;
        }

        magazaElemani.Adi = model.Adi;
        magazaElemani.Soyadi = model.Soyadi;

        if (model.Magazano != null) { magazaElemani.Magazano = model.Magazano; }
        try
        {
            if (ModelState.IsValid)
            {

                _context.Magazaelemanis.Add(magazaElemani);
                _context.SaveChanges();
                return RedirectToAction(nameof(Index));
            }
            _context.Magazaelemanis.Add(magazaElemani);
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


    public IActionResult Delete(int id)
    {
        var magazaElemani = _context.Magazaelemanis.Include(m => m.MagazanoNavigation).FirstOrDefault(k => k.Magazaelemanno == id);
        if (magazaElemani == null)
            return BadRequest();
        return View(magazaElemani);

    }


    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int id)
    {
        var magazaElemani = _context.Magazaelemanis.Include(m => m.MagazanoNavigation).FirstOrDefault(k => k.Magazaelemanno == id);
        try
        {
            _context.Magazaelemanis.Remove(magazaElemani);
            _context.SaveChanges(); // Trigger burada tetiklenir
            TempData["Message"] = "Magaza elemanı başarıyla silindi.";
        }
        catch (DbUpdateException ex)
        {
            if (ex.InnerException != null)
            {
                // Trigger'dan gelen mesaj
                TempData["Error"] = ex.InnerException.Message;
            }
            else
            {
                TempData["Error"] = ex.Message;
            }
        }

        return RedirectToAction("Index");

    }


}
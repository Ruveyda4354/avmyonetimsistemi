using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;

namespace VeriTabaniProje.Controllers;

public class AvmYoneticisiController : Controller
{
    private readonly AppDbContext _context;
    public AvmYoneticisiController(AppDbContext context)
    {
        _context = context;
    }

    public IActionResult Index()
    {
        var avmYoneticileri = _context.Avmyoneticisis.Include(m => m.Avm).ToList();
        return View(avmYoneticileri);
    }

    public IActionResult Edit(int id)
    {
        var avmYoneticisi = _context.Avmyoneticisis.Include(m => m.Avm).FirstOrDefault(k => k.Avmyoneticisino == id);
        if (avmYoneticisi == null)
            return NotFound();
        return View(avmYoneticisi);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, IFormCollection form, IFormFile Foto)
    {

        var avmYoneticisi = _context.Avmyoneticisis.FirstOrDefault(p => p.Avmyoneticisino == id);
        if (avmYoneticisi == null)
        {
            return NotFound();
        }
        string Ad = form["Ad"];
        string Soyad = form["Soyad"];


        avmYoneticisi.Adi = Ad;
        avmYoneticisi.Soyadi = Soyad;

        if (ModelState.IsValid)
        {
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


                avmYoneticisi.Profilfoto = fileName;
            }

            _context.Update(avmYoneticisi);
            _context.SaveChanges();
        }


        return RedirectToAction(nameof(Index));
    }


    public IActionResult Create()
    {
        var avmYoneticisi = new Avmyoneticisi
        {
            Avm = new Avm()

        };
        return View(avmYoneticisi);

    }
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(Avmyoneticisi avmYoneticisi, IFormFile Foto)
    {
        ModelState.Clear();

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
            avmYoneticisi.Profilfoto = fileName;
        }

        try
        {
            _context.Avmyoneticisis.Add(avmYoneticisi);

            await _context.SaveChangesAsync();

            return RedirectToAction(nameof(Index));
        }
        catch (DbUpdateException ex)
        {
            var hataMesaji = ex.InnerException != null ? ex.InnerException.Message : ex.Message;

            TempData["Error"] = "İşlem Engellendi: " + hataMesaji;

            return View(avmYoneticisi);
        }
        catch (Exception ex)
        {
            TempData["Error"] = "Bir hata oluştu: " + ex.Message;
            return View(avmYoneticisi);
        }
    }
    public IActionResult Delete(int id)
    {
        var avmYoneticisi = _context.Avmyoneticisis.Include(m => m.Avm).FirstOrDefault(k => k.Avmyoneticisino == id);
        if (avmYoneticisi == null)
            return BadRequest();
        return View(avmYoneticisi);

    }

    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int id)
    {
        var avmYoneticisi = _context.Avmyoneticisis.Find(id);


        try
        {
            if (ModelState.IsValid)
            {
                if (avmYoneticisi != null)
                {
                    _context.Remove(avmYoneticisi);
                    _context.SaveChanges();
                }
            }

        }
        catch (DbUpdateException ex) // EF Core exception
        {
            if (ex.InnerException != null)
            {
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
}

using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace VeriTabaniProje.Controllers;

public class MusteriController : Controller
{
    private readonly AppDbContext _context;
    public MusteriController(AppDbContext context)
    {
        _context = context;
    }

    public IActionResult Index(string search)
    {
        _context.ChangeTracker.Clear();
        var liste = _context.Musteris.AsQueryable();
        if (!string.IsNullOrEmpty(search))
        {
            search = search.ToLower();
            liste = liste
                .Where(p =>
                    p.Musterino.ToString().Contains(search) ||
                    p.Ad.ToLower().Contains(search) ||
                    p.Soyad.ToLower().Contains(search) ||
                    (p.Ad + " " + p.Soyad).ToLower().Contains(search));
        }
        return View(liste.OrderBy(p => p.Musterino).ToList());
    }

    public IActionResult Edit(int id)
    {
        var musteri = _context.Musteris.Find(id);
        if (musteri == null)
            return NotFound();
        ViewBag.AdSoyad = $"{musteri.Ad} {musteri.Soyad}";
        return View(musteri);
    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Edit(int id, IFormCollection form)
    {
        var Musteri = _context.Musteris.FirstOrDefault(p => p.Musterino == id);
        if (Musteri == null)
        {
            return NotFound();
        }
        string AdSoyad = form["AdSoyad"];
        var parts = AdSoyad.Split(' ', 2);
        Musteri.Ad = parts[0];
        Musteri.Soyad = parts.Length > 1 ? parts[1] : "";

        _context.Musteris.Update(Musteri);
        _context.SaveChanges();

        return RedirectToAction("Index");
    }


    public IActionResult Create()
    {
        var model = new MusteriEditViewModel
        {
        // Tüm mağazaları dropdown için getiriyoruz
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
    public async Task<IActionResult> Create(IFormCollection form, MusteriEditViewModel model)
    {
        if (!ModelState.IsValid)
    {
        // Hata varsa dropdown yeniden doldurulmalı
        model.MagazaList = _context.Magazas
            .Select(m => new SelectListItem
            {
                Value = m.Magazano.ToString(),
                Text = m.Adi
            })
            .ToList();
        return View(model);
    }

    var musteri = new Musteri
    {
        Ad = model.Ad,
        Soyad = model.Soyad
    };

    // Kullanıcının seçtiği mağazayı alıyoruz
    if (model.SecilenMagazaIdler != null && model.SecilenMagazaIdler.Length > 0)
    {
        var secilenMagaza =  await _context.Magazas
            .Where(m => model.SecilenMagazaIdler.Contains(m.Magazano))
            .ToListAsync();

        foreach (var magaza in secilenMagaza)
        {
            musteri.Magazanos.Add(magaza);
        }
    }

    _context.Musteris.Add(musteri);
     _context.SaveChanges();

    return RedirectToAction(nameof(Index));
    }


    public IActionResult Delete(int id)
    {
        var musteri = _context.Musteris.Find(id);
        if (musteri == null)
            return BadRequest();
        return View(musteri);

    }


    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int Musterino)
    {
        var musteri = _context.Musteris.Find(Musterino);
        if (musteri == null)
        {
            return BadRequest();
        }
       
        var kisi = _context.Kisis.FirstOrDefault(k =>
            k.Ad == musteri.Ad &&
            k.Soyad == musteri.Soyad &&
            k.Kisituru == "Müşteri");
        if (kisi != null)
        
            _context.Kisis.Remove(kisi);
        _context.Database.ExecuteSqlRaw(
            "DELETE FROM magazamusteri WHERE musterino= {0}", Musterino);
        _context.Musteris.Remove(musteri);
        _context.SaveChanges();

        return RedirectToAction("Index", "Musteri");
    }

}
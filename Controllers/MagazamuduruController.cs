using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;
namespace VeriTabaniProje.Controllers;

public class MagazamuduruController : Controller
{
    private readonly AppDbContext _context;
    public MagazamuduruController(AppDbContext context)
    {
        _context = context;
    }

    public IActionResult Index(string search)
    {
        _context.ChangeTracker.Clear();
        var magazaMudurleri = _context.Magazamudurus
                                .AsQueryable();
        if (!string.IsNullOrEmpty(search))
        {
            search = search.ToLower();
            magazaMudurleri = magazaMudurleri
                            .Where(m => m.Adi.Contains(search) ||
                            m.Soyadi.Contains(search) ||
                            (m.Adi + " " + m.Soyadi).ToLower().Contains(search));
        }
        var liste = magazaMudurleri.Include(m => m.Magaza)
                    .AsEnumerable()
                    .DistinctBy(m => m.Magazamuduruno)
                    .ToList();
        return View(liste);

    }
    public IActionResult Edit(int id)
    {
        var magazaMudur = _context.Magazamudurus.Include(m => m.Magaza).FirstOrDefault(k => k.Magazamuduruno == id);
        if (magazaMudur == null)
            return NotFound();
        return View(magazaMudur);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, IFormCollection form, IFormFile Foto)
    {
        var magazaMudur = _context.Magazamudurus.Include(m => m.Magaza).FirstOrDefault(p => p.Magazamuduruno == id);
        if (magazaMudur == null)
        {
            return NotFound();
        }
        string Ad = form["Ad"];
        string Soyad = form["Soyad"];

        magazaMudur.Adi = Ad;
        magazaMudur.Soyadi = Soyad;

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


            magazaMudur.Profilfoto = fileName;
        }
        _context.Update(magazaMudur);

        _context.SaveChanges();

        return RedirectToAction("Index");
    }
}
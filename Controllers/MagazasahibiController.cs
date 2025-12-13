using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Mvc.Rendering;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;

namespace VeriTabaniProje.Controllers;

public class MagazaSahibiController : Controller
{
    private readonly AppDbContext _context;
    public MagazaSahibiController(AppDbContext context)
    {
        _context = context;
    }

    public IActionResult Index(string search)
    {
        _context.ChangeTracker.Clear();
        var liste = _context.Magazasahibis.AsQueryable();
        if (!string.IsNullOrEmpty(search))
        {
            search = search.ToLower();
            liste = liste
                .Where(p =>
                    p.Magazasahibino.ToString().Contains(search) ||
                    p.Adi.ToLower().Contains(search) ||
                    p.Soyadi.ToLower().Contains(search) ||
                    (p.Adi + " " + p.Soyadi).ToLower().Contains(search));
        }
        return View(liste.OrderBy(p => p.Magazasahibino).Include(m => m.Magaza).ToList());

    }

    public IActionResult Edit(int id)
    {
        var magazaSahibi = _context.Magazasahibis.Include(m => m.Magaza).FirstOrDefault(m => m.Magazasahibino == id);
        if (magazaSahibi == null)
            return NotFound();
        return View(magazaSahibi);
    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, IFormCollection form, IFormFile Foto)
    {
        var magazaSahibi = _context.Magazasahibis.Include(k=>k.Magaza).FirstOrDefault(p => p.Magazasahibino == id);
        if (magazaSahibi == null)
        {
            return NotFound();
        }
        string Ad = form["Ad"];
        string Soyad = form["Soyad"];
        
        
        magazaSahibi.Adi = Ad;
        magazaSahibi.Soyadi = Soyad;
       
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


                magazaSahibi.Profilfoto = fileName;
            }

            
        
        _context.Update(magazaSahibi);
        _context.SaveChanges();
        return RedirectToAction(nameof(Index));
    }

}
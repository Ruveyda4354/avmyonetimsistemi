using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;

namespace VeriTabaniProje.Controllers;

public class KatController : Controller
{
    private readonly AppDbContext _context;
    public KatController(AppDbContext context)
    {
        _context = context;
    }

    public IActionResult Index(string search)
    {
        _context.ChangeTracker.Clear();

        var liste = _context.Kats
                    .Include(k => k.Magazas)
                    .Include(k => k.Personels)
                    .AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
        {
            if (int.TryParse(search, out int Katno))
            {
                liste = liste.Where(x => x.Katno == Katno);

            }
        }
        return View(liste.OrderBy(x=>x.Katno).ToList());
    }

    public IActionResult IndexKat(int id)
    {
        var kat = _context.Kats.Include(k => k.Personels).Include(k => k.Magazas).FirstOrDefault(k => k.Katno == id);
        if (kat == null)
            return NotFound();
        return View(kat);
    }

    public IActionResult Edit(int id)
    {
        var kat = _context.Kats.Include(k => k.Personels).FirstOrDefault(k => k.Katno == id);
        if (kat == null)
            return NotFound();
        return View(kat);
    }

    public IActionResult Create(int id)
    {
        var kat = _context.Kats.Find(id);
        if (kat == null)
            return NotFound();
        return View(kat);

    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Create(Kat kat)
    {
        if (ModelState.IsValid)
        {
            _context.Kats.Add(kat);
            _context.SaveChanges();
            return RedirectToAction(nameof(Index));
        }
        return View(kat);
    }


    public IActionResult Delete(int id)
    {
        var kat = _context.Kats.Include(k => k.Personels).FirstOrDefault(k => k.Katno == id);
        if (kat == null)
            return BadRequest();
        return View(kat);

    }



    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int personelId)
    {
        var personel = _context.Personels.Find(personelId);
        if (personel != null)
        {
            _context.Personels.Remove(personel);
            _context.SaveChanges();
        }

        // Silinen personelin katına yönlendirebilirsin
        return RedirectToAction(nameof(Index));
    }

}
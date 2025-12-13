using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;

namespace VeriTabaniProje.Controllers;

public class GiderController : Controller
{
    private readonly AppDbContext _context; 
    public GiderController(AppDbContext context)
    {
        _context = context;
    }

    public IActionResult Index(string search)
    {
        _context.ChangeTracker.Clear();
        var liste=_context.Giders
                            .Include(g=>g.MagazanoNavigation)
                            .AsQueryable();
		if (!string.IsNullOrEmpty(search))
		{
			liste=liste.Where(x=>x.MagazanoNavigation.Adi.Contains(search));
		}
        return View(liste.OrderBy(x=>x.MagazanoNavigation).ToList());
    }

    public IActionResult Edit(int id)
    {
        var gider = _context.Giders.Find(id);
        if (gider == null)      
            return NotFound();     
        return View(gider);
    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Edit(Gider gelenVeri)
    {
       var mevcutKayit =_context.Giders.Find(gelenVeri.Giderno);
        if(mevcutKayit != null)
        {
            mevcutKayit.Gidermiktari=gelenVeri.Gidermiktari;
            _context.SaveChanges();
            return RedirectToAction("Index");
        }
        return View(gelenVeri);
    }


    public IActionResult Create(int id)
    {
        var gider = _context.Giders.Find(id);
        if(gider == null)
            return NotFound();
        return View(gider);
    
    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Create(Gider gider)
    {
        if(ModelState.IsValid)
        {
            _context.Giders.Add(gider);
            _context.SaveChanges();
            return RedirectToAction(nameof(Index));
        }
        return View(gider);
    }


    public IActionResult Delete(int id)
    {
        var gider = _context.Giders.Find(id);
        if(gider == null)
            return BadRequest();
        return View(gider);
        
    }


    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int Giderno)
    {
        var kayit = _context.Giders.Find(Giderno);
        if(kayit == null)
        {        
            return BadRequest();
        }
        _context.Giders.Remove(kayit);
        _context.SaveChanges();

       return RedirectToAction("Index");
    }


}
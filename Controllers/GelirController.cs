using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;
using AspNetCoreGeneratedDocument;

namespace VeriTabaniProje.Controllers;

public class GelirController : Controller
{
    private readonly AppDbContext _context; 
    public GelirController(AppDbContext context)
    {
        _context = context;
    }

    public IActionResult Index(string search)
    {
        _context.ChangeTracker.Clear();

        var liste=_context.Gelirs
                        .Include(g=>g.MagazanoNavigation)
                        .AsQueryable();

		if (!string.IsNullOrEmpty(search))
		{
			liste = liste.Where(x=>x.MagazanoNavigation.Adi.Contains(search));
		}
        return View(liste.OrderBy(x=>x.MagazanoNavigation).ToList());
    }

    public IActionResult Edit(int id)
    {
        var gelir = _context.Gelirs.Find(id);
        if (gelir == null)      
            return NotFound();     
        return View(gelir);
    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Edit(Gelir gelenVeri)
    {
       var mevcutKayit =_context.Gelirs.Find(gelenVeri.Gelirno);
        if(mevcutKayit != null)
        {
            mevcutKayit.Gelirmiktari=gelenVeri.Gelirmiktari;
            _context.SaveChanges();
            return RedirectToAction("Index");
        }
        return View(gelenVeri);
    }


    public IActionResult Create(int id)
    {
        var gelir = _context.Gelirs.Find(id);
        if(gelir == null)
            return NotFound();
        return View(gelir);
    
    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Create(Gelir gelir)
    {
        if(ModelState.IsValid)
        {
            _context.Gelirs.Add(gelir);
            _context.SaveChanges();
            return RedirectToAction(nameof(Index));
        }
        return View(gelir);
    }


    public IActionResult Delete(int id)
    {
        var gelir = _context.Gelirs.Find(id);
        if(gelir == null)
            return BadRequest();
        return View(gelir);
        
    }


    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int Gelirno)
    {
        var kayit = _context.Gelirs.Find(Gelirno);
        if(kayit == null)
        {        
            return BadRequest();
        }
        _context.Gelirs.Remove(kayit);
        _context.SaveChanges();

       return RedirectToAction("Index");
    }


}
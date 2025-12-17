using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;
using System.ComponentModel;

namespace VeriTabaniProje.Controllers;

public class OtoparkController : Controller
{
    private readonly AppDbContext _context; 
    public OtoparkController(AppDbContext context)
    {
        _context = context;
    }

    public IActionResult Index(string search)
    {
        _context.ChangeTracker.Clear();
        var liste=_context.Otoparks.AsQueryable();
		if (!string.IsNullOrWhiteSpace(search))
		{
			if(int.TryParse(search,out int Katno))
			{
				liste=liste.Where(x=>x.Katno == Katno);
			}
		}
        return View(liste.OrderBy(x=>x.Katno).ToList());
    }

    public IActionResult Edit(int id)
    {
        var kayit = _context.Otoparks.Find(id);
        if (kayit == null)      
            return NotFound();     
        return View(kayit);
    }


    [HttpPost, ActionName("Edit")]
    [ValidateAntiForgeryToken]
    public IActionResult Edit2(Otopark gelenVeri)
    {
       var mevcut= _context.Otoparks.Find(gelenVeri.Otoparkno);

       if(mevcut != null)
		{
			mevcut.Otoparkkapasite = gelenVeri.Otoparkkapasite;

            _context.SaveChanges();

            return RedirectToAction("Index");
		}

        return View(gelenVeri);
    }


    public IActionResult Create(int id)
    {
        var otopark = _context.Otoparks.Find(id);
        if(otopark == null)
            return NotFound();
        return View(otopark);
    
    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Create(Otopark otopark)
    {
        if(ModelState.IsValid)
        {
            _context.Otoparks.Add(otopark);
            _context.SaveChanges();
            return RedirectToAction(nameof(Index));
        }
        return View(otopark);
    }


    public IActionResult Delete(int id)
    {
        var otopark = _context.Otoparks.Find(id);
        if(otopark == null)
            return BadRequest();
        return View(otopark);
        
    }


    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int id)
    {
        var otopark = _context.Otoparks.Find(id);
        if(otopark != null)
        {        
            _context.Remove(otopark);
            _context.SaveChanges();
        }
       return RedirectToAction(nameof(Index));
    }


}
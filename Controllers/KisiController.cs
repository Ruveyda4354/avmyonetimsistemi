using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;

namespace VeriTabaniProje.Controllers;

public class KisiController : Controller
{
    private readonly AppDbContext _context; 
    public KisiController(AppDbContext context)
    {
        _context = context;
    }

    public IActionResult Index()
    {
        var turler = _context.Kisis
                            .GroupBy(k=>k.Kisituru)
                            .Select(g=>new KisiTur
        {
			Kisituru = g.Key,
            Sayisi = g.Count()
		})
        .ToList();
        return View(turler);
    }

    public IActionResult Edit(int id)
    {
        var kisi = _context.Kisis.Find(id);
        if (kisi == null)      
            return NotFound();     
        return View(kisi);
    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Edit(int id, Kisi kisi)
    {
       
        if(id != kisi.Id)
        {
            return BadRequest();
        }
        if(ModelState.IsValid)
        {
            _context.Update(kisi);
            _context.SaveChanges();
            return RedirectToAction(nameof(Index));
        }
        return View(kisi);
    }


    public IActionResult Create(int id)
    {
        var kisi = _context.Kisis.Find(id);
        if(kisi == null)
            return NotFound();
        return View(kisi);
    
    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Create(Kisi kisi)
    {
        if(ModelState.IsValid)
        {
            _context.Kisis.Add(kisi);
            _context.SaveChanges();
            return RedirectToAction(nameof(Index));
        }
        return View(kisi);
    }


    public IActionResult Delete(int id)
    {
        var kisi = _context.Kisis.Find(id);
        if(kisi == null)
            return BadRequest();
        return View(kisi);
        
    }


    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int id)
    {
        var kisi = _context.Kisis.Find(id);
        if(kisi != null)
        {        
            _context.Remove(kisi);
            _context.SaveChanges();
        }
       return RedirectToAction(nameof(Index));
    }

}
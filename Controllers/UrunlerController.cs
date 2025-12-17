using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;

namespace VeriTabaniProje.Controllers;

public class UrunlerController : Controller
{
    private readonly AppDbContext _context; 
    public UrunlerController(AppDbContext context)
    {
        _context = context;
    }

    public IActionResult Index()
    {
        var urunler = _context.Urunlers.ToList();
        return View(urunler);
    }

    public IActionResult Edit(int id)
    {
        var urun = _context.Urunlers.Find(id);
        if (urun == null)      
            return NotFound();     
        return View(urun);
    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Edit(int id, Urunler urun)
    {
       
        if(id != urun.Urunno)
        {
            return BadRequest();
        }
        if(ModelState.IsValid)
        {
            _context.Update(urun);
            _context.SaveChanges();
            return RedirectToAction(nameof(Index));
        }
        return View(urun);
    }


    public IActionResult Create(int id)
    {
        var urun = _context.Urunlers.Find(id);
        if(urun == null)
            return NotFound();
        return View(urun);
    
    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Create(Urunler urun)
    {
        if(ModelState.IsValid)
        {
            _context.Urunlers.Add(urun);
            _context.SaveChanges();
            return RedirectToAction(nameof(Index));
        }
        return View(urun);
    }


    public IActionResult Delete(int id)
    {
        var urun = _context.Urunlers.Find(id);
        if(urun == null)
            return BadRequest();
        return View(urun);
        
    }


    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int id)
    {
        var urun = _context.Urunlers.Find(id);
        if(urun != null)
        {        
            _context.Remove(urun);
            _context.SaveChanges();
        }
       return RedirectToAction(nameof(Index));
    }


}
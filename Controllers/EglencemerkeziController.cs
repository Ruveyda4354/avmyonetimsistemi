using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;
using VeriTabaniProje.Data;

namespace VeriTabaniProje.Controllers;

public class EglencemerkeziController : Controller
{
    private readonly AppDbContext _context;
    public EglencemerkeziController(AppDbContext context)
    {
        _context = context;
    }

    public IActionResult Index(string search)
    {
        _context.ChangeTracker.Clear();

        var liste = _context.Eglencemerkezis.AsQueryable();

        if (!string.IsNullOrEmpty(search))
        {
            liste = liste.Where(x => x.Oyuncaklar.Contains(search));
        }

        return View(liste.OrderBy(x => x.Oyuncakno).ToList());
    }

    public IActionResult Edit(int id)
    {
        var eglenceMerkezi = _context.Eglencemerkezis.Find(id);
        if (eglenceMerkezi == null)
            return NotFound();
        return View(eglenceMerkezi);
    }


    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Edit2(Eglencemerkezi gelenVeri)
    {
        var mevcutKayit = _context.Eglencemerkezis.Find(gelenVeri.Oyuncakno);
        if (mevcutKayit != null)
        {
            mevcutKayit.Oyuncaklar = gelenVeri.Oyuncaklar;
            _context.SaveChanges();
            return RedirectToAction("Index");
        }
        return View(gelenVeri);
    }
    public IActionResult Create()
    {
        int sonOyuncakno = _context.Eglencemerkezis
                        .OrderByDescending(x => x.Oyuncakno)
                        .Select(x => x.Oyuncakno)
                        .FirstOrDefault();
        var model = new Eglencemerkezi
        {
            Avmno = 1,
            Katno = 2,
            Eglencemerkezino = 1,
            Oyuncakno = sonOyuncakno + 1
        };
        return View(model);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Create(Eglencemerkezi yeni)
    {
        ModelState.Remove("AvmnoNavigation");
        if (ModelState.IsValid)
        {
            _context.Eglencemerkezis.Add(yeni);
            _context.SaveChanges();
            return RedirectToAction("Index");
        }
        return View(yeni);
    }

    public IActionResult Delete(int id)
    {
        var kayit = _context.Eglencemerkezis.Find(id);
        if (kayit == null)
            return BadRequest();
        return View(kayit);

    }


    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed(int Oyuncakno)
    {
        var kayit = _context.Eglencemerkezis.Find(Oyuncakno);

        if (kayit == null)
        {
            return BadRequest();
        }
        _context.Eglencemerkezis.Remove(kayit);
        _context.SaveChanges();

        return RedirectToAction("Index");
    }
}
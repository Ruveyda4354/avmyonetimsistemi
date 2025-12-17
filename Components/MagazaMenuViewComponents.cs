using Microsoft.AspNetCore.Mvc;
using VeriTabaniProje.Data;

namespace VeriTabaniProje.Components;
public class MagazaMenuViewComponent: ViewComponent
{
    private readonly AppDbContext _db;

    public MagazaMenuViewComponent(AppDbContext db)
    {
        _db = db;
    }

    public IViewComponentResult Invoke()
    {
        var magazalar = _db.Magazas.ToList();
        Console.WriteLine(magazalar.Count); 
        return View(magazalar);
    }
}
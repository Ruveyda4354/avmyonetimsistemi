namespace VeriTabaniProje.Models;
using Microsoft.AspNetCore.Mvc.Rendering;

public class TedarikciEditViewModel
{
    public int Id { get; set; }
    public string Adi { get; set; }
    public string Soyadi { get; set; }

    public int Magazano{get;set;}
    public string? Profilfoto { get; set; }

    public List<int> SecilenMagazaIdList { get; set; } = new();  // <<< Burası önemli
    public List<SelectListItem>? MagazaList { get; set; }
}

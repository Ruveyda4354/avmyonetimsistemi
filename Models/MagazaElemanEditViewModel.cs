namespace VeriTabaniProje.Models;
using Microsoft.AspNetCore.Mvc.Rendering;

public class MagazaElemanEditViewModel
{
    public int Id{get; set;}
    public string Adi{get; set;}= null!;

    public string Soyadi{get; set;}= null!;

    public int Magazano {get;set;}
    public string? Profilfoto {get; set;}

    public List<SelectListItem>? MagazaList{get; set;}
}
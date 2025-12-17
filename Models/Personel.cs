using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Personel
{
    public int Personelno { get; set; }

    public string? Adi { get; set; }

    public string? Soyadi { get; set; }

    public int? Katno { get; set; }

    public int Kisino { get; set; }

    public string? Profilfoto { get; set; }

    public virtual Kat? KatnoNavigation { get; set; }

    public virtual Kisi KisinoNavigation { get; set; } = null!;
}
using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Magazamuduru
{
    public int Magazamuduruno { get; set; }

    public string? Adi { get; set; }

    public string? Soyadi { get; set; }

    public int Kisino { get; set; }

    public string? Profilfoto { get; set; }

    public virtual Kisi KisinoNavigation { get; set; } = null!;

    public virtual Magaza? Magaza { get; set; }
}
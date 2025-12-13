using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Avmyoneticisi
{
    public int Avmyoneticisino { get; set; }

    public string Adi { get; set; } = null!;

    public string Soyadi { get; set; } = null!;

    public int Kisino { get; set; }

    public string? Profilfoto { get; set; }

    public virtual Avm? Avm { get; set; }

    public virtual Kisi KisinoNavigation { get; set; } = null!;
}

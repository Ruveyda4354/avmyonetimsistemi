using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Magazaelemani
{
    public int Magazaelemanno { get; set; }

    public string Adi { get; set; } = null!;

    public string Soyadi { get; set; } = null!;

    public int Magazano { get; set; }

    public int Kisino { get; set; }

    public string? Profilfoto { get; set; }

    public virtual Kisi KisinoNavigation { get; set; } = null!;

    public virtual Magaza MagazanoNavigation { get; set; } = null!;
}

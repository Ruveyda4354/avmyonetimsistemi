using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Musteri
{
    public int Musterino { get; set; }

    public string? Ad { get; set; }

    public string? Soyad { get; set; }

    public int Kisino { get; set; }

    public virtual Kisi KisinoNavigation { get; set; } = null!;

    public virtual ICollection<Magaza> Magazanos { get; set; } = new List<Magaza>();
}

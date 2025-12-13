using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Urunler
{
    public int Urunno { get; set; }

    public string? Adi { get; set; }

    public int? Fiyat { get; set; }

    public int? Stok { get; set; }

    public virtual ICollection<Magaza> Magazanos { get; set; } = new List<Magaza>();
}

using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Kat
{
    public int Katno { get; set; }

    public int Avmno { get; set; }

    public virtual Avm AvmnoNavigation { get; set; } = null!;

    public virtual ICollection<Magaza> Magazas { get; set; } = new List<Magaza>();

    public virtual ICollection<Otopark> Otoparks { get; set; } = new List<Otopark>();

    public virtual ICollection<Personel> Personels { get; set; } = new List<Personel>();
}

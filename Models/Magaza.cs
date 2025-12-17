using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Magaza
{
    public int Magazano { get; set; }

    public string Adi { get; set; } = null!;

    public int Katno { get; set; }

    public int Magazamuduruno { get; set; }

    public int Magazasahibino { get; set; }

    public virtual Gelir? Gelir { get; set; }

    public virtual Gider? Gider { get; set; }

    public virtual Kat KatnoNavigation { get; set; } = null!;

    public virtual ICollection<Magazaelemani> Magazaelemanis { get; set; } = new List<Magazaelemani>();

    public virtual Magazamuduru MagazamudurunoNavigation { get; set; } = null!;

    public virtual Magazasahibi MagazasahibinoNavigation { get; set; } = null!;

    public virtual ICollection<Musteri> Musterinos { get; set; } = new List<Musteri>();

    public virtual ICollection<Tedarikci> Tedarikcinos { get; set; } = new List<Tedarikci>();

    public virtual ICollection<Urunler> Urunnos { get; set; } = new List<Urunler>();
}
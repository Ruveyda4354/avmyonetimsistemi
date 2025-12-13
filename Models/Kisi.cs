using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Kisi
{
    public int Id { get; set; }

    public string Ad { get; set; } = null!;

    public string Soyad { get; set; } = null!;

    public string Kisituru { get; set; } = null!;

    public virtual ICollection<Avmyoneticisi> Avmyoneticisis { get; set; } = new List<Avmyoneticisi>();

    public virtual ICollection<Magazaelemani> Magazaelemanis { get; set; } = new List<Magazaelemani>();

    public virtual ICollection<Magazamuduru> Magazamudurus { get; set; } = new List<Magazamuduru>();

    public virtual ICollection<Magazasahibi> Magazasahibis { get; set; } = new List<Magazasahibi>();

    public virtual ICollection<Musteri> Musteris { get; set; } = new List<Musteri>();

    public virtual ICollection<Personel> Personels { get; set; } = new List<Personel>();

    public virtual ICollection<Tedarikci> Tedarikcis { get; set; } = new List<Tedarikci>();
}

using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Avm
{
    public int Avmno { get; set; }

    public string Adi { get; set; } = null!;

    public int Avmyoneticisino { get; set; }

    public virtual Avmyoneticisi AvmyoneticisinoNavigation { get; set; } = null!;

    public virtual ICollection<Eglencemerkezi> Eglencemerkezis { get; set; } = new List<Eglencemerkezi>();

    public virtual ICollection<Kat> Kats { get; set; } = new List<Kat>();

    public virtual ICollection<Otopark> Otoparks { get; set; } = new List<Otopark>();
}
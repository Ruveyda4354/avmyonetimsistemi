using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Eglencemerkezi
{
    public int Oyuncakno { get; set; }

    public int Avmno { get; set; }

    public int Katno { get; set; }

    public int Eglencemerkezino { get; set; }

    public string Oyuncaklar { get; set; } = null!;

    public virtual Avm AvmnoNavigation { get; set; } = null!;
}
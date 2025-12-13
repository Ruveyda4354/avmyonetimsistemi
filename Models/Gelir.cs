using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Gelir
{
    public int Gelirno { get; set; }

    public int Gelirmiktari { get; set; }

    public int Magazano { get; set; }

    public virtual Magaza MagazanoNavigation { get; set; } = null!;
}

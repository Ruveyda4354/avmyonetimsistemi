using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Gider
{
    public int Giderno { get; set; }

    public int Gidermiktari { get; set; }

    public int Magazano { get; set; }

    public virtual Magaza MagazanoNavigation { get; set; } = null!;
}

using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Otopark
{
    public int Otoparkno { get; set; }

    public int? Avmno { get; set; }

    public int? Katno { get; set; }

    public int? Otoparkkapasite { get; set; }

    public virtual Avm? AvmnoNavigation { get; set; }

    public virtual Kat? KatnoNavigation { get; set; }
}

using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Magazamusteri
{
    public int Musterino { get; set; }
    public int Magazano { get; set; }
    public virtual Magaza Magaza { get; set; }
    public virtual Musteri Musteri { get; set; }
}

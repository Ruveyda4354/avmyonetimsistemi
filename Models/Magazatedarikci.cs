using System;
using System.Collections.Generic;

namespace VeriTabaniProje.Models;

public partial class Magazatedarikci
{
    public int Tedarikcino { get; set; }

    public int Magazano { get; set; }

    public virtual Tedarikci Tedarikci {get; set;}

    public virtual Magaza Magaza {get; set;}
}

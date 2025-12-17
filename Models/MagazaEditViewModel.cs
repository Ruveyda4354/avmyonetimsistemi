using Microsoft.AspNetCore.Mvc.Rendering;
using System.Collections.Generic;

namespace VeriTabaniProje.Models
{
    public class MagazaEditViewModel
    {
        public int Magazano { get; set; }
        public string Adi { get; set; } = "";
        public int Katno { get; set; }

        public Gelir? Gelir { get; set; }
        public Gider? Gider { get; set; }

        public Magazamuduru MagazamudurunoNavigation { get; set; } = null!;
        public Magazasahibi MagazasahibinoNavigation { get; set; } = null!;
        public List<Magazaelemani> Magazaelemanis { get; set; } = new();

        public List<MagazaUrunItem> UrunListesi { get; set; } = new();
    }

    public class MagazaUrunItem
    {
        public int UrunId { get; set; }
        public string UrunAdi { get; set; } = "";
        public int Stok { get; set; }
        public bool SeciliMi { get; set; }

		public int Fiyat{get;set;}
    }
}
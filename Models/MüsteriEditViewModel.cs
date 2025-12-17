using Microsoft.AspNetCore.Mvc.Rendering;
using System.Collections.Generic;

namespace VeriTabaniProje.Models
{
    public class MusteriEditViewModel
    {
        // Müşteri ID
        public int Id { get; set; }

        // Müşteri adı
        public string Ad { get; set; }

        // Müşteri soyadı
        public string Soyad { get; set; }

        // Form üzerinden seçilen mağaza(lar) - çoktan çoka için array
        public int[] SecilenMagazaIdler { get; set; } = new int[0];

        // Mağaza seçimleri için dropdown listesi
        public List<SelectListItem> MagazaList { get; set; } = new List<SelectListItem>();

        // Opsiyonel: Tüm mağazalar ile ilişki kurmak için işaretleyebilirsin
        public bool TumMagazalar { get; set; } = false;
    }
}
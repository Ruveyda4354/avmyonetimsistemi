using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;

namespace VeriTabaniProje.Data;

public partial class AppDbContext : DbContext
{
    public AppDbContext()
    {
    }

    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Avm> Avms { get; set; }

    public virtual DbSet<Avmyoneticisi> Avmyoneticisis { get; set; }

    public virtual DbSet<Eglencemerkezi> Eglencemerkezis { get; set; }

    public virtual DbSet<Gelir> Gelirs { get; set; }

    public virtual DbSet<Gider> Giders { get; set; }

    public virtual DbSet<Kat> Kats { get; set; }

    public virtual DbSet<Kisi> Kisis { get; set; }

    public virtual DbSet<Magaza> Magazas { get; set; }

    public virtual DbSet<Magazaelemani> Magazaelemanis { get; set; }

    public virtual DbSet<Magazamuduru> Magazamudurus { get; set; }

    public virtual DbSet<Magazasahibi> Magazasahibis { get; set; }

    public virtual DbSet<Musteri> Musteris { get; set; }

    public virtual DbSet<Otopark> Otoparks { get; set; }

    public virtual DbSet<Personel> Personels { get; set; }

    public virtual DbSet<Tedarikci> Tedarikcis { get; set; }

    public virtual DbSet<Urunler> Urunlers { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseNpgsql("Host=localhost;Port=5432;Database=AvmYonetimSistemi;Username=postgres;Password=RA..20.06.;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Avm>(entity =>
        {
            entity.HasKey(e => e.Avmno).HasName("avm_pkey");

            entity.ToTable("avm");

            entity.HasIndex(e => e.Adi, "avm_adi_idx");

            entity.HasIndex(e => e.Adi, "avm_adi_key").IsUnique();

            entity.HasIndex(e => e.Avmyoneticisino, "uq_avm_avmyoneticisi").IsUnique();

            entity.Property(e => e.Avmno).HasColumnName("avmno");
            entity.Property(e => e.Adi)
                .HasMaxLength(15)
                .HasColumnName("adi");
            entity.Property(e => e.Avmyoneticisino).HasColumnName("avmyoneticisino");

            entity.HasOne(d => d.AvmyoneticisinoNavigation).WithOne(p => p.Avm)
                .HasForeignKey<Avm>(d => d.Avmyoneticisino)
                .HasConstraintName("fk_avm_avmyoneticisino");
        });

        modelBuilder.Entity<Avmyoneticisi>(entity =>
        {
            entity.HasKey(e => e.Avmyoneticisino).HasName("avmyoneticisi_pkey");

            entity.ToTable("avmyoneticisi");

            entity.HasIndex(e => e.Adi, "avmyoneticisi_adi_idx");

            entity.HasIndex(e => e.Adi, "avmyoneticisi_adi_key").IsUnique();

            entity.HasIndex(e => e.Profilfoto, "index_profilfoto1");

            entity.Property(e => e.Avmyoneticisino).HasColumnName("avmyoneticisino");
            entity.Property(e => e.Adi)
                .HasMaxLength(15)
                .HasColumnName("adi");
            entity.Property(e => e.Kisino).HasColumnName("kisino");
            entity.Property(e => e.Profilfoto)
                .HasMaxLength(100)
                .HasColumnName("profilfoto");
            entity.Property(e => e.Soyadi)
                .HasMaxLength(20)
                .HasColumnName("soyadi");

            entity.HasOne(d => d.KisinoNavigation).WithMany(p => p.Avmyoneticisis)
                .HasForeignKey(d => d.Kisino)
                .HasConstraintName("fk_avmyoneticisi_kisino");
        });

        modelBuilder.Entity<Eglencemerkezi>(entity =>
        {
            entity.HasKey(e => e.Oyuncakno).HasName("eglencemerkezi_pkey");

            entity.ToTable("eglencemerkezi");

            entity.HasIndex(e => e.Avmno, "eglencemerkezi_avmno_idx");

            entity.HasIndex(e => e.Eglencemerkezino, "eglencemerkezi_eglencemerkezino_idx");

            entity.HasIndex(e => e.Oyuncaklar, "eglencemerkezi_oyuncaklar_idx");

            entity.HasIndex(e => e.Oyuncaklar, "eglencemerkezi_oyuncaklar_key").IsUnique();

            entity.Property(e => e.Oyuncakno)
                .HasDefaultValueSql("nextval('eglencemerkezi_eglencemerkezino_seq'::regclass)")
                .HasColumnName("oyuncakno");
            entity.Property(e => e.Avmno).HasColumnName("avmno");
            entity.Property(e => e.Eglencemerkezino).HasColumnName("eglencemerkezino");
            entity.Property(e => e.Katno).HasColumnName("katno");
            entity.Property(e => e.Oyuncaklar)
                .HasColumnType("character varying")
                .HasColumnName("oyuncaklar");

            entity.HasOne(d => d.AvmnoNavigation).WithMany(p => p.Eglencemerkezis)
                .HasForeignKey(d => d.Avmno)
                .HasConstraintName("fk_eglencemerkezi_avm");
        });

        modelBuilder.Entity<Gelir>(entity =>
        {
            entity.HasKey(e => e.Gelirno).HasName("gelir_pkey");

            entity.ToTable("gelir");

            entity.HasIndex(e => e.Gelirmiktari, "gelir_gelirmiktari_idx");

            entity.HasIndex(e => e.Magazano, "uq_gelir_magazano").IsUnique();

            entity.Property(e => e.Gelirno).HasColumnName("gelirno");
            entity.Property(e => e.Gelirmiktari).HasColumnName("gelirmiktari");
            entity.Property(e => e.Magazano).HasColumnName("magazano");

            entity.HasOne(d => d.MagazanoNavigation).WithOne(p => p.Gelir)
                .HasForeignKey<Gelir>(d => d.Magazano)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_gelir_magaza");
        });

        modelBuilder.Entity<Gider>(entity =>
        {
            entity.HasKey(e => e.Giderno).HasName("gider_pkey");

            entity.ToTable("gider");

            entity.HasIndex(e => e.Gidermiktari, "gider_gidermiktari_idx");

            entity.HasIndex(e => e.Magazano, "gider_magazano_idx");

            entity.HasIndex(e => e.Magazano, "gider_magazano_key").IsUnique();

            entity.Property(e => e.Giderno).HasColumnName("giderno");
            entity.Property(e => e.Gidermiktari).HasColumnName("gidermiktari");
            entity.Property(e => e.Magazano).HasColumnName("magazano");

            entity.HasOne(d => d.MagazanoNavigation).WithOne(p => p.Gider)
                .HasForeignKey<Gider>(d => d.Magazano)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_gider_magaza");
        });

        modelBuilder.Entity<Kat>(entity =>
        {
            entity.HasKey(e => e.Katno).HasName("kat_pkey");

            entity.ToTable("kat");

            entity.HasIndex(e => e.Avmno, "kat_avmno_idx");

            entity.Property(e => e.Katno).HasColumnName("katno");
            entity.Property(e => e.Avmno).HasColumnName("avmno");

            entity.HasOne(d => d.AvmnoNavigation).WithMany(p => p.Kats)
                .HasForeignKey(d => d.Avmno)
                .HasConstraintName("fk_kat_avm");
        });

        modelBuilder.Entity<Kisi>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("kisi_pkey");

            entity.ToTable("kisi");

            entity.HasIndex(e => e.Ad, "kisi_ad_idx");

            entity.HasIndex(e => e.Kisituru, "kisi_kisituru_idx");

            entity.HasIndex(e => e.Soyad, "kisi_soyad_idx");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Ad)
                .HasMaxLength(15)
                .HasColumnName("ad");
            entity.Property(e => e.Kisituru)
                .HasMaxLength(15)
                .HasColumnName("kisituru");
            entity.Property(e => e.Soyad)
                .HasMaxLength(20)
                .HasColumnName("soyad");
        });

        modelBuilder.Entity<Magaza>(entity =>
        {
            entity.HasKey(e => e.Magazano).HasName("magaza_pkey");

            entity.ToTable("magaza");

            entity.HasIndex(e => e.Adi, "magaza_adi_idx");

            entity.HasIndex(e => e.Adi, "magaza_adi_key").IsUnique();

            entity.HasIndex(e => e.Katno, "magaza_katno_idx");

            entity.HasIndex(e => e.Magazamuduruno, "magaza_magazamuduruno_idx");

            entity.HasIndex(e => e.Magazamuduruno, "magaza_magazamuduruno_key").IsUnique();

            entity.HasIndex(e => new { e.Katno, e.Adi }, "uq_magaza_adi").IsUnique();

            entity.HasIndex(e => e.Magazasahibino, "uq_magaza_magazasahibino").IsUnique();

            entity.HasIndex(e => e.Magazasahibino, "uq_magazasahibi").IsUnique();

            entity.Property(e => e.Magazano).HasColumnName("magazano");
            entity.Property(e => e.Adi)
                .HasMaxLength(20)
                .HasColumnName("adi");
            entity.Property(e => e.Katno).HasColumnName("katno");
            entity.Property(e => e.Magazamuduruno).HasColumnName("magazamuduruno");
            entity.Property(e => e.Magazasahibino).HasColumnName("magazasahibino");

            entity.HasOne(d => d.KatnoNavigation).WithMany(p => p.Magazas)
                .HasForeignKey(d => d.Katno)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("katno");

            entity.HasOne(d => d.MagazamudurunoNavigation).WithOne(p => p.Magaza)
                .HasForeignKey<Magaza>(d => d.Magazamuduruno)
                .HasConstraintName("fk_magaza_magazamuduruno");

            entity.HasOne(d => d.MagazasahibinoNavigation).WithOne(p => p.Magaza)
                .HasForeignKey<Magaza>(d => d.Magazasahibino)
                .HasConstraintName("fk_magaza_magazasahibi");

            entity.HasMany(d => d.Urunnos).WithMany(p => p.Magazanos)
                .UsingEntity<Dictionary<string, object>>(
                    "Magazaurun",
                    r => r.HasOne<Urunler>().WithMany()
                        .HasForeignKey("Urunno")
                        .HasConstraintName("fk_magazaurun_urunno"),
                    l => l.HasOne<Magaza>().WithMany()
                        .HasForeignKey("Magazano")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("magazaurun_magazano_fkey"),
                    j =>
                    {
                        j.HasKey("Magazano", "Urunno").HasName("magazaurun_pkey");
                        j.ToTable("magazaurun");
                        j.IndexerProperty<int>("Magazano").HasColumnName("magazano");
                        j.IndexerProperty<int>("Urunno").HasColumnName("urunno");
                    });
        });

        modelBuilder.Entity<Magazaelemani>(entity =>
        {
            entity.HasKey(e => e.Magazaelemanno).HasName("magazaelemani_pkey");

            entity.ToTable("magazaelemani");

            entity.HasIndex(e => e.Profilfoto, "index_profilfoto");

            entity.HasIndex(e => e.Adi, "magazaelemani_adi_idx");

            entity.HasIndex(e => e.Magazano, "magazaelemani_magazano_idx");

            entity.HasIndex(e => e.Soyadi, "magazaelemani_soyadi_idx");

            entity.Property(e => e.Magazaelemanno).HasColumnName("magazaelemanno");
            entity.Property(e => e.Adi)
                .HasMaxLength(15)
                .HasColumnName("adi");
            entity.Property(e => e.Kisino).HasColumnName("kisino");
            entity.Property(e => e.Magazano).HasColumnName("magazano");
            entity.Property(e => e.Profilfoto)
                .HasMaxLength(100)
                .HasColumnName("profilfoto");
            entity.Property(e => e.Soyadi)
                .HasMaxLength(20)
                .HasColumnName("soyadi");

            entity.HasOne(d => d.KisinoNavigation).WithMany(p => p.Magazaelemanis)
                .HasForeignKey(d => d.Kisino)
                .HasConstraintName("fk_magazaelemani_kisino");

            entity.HasOne(d => d.MagazanoNavigation).WithMany(p => p.Magazaelemanis)
                .HasForeignKey(d => d.Magazano)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_magazaelemani_magaza");
        });

        modelBuilder.Entity<Magazamuduru>(entity =>
        {
            entity.HasKey(e => e.Magazamuduruno).HasName("magazamuduru_pkey");

            entity.ToTable("magazamuduru");

            entity.HasIndex(e => e.Profilfoto, "index_profilfoto2");

            entity.Property(e => e.Magazamuduruno).HasColumnName("magazamuduruno");
            entity.Property(e => e.Adi)
                .HasMaxLength(15)
                .HasColumnName("adi");
            entity.Property(e => e.Kisino).HasColumnName("kisino");
            entity.Property(e => e.Profilfoto)
                .HasMaxLength(100)
                .HasColumnName("profilfoto");
            entity.Property(e => e.Soyadi)
                .HasMaxLength(20)
                .HasColumnName("soyadi");

            entity.HasOne(d => d.KisinoNavigation).WithMany(p => p.Magazamudurus)
                .HasForeignKey(d => d.Kisino)
                .HasConstraintName("fk_magazamuduru_kisino");
        });

        modelBuilder.Entity<Magazasahibi>(entity =>
        {
            entity.HasKey(e => e.Magazasahibino).HasName("magazasahibi_pkey");

            entity.ToTable("magazasahibi");

            entity.HasIndex(e => e.Profilfoto, "index_profilfoto3");

            entity.Property(e => e.Magazasahibino).HasColumnName("magazasahibino");
            entity.Property(e => e.Adi)
                .HasMaxLength(15)
                .HasColumnName("adi");
            entity.Property(e => e.Kisino).HasColumnName("kisino");
            entity.Property(e => e.Profilfoto)
                .HasMaxLength(100)
                .HasColumnName("profilfoto");
            entity.Property(e => e.Soyadi)
                .HasMaxLength(20)
                .HasColumnName("soyadi");

            entity.HasOne(d => d.KisinoNavigation).WithMany(p => p.Magazasahibis)
                .HasForeignKey(d => d.Kisino)
                .HasConstraintName("fk_magazasahibi_kisino");
        });

        modelBuilder.Entity<Musteri>(entity =>
        {
            entity.HasKey(e => e.Musterino).HasName("musteri_pkey");

            entity.ToTable("musteri");

            entity.Property(e => e.Musterino).HasColumnName("musterino");
            entity.Property(e => e.Ad)
                .HasMaxLength(15)
                .HasColumnName("ad");
            entity.Property(e => e.Kisino).HasColumnName("kisino");
            entity.Property(e => e.Soyad)
                .HasMaxLength(20)
                .HasColumnName("soyad");

            entity.HasOne(d => d.KisinoNavigation).WithMany(p => p.Musteris)
                .HasForeignKey(d => d.Kisino)
                .HasConstraintName("fk_musteri_kisino");

            entity.HasMany(d => d.Magazanos).WithMany(p => p.Musterinos)
                .UsingEntity<Dictionary<string, object>>(
                    "Magazamusteri",
                    r => r.HasOne<Magaza>().WithMany()
                        .HasForeignKey("Magazano")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("magazamusteri_magazano_fkey"),
                    l => l.HasOne<Musteri>().WithMany()
                        .HasForeignKey("Musterino")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("magazamusteri_musterino_fkey"),
                    j =>
                    {
                        j.HasKey("Musterino", "Magazano").HasName("magazamusteri_pkey");
                        j.ToTable("magazamusteri");
                        j.IndexerProperty<int>("Musterino").HasColumnName("musterino");
                        j.IndexerProperty<int>("Magazano").HasColumnName("magazano");
                    });
        });

        modelBuilder.Entity<Otopark>(entity =>
        {
            entity.HasKey(e => e.Otoparkno).HasName("otopark_pkey");

            entity.ToTable("otopark");

            entity.Property(e => e.Otoparkno).HasColumnName("otoparkno");
            entity.Property(e => e.Avmno).HasColumnName("avmno");
            entity.Property(e => e.Katno).HasColumnName("katno");
            entity.Property(e => e.Otoparkkapasite).HasColumnName("otoparkkapasite");

            entity.HasOne(d => d.AvmnoNavigation).WithMany(p => p.Otoparks)
                .HasForeignKey(d => d.Avmno)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("fk_otopark_avm");

            entity.HasOne(d => d.KatnoNavigation).WithMany(p => p.Otoparks)
                .HasForeignKey(d => d.Katno)
                .HasConstraintName("fk_otopark_kat");
        });

        modelBuilder.Entity<Personel>(entity =>
        {
            entity.HasKey(e => e.Personelno).HasName("personel_pkey");

            entity.ToTable("personel");

            entity.HasIndex(e => e.Profilfoto, "index_profilfoto4");

            entity.Property(e => e.Personelno).HasColumnName("personelno");
            entity.Property(e => e.Adi)
                .HasMaxLength(15)
                .HasColumnName("adi");
            entity.Property(e => e.Katno).HasColumnName("katno");
            entity.Property(e => e.Kisino).HasColumnName("kisino");
            entity.Property(e => e.Profilfoto)
                .HasMaxLength(100)
                .HasColumnName("profilfoto");
            entity.Property(e => e.Soyadi)
                .HasMaxLength(20)
                .HasColumnName("soyadi");

            entity.HasOne(d => d.KatnoNavigation).WithMany(p => p.Personels)
                .HasForeignKey(d => d.Katno)
                .HasConstraintName("katno");

            entity.HasOne(d => d.KisinoNavigation).WithMany(p => p.Personels)
                .HasForeignKey(d => d.Kisino)
                .HasConstraintName("fk_personel_kisino");
        });

        modelBuilder.Entity<Tedarikci>(entity =>
        {
            entity.HasKey(e => e.Tedarikcino).HasName("tedarikci_pkey");

            entity.ToTable("tedarikci");

            entity.HasIndex(e => e.Profilfoto, "index_profilfoto5");

            entity.Property(e => e.Tedarikcino)
                .HasDefaultValueSql("nextval('tedarikci_id_seq'::regclass)")
                .HasColumnName("tedarikcino");
            entity.Property(e => e.Adi)
                .HasMaxLength(15)
                .HasColumnName("adi");
            entity.Property(e => e.Kisino).HasColumnName("kisino");
            entity.Property(e => e.Profilfoto)
                .HasMaxLength(100)
                .HasColumnName("profilfoto");
            entity.Property(e => e.Soyadi)
                .HasMaxLength(20)
                .HasColumnName("soyadi");

            entity.HasOne(d => d.KisinoNavigation).WithMany(p => p.Tedarikcis)
                .HasForeignKey(d => d.Kisino)
                .HasConstraintName("fk_tedarikci_kisino");

            entity.HasMany(d => d.Magazanos).WithMany(p => p.Tedarikcinos)
                .UsingEntity<Dictionary<string, object>>(
                    "Magazatedarikci",
                    r => r.HasOne<Magaza>().WithMany()
                        .HasForeignKey("Magazano")
                        .HasConstraintName("fk_magazatedarikci_magazano"),
                    l => l.HasOne<Tedarikci>().WithMany()
                        .HasForeignKey("Tedarikcino")
                        .HasConstraintName("fk_magazatedarikci_tedarikcino"),
                    j =>
                    {
                        j.HasKey("Tedarikcino", "Magazano").HasName("magazatedarikci_pkey");
                        j.ToTable("magazatedarikci");
                        j.IndexerProperty<int>("Tedarikcino").HasColumnName("tedarikcino");
                        j.IndexerProperty<int>("Magazano").HasColumnName("magazano");
                    });
        });

        modelBuilder.Entity<Urunler>(entity =>
        {
            entity.HasKey(e => e.Urunno).HasName("urunler_pkey");

            entity.ToTable("urunler");

            entity.Property(e => e.Urunno).HasColumnName("urunno");
            entity.Property(e => e.Adi)
                .HasMaxLength(15)
                .HasColumnName("adi");
            entity.Property(e => e.Fiyat).HasColumnName("fiyat");
            entity.Property(e => e.Stok).HasColumnName("stok");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}

using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using VeriTabaniProje.Models;

namespace VeriTabaniProje.Data;

public partial class AvmYonetimSistemiContext : DbContext
{
    public AvmYonetimSistemiContext()
    {
    }

    public AvmYonetimSistemiContext(DbContextOptions<AvmYonetimSistemiContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Magazamusteri> Magazamusteris { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseNpgsql("Host=localhost;Port=5432;Database=AvmYonetimSistemi;Username=postgres;Password=RA..20.06.;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Magazamusteri>(entity =>
        {
            entity.HasKey(e => new { e.Musterino, e.Magazano }).HasName("magazamusteri_pkey");

            entity.ToTable("magazamusteri");

            entity.Property(e => e.Musterino).HasColumnName("musterino");
            entity.Property(e => e.Magazano).HasColumnName("magazano");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}

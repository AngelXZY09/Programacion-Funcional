using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace ApiCrud.Entitys;

public partial class CreditosComplementariosContext : DbContext
{
    public CreditosComplementariosContext()
    {
    }

    public CreditosComplementariosContext(DbContextOptions<CreditosComplementariosContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Actividad> Actividad { get; set; }

    public virtual DbSet<Categoria> Categoria { get; set; }

    public virtual DbSet<ConfiguracionGlobal> ConfiguracionGlobal { get; set; }

    public virtual DbSet<EstudianteXactividade> EstudianteXactividades { get; set; }



    public virtual DbSet<VistaCreditoEstudiante> VistaCreditoEstudiantes { get; set; }

 
    //protected override void OnModelCreating(ModelBuilder modelBuilder)
    //{
    //    modelBuilder.Entity<Actividad>(entity =>
    //    {
    //        entity.HasKey(e => e.Id).HasName("PK__Activida__3213E83F2C3F350A");
            
    //        entity.ToTable("Actividad");

    //        entity.Property(e => e.Id).HasColumnName("id");
    //        entity.Property(e => e.Estado)
    //            .HasMaxLength(20)
    //            .IsUnicode(false);
    //        entity.Property(e => e.FechaHoraFin).HasColumnType("datetime");
    //        entity.Property(e => e.FechaHoraInicio).HasColumnType("datetime");
    //        entity.Property(e => e.IdCategoria).HasColumnName("idCategoria");
    //        entity.Property(e => e.IdEncargado).HasColumnName("idEncargado");
    //        entity.Property(e => e.ImagenUrl)
    //            .HasMaxLength(255)
    //            .IsUnicode(false)
    //            .HasColumnName("ImagenURL");
    //        entity.Property(e => e.Instalacion)
    //            .HasMaxLength(100)
    //            .IsUnicode(false);
    //        entity.Property(e => e.NombreActividad)
    //            .HasMaxLength(100)
    //            .IsUnicode(false);

    //        entity.HasOne(d => d.IdCategoriaNavigation).WithMany(p => p.Actividads)
    //            .HasForeignKey(d => d.IdCategoria)
    //            .OnDelete(DeleteBehavior.ClientSetNull)
    //            .HasConstraintName("FK__Actividad__idCat__2F10007B");

    //        entity.HasOne(d => d.IdEncargadoNavigation).WithMany(p => p.)
    //            .HasForeignKey(d => d.IdEncargado)
    //            .OnDelete(DeleteBehavior.ClientSetNull)
    //            .HasConstraintName("FK__Actividad__idEnc__300424B4");
    //    });

    //    modelBuilder.Entity<Categoria>(entity =>
    //    {
    //        entity.HasKey(e => e.Id).HasName("PK__Categori__3213E83FF421B627");

    //        entity.HasIndex(e => e.NombreCategoria, "UQ__Categori__788BF0FACD501FA5").IsUnique();

    //        entity.Property(e => e.Id).HasColumnName("id");
    //        entity.Property(e => e.NombreCategoria)
    //            .HasMaxLength(50)
    //            .IsUnicode(false)
    //            .HasColumnName("nombreCategoria");
    //    });

    //    modelBuilder.Entity<ConfiguracionGlobal>(entity =>
    //    {
    //        entity.HasKey(e => e.Id).HasName("PK__Configur__3213E83FC82E4970");

    //        entity.ToTable("ConfiguracionGlobal");

    //        entity.HasIndex(e => e.Clave, "UQ__Configur__E8181E112E99A80C").IsUnique();

    //        entity.Property(e => e.Id).HasColumnName("id");
    //        entity.Property(e => e.Clave)
    //            .HasMaxLength(100)
    //            .IsUnicode(false);
    //        entity.Property(e => e.Descripcion).HasColumnType("text");
    //        entity.Property(e => e.Valor)
    //            .HasMaxLength(100)
    //            .IsUnicode(false);
    //    });

    //    modelBuilder.Entity<EstudianteXactividade>(entity =>
    //    {
    //        entity.HasKey(e => e.Id).HasName("PK__Estudian__3213E83FAFE78E09");

    //        entity.ToTable("EstudianteXActividades");

    //        entity.Property(e => e.Id).HasColumnName("id");
    //        entity.Property(e => e.Aprobado).HasDefaultValue(false);
    //        entity.Property(e => e.IdActividad).HasColumnName("idActividad");
    //        entity.Property(e => e.IdEstudiante).HasColumnName("idEstudiante");
    //        entity.Property(e => e.IdHorario).HasColumnName("idHorario");

    //        entity.HasOne(d => d.IdActividadNavigation).WithMany(p => p.EstudianteXactividades)
    //            .HasForeignKey(d => d.IdActividad)
    //            .OnDelete(DeleteBehavior.ClientSetNull)
    //            .HasConstraintName("FK__Estudiant__idAct__34C8D9D1");

    //        entity.HasOne(d => d.IdEstudianteNavigation).WithMany(p => p.EstudianteXactividades)
    //            .HasForeignKey(d => d.IdEstudiante)
    //            .OnDelete(DeleteBehavior.ClientSetNull)
    //            .HasConstraintName("FK__Estudiant__idEst__33D4B598");

    //        entity.HasOne(d => d.IdHorarioNavigation).WithMany(p => p.EstudianteXactividades)
    //            .HasForeignKey(d => d.IdHorario)
    //            .HasConstraintName("FK__Estudiant__idHor__4AB81AF0");
    //    });

    //    modelBuilder.Entity<HorarioActividad>(entity =>
    //    {
    //        entity.HasKey(e => e.Id).HasName("PK__HorarioA__3213E83F19DF8FAF");

    //        entity.ToTable("HorarioActividad");

    //        entity.Property(e => e.Id).HasColumnName("id");
    //        entity.Property(e => e.DiaSemana)
    //            .HasMaxLength(35)
    //            .IsUnicode(false);
    //        entity.Property(e => e.IdActividad).HasColumnName("idActividad");

    //        entity.HasOne(d => d.IdActividadNavigation).WithMany(p => p.HorarioActividads)
    //            .HasForeignKey(d => d.IdActividad)
    //            .OnDelete(DeleteBehavior.ClientSetNull)
    //            .HasConstraintName("FK__HorarioAc__idAct__49C3F6B7");
    //    });

    //    modelBuilder.Entity<Rol>(entity =>
    //    {
    //        entity.HasKey(e => e.Id).HasName("PK__Rol__3213E83F829A3D02");

    //        entity.ToTable("Rol");

    //        entity.HasIndex(e => e.NombreRole, "UQ__Rol__1FDFFDE4EF20213D").IsUnique();

    //        entity.Property(e => e.Id).HasColumnName("id");
    //        entity.Property(e => e.NombreRole)
    //            .HasMaxLength(50)
    //            .IsUnicode(false)
    //            .HasColumnName("nombreRole");
    //    });

    //    modelBuilder.Entity<Usuario>(entity =>
    //    {
    //        entity.HasKey(e => e.Id).HasName("PK__Usuario__3213E83F8C6F34C8");

    //        entity.ToTable("Usuario");

    //        entity.HasIndex(e => e.Correo, "UQ__Usuario__60695A196AE73666").IsUnique();

    //        entity.HasIndex(e => e.MatriculaRfc, "UQ__Usuario__C1E55B4507978A20").IsUnique();

    //        entity.Property(e => e.Id).HasColumnName("id");
    //        entity.Property(e => e.Contrasena)
    //            .HasMaxLength(100)
    //            .IsUnicode(false);
    //        entity.Property(e => e.Correo)
    //            .HasMaxLength(100)
    //            .IsUnicode(false);
    //        entity.Property(e => e.IdRol).HasColumnName("idRol");
    //        entity.Property(e => e.MatriculaRfc)
    //            .HasMaxLength(13)
    //            .IsUnicode(false)
    //            .HasColumnName("MatriculaRFC");
    //        entity.Property(e => e.Nombre)
    //            .HasMaxLength(100)
    //            .IsUnicode(false);

    //        entity.HasOne(d => d.IdRolNavigation).WithMany(p => p.Usuarios)
    //            .HasForeignKey(d => d.IdRol)
    //            .OnDelete(DeleteBehavior.ClientSetNull)
    //            .HasConstraintName("FK__Usuario__idRol__29572725");
    //    });

    //    modelBuilder.Entity<VistaCreditoEstudiante>(entity =>
    //    {
    //        entity
    //            .HasNoKey()
    //            .ToView("VistaCreditoEstudiante");

    //        entity.Property(e => e.EstadoCredito)
    //            .HasMaxLength(15)
    //            .IsUnicode(false);
    //        entity.Property(e => e.Nombre)
    //            .HasMaxLength(100)
    //            .IsUnicode(false);
    //        entity.Property(e => e.NombreCategoria)
    //            .HasMaxLength(50)
    //            .IsUnicode(false)
    //            .HasColumnName("nombreCategoria");
    //    });

    //    OnModelCreatingPartial(modelBuilder);
    //}

    //partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}

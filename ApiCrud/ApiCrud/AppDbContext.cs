using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using ApiCrud.Entitys;
using Microsoft.Data.SqlClient;
using System.Data;
namespace ApiCrud
{
    public partial class AppDbContext : IdentityDbContext<User>
    {
       
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        // El tipo de idEstudiante cambia a string
        public async Task<int> InscribirEstudianteSp(string idEstudiante, int idActividad, int idGrupoHorario, int idHorarioDetalle)
        {
            var statusCodeParam = new SqlParameter
            {
                ParameterName = "@statusCode",
                SqlDbType = SqlDbType.Int,
                Direction = ParameterDirection.Output
            };

            // Corrección: Mueve @statusCode OUTPUT
            await Database.ExecuteSqlRawAsync(
                "EXEC [dbo].[inscribir] @idEstudiante, @idActividad, @idGrupoHorario, @idHorarioDetalle, @statusCode OUTPUT", // <-- CAMBIO AQUÍ
                new SqlParameter("@idEstudiante", idEstudiante),
                new SqlParameter("@idActividad", idActividad),
                new SqlParameter("@idGrupoHorario", idGrupoHorario),
                new SqlParameter("@idHorarioDetalle", idHorarioDetalle),
                statusCodeParam // Este es el SqlParameter que creaste antes
            );

            return (int)statusCodeParam.Value;
        }

        public virtual DbSet<Actividad> Actividad { get; set; }
        public virtual DbSet<Categoria> Categoria { get; set; }
        public virtual DbSet<ConfiguracionGlobal> ConfiguracionGlobal { get; set; }
        public virtual DbSet<EstudianteXactividade> EstudianteXactividades { get; set; }
        // public virtual DbSet<VistaCreditoEstudiante> VistaCreditoEstudiantes { get; set; }
        public async Task<EstudianteXactividade?> GetInscripcionByIdAndStudentAsync(int idInscripcion, string idEstudiante)
        {
            return await EstudianteXactividades
                .FirstOrDefaultAsync(e => e.Id == idInscripcion && e.IdEstudiante == idEstudiante);
        }
        // Nuevas tablas  
        public virtual DbSet<Periodo> Periodos { get; set; }
        public virtual DbSet<ActividadxPeriodo> ActividadxPeriodos { get; set; }
        public virtual DbSet<GrupoHorario> GruposHorario { get; set; }
        public virtual DbSet<HorarioDetalle> HorarioDetalles { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            OnModelCreatingPartial(modelBuilder);
            modelBuilder.Entity<Actividad>(entity =>
            {
                entity.HasKey(e => e.Id).HasName("PK__Activida__3213E83F2C3F350A");

                entity.ToTable("Actividad");

                entity.Property(e => e.Id).HasColumnName("id");
                entity.Property(e => e.Estado).HasMaxLength(20).IsUnicode(false);
                entity.Property(e => e.FechaHoraFin).HasColumnType("date");
                entity.Property(e => e.FechaHoraInicio).HasColumnType("date");
                entity.Property(e => e.IdCategoria).HasColumnName("idCategoria");
                entity.Property(e => e.IdEncargado).HasColumnName("idEncargado");
                entity.Property(e => e.ImagenUrl).HasMaxLength(255).IsUnicode(false).HasColumnName("ImagenURL");
                entity.Property(e => e.Instalacion).HasMaxLength(100).IsUnicode(false);
                entity.Property(e => e.NombreActividad).HasMaxLength(100).IsUnicode(false);
                entity.Property(e => e.Creditos).HasDefaultValue(0);
                entity.Property(e => e.Descripcion).HasMaxLength(500).IsUnicode(false);
                entity.Property(e => e.DatosExtra).HasMaxLength(250).IsUnicode(false);
                entity.HasOne(d => d.IdCategoriaNavigation).WithMany(p => p.Actividads)
                    .HasForeignKey(d => d.IdCategoria)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__Actividad__idCat__2F10007B");

                entity.HasOne(d => d.IdEncargadoNavigation)
                    .WithMany()
                    .HasForeignKey(d => d.IdEncargado)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__Actividad__idEnc__300424B4");

                entity.HasMany(a => a.ActividadXPeriodos)
                    .WithOne(ap => ap.Actividad)
                    .HasForeignKey(ap => ap.ActividadId);
            });

            modelBuilder.Entity<Categoria>(entity =>
            {
                entity.HasKey(e => e.Id);

                entity.ToTable("Categoria");

                entity.Property(e => e.Id).HasColumnName("id");
                entity.Property(e => e.NombreCategoria)
                      .IsRequired()
                      .HasMaxLength(50)
                      .IsUnicode(false)
                      .HasColumnName("nombreCategoria");
            });

            modelBuilder.Entity<EstudianteXactividade>(entity =>
            {
                entity.HasKey(e => e.Id).HasName("PK__Estudian__3213E83FAFE78E09");

                entity.ToTable("EstudianteXActividades");

                entity.Property(e => e.Id).HasColumnName("id");
                entity.Property(e => e.Aprobado).HasDefaultValue(false);
                entity.Property(e => e.IdEstudiante).HasColumnName("idEstudiante");
                entity.Property(e => e.FechaInscripcion).HasColumnType("date");

                entity.HasOne(e => e.IdEstudianteNavigation)
                    .WithMany()
                    .HasForeignKey(e => e.IdEstudiante)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__Estudiant__idEst__33D4B598");

                entity.HasOne(e => e.idGrupoHorarioNavigation)
                    .WithMany(g => g.EstudianteXactividades)
                    .HasForeignKey(e => e.IdGrupoHorario)
                    .OnDelete(DeleteBehavior.Cascade)
                    .HasConstraintName("FK__Estudiant__idGru__GrupoHorario");

                entity.HasOne(e => e.idHorarioDetalleNavigation)
                    .WithMany(h => h.EstudianteXactividades)
                    .HasForeignKey(e => e.IdHorarioDetalle)
                    .HasConstraintName("FK__Estudiant__idHor__HorarioDetalle");
            });

            modelBuilder.Entity<Periodo>(entity =>
            {
                entity.HasKey(p => p.Id);
                entity.Property(p => p.EtiquetaPeriodo).HasMaxLength(70).IsRequired();
                entity.Property(p => p.FechaHoraInicio).HasColumnType("date");
                entity.Property(p => p.FechaHoraFin).HasColumnType("date");
            });

            modelBuilder.Entity<ActividadxPeriodo>(entity =>
            {
                entity.HasKey(ap => ap.Id);
                entity.HasOne(ap => ap.Actividad)
                      .WithMany(a => a.ActividadXPeriodos)
                      .HasForeignKey(ap => ap.ActividadId);

                entity.HasOne(ap => ap.Periodo)
                      .WithMany(p => p.ActividadXPeriodos)
                      .HasForeignKey(ap => ap.PeriodoId);
            });

            modelBuilder.Entity<GrupoHorario>(entity =>
            {
                entity.HasKey(g => g.Id);

                entity.HasOne(g => g.Actividad)
                      .WithMany(a => a.GruposHorario)
                      .HasForeignKey(g => g.ActividadId)
                      .OnDelete(DeleteBehavior.Cascade);


            });

            modelBuilder.Entity<HorarioDetalle>(entity =>
            {
                entity.ToTable(t =>
                {
                    t.HasCheckConstraint("CK_HorarioDetalle_HoraInicio_Fin", "HoraInicio < HoraFin");
                    t.HasComment("Tabla que define los horarios detallados de un grupo horario.");

                    t.HasCheckConstraint("CK_HorarioDetalle_DiaSemanaOrFecha",
        "(Fecha IS NOT NULL OR DiaSemana IS NOT NULL)");
                    t.HasComment("Debe tener al menos un valor entre Fecha o DiaSemana.");
                });
                entity.HasKey(h => h.Id);
                entity.Property(h => h.Fecha).HasColumnType("date");
                entity.Property(h => h.DiaSemana).HasMaxLength(20);
                entity.Property(h => h.HoraInicio).HasColumnType("time");
                entity.Property(h => h.HoraFin).HasColumnType("time");

                entity.HasOne(h => h.GrupoHorario)
                      .WithMany(g => g.HorariosDetalle)
                      .HasForeignKey(h => h.GrupoHorarioId);
            });





        }
        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }



}

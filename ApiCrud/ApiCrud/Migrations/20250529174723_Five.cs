using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ApiCrud.Migrations
{
    /// <inheritdoc />
    public partial class Five : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterTable(
                name: "HorarioDetalles",
                comment: "Debe tener al menos un valor entre Fecha o DiaSemana.");

            migrationBuilder.AddColumn<string>(
                name: "TipoDeHorario",
                table: "GruposHorario",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<string>(
                name: "Nombre",
                table: "AspNetUsers",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(100)",
                oldMaxLength: 100,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "MatriculaRfc",
                table: "AspNetUsers",
                type: "nvarchar(14)",
                maxLength: 14,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(14)",
                oldMaxLength: 14,
                oldNullable: true);

            migrationBuilder.AddCheckConstraint(
                name: "CK_HorarioDetalle_DiaSemanaOrFecha",
                table: "HorarioDetalles",
                sql: "(Fecha IS NOT NULL OR DiaSemana IS NOT NULL)");

            migrationBuilder.AddCheckConstraint(
                name: "CK_HorarioDetalle_HoraInicio_Fin",
                table: "HorarioDetalles",
                sql: "HoraInicio < HoraFin");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_HorarioDetalle_DiaSemanaOrFecha",
                table: "HorarioDetalles");

            migrationBuilder.DropCheckConstraint(
                name: "CK_HorarioDetalle_HoraInicio_Fin",
                table: "HorarioDetalles");

            migrationBuilder.DropColumn(
                name: "TipoDeHorario",
                table: "GruposHorario");

            migrationBuilder.AlterTable(
                name: "HorarioDetalles",
                oldComment: "Debe tener al menos un valor entre Fecha o DiaSemana.");

            migrationBuilder.AlterColumn<string>(
                name: "Nombre",
                table: "AspNetUsers",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(100)",
                oldMaxLength: 100);

            migrationBuilder.AlterColumn<string>(
                name: "MatriculaRfc",
                table: "AspNetUsers",
                type: "nvarchar(14)",
                maxLength: 14,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(14)",
                oldMaxLength: 14);
        }
    }
}

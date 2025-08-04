using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ApiCrud.Migrations
{
    /// <inheritdoc />
    public partial class Final : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "IdHorarioDetalle",
                table: "EstudianteXActividades",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_EstudianteXActividades_IdHorarioDetalle",
                table: "EstudianteXActividades",
                column: "IdHorarioDetalle");

            migrationBuilder.AddForeignKey(
                name: "FK__Estudiant__idHor__HorarioDetalle",
                table: "EstudianteXActividades",
                column: "IdHorarioDetalle",
                principalTable: "HorarioDetalles",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Estudiant__idHor__HorarioDetalle",
                table: "EstudianteXActividades");

            migrationBuilder.DropIndex(
                name: "IX_EstudianteXActividades_IdHorarioDetalle",
                table: "EstudianteXActividades");

            migrationBuilder.DropColumn(
                name: "IdHorarioDetalle",
                table: "EstudianteXActividades");
        }
    }
}

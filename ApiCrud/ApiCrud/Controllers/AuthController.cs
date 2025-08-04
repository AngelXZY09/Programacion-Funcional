using ApiCrud.DTOs;
using ApiCrud.Entitys;
using Microsoft.AspNetCore.Identity;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.Data;

namespace ApiCrud.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<User> _userManager;
        private readonly IConfiguration _config;
        private readonly RoleManager<IdentityRole> _roleManager;
        public AuthController(UserManager<User> userManager, IConfiguration config, RoleManager<IdentityRole> roleManager)
        {
            _userManager = userManager;
            _config = config;
            _roleManager = roleManager;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(RegisterDto model)
        {
            if (!await _roleManager.RoleExistsAsync(model.role))
                return BadRequest($"El rol '{model.role}' no existe.");

            var user = new User
            {
                UserName = model.Email,
                Email = model.Email,
                MatriculaRfc = model.Matricula,
                Nombre = model.Nombre
            };

            var result = await _userManager.CreateAsync(user, model.Password);

            if (!result.Succeeded)
                return BadRequest(result.Errors);

            var userCreated = await _userManager.FindByEmailAsync(model.Email);
            if (userCreated == null)
                return BadRequest("El usuario no fue encontrado tras su creación.");

            var roleResult = await _userManager.AddToRoleAsync(userCreated, model.role);
            if (!roleResult.Succeeded)
                return BadRequest(roleResult.Errors);

            // Opcional: verificar roles asignados
            var rolesUser = await _userManager.GetRolesAsync(userCreated);

            return Ok(new
            {
                message = "Usuario registrado con rol asignado",
                roles = rolesUser
            });
        }


        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginDto model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = await _userManager.FindByEmailAsync(model.UserName);

            if (user == null || !await _userManager.CheckPasswordAsync(user, model.Password))
                return Unauthorized();

            var claims = new[]
            {
            new Claim(ClaimTypes.NameIdentifier, user.Id),
            new Claim(JwtRegisteredClaimNames.UniqueName, user.UserName),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim("nombre",user.Nombre),
            new Claim("matricula",user.MatriculaRfc),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
               issuer: _config["Jwt:Issuer"],
               audience: _config["Jwt:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddHours(9),
                signingCredentials: creds);

            return Ok(new { token = new JwtSecurityTokenHandler().WriteToken(token) });
        }
    }

}

using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.UI.Services;
namespace ApiCrud.Entitys
{
    public class DummyEmailSender : IEmailSender<User>
    {
        public Task SendConfirmationLinkAsync(User user, string email, string confirmationLink)
        {
            Console.WriteLine($"[Dummy] Confirmación enviada a {email}: {confirmationLink}");
            return Task.CompletedTask;
        }

        public Task SendPasswordResetLinkAsync(User user, string email, string resetLink)
        {
            Console.WriteLine($"[Dummy] Reset password para {email}: {resetLink}");
            return Task.CompletedTask;
        }

        public Task SendPasswordResetCodeAsync(User user, string email, string resetCode)
        {
            Console.WriteLine($"[Dummy] Código de restablecimiento enviado a {email}: {resetCode}");
            return Task.CompletedTask;
        }
    }
}

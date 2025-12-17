using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using VeriTabaniProje.Models;

namespace VeriTabaniProje.Controllers
{
	public class AccountController : Controller
	{
		[HttpGet]
		public IActionResult Login()
		{
			return View();
		}
		[HttpPost]
		public async Task<IActionResult> Login(LoginViewModel model)
		{
			if (model.KullaniciAdi == "admin" && model.Sifre == "12345")
			{
				var claims = new List<Claim>
				{
					new Claim(ClaimTypes.Name, model.KullaniciAdi)
				};
				var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
				var authProperties = new AuthenticationProperties();

				await HttpContext.SignInAsync(
					CookieAuthenticationDefaults.AuthenticationScheme,
					new ClaimsPrincipal(claimsIdentity),
					authProperties);

				return RedirectToAction("Index", "Home");
			}
			ViewBag.Error = "Kullanıcı adı veya şifre hatalı!";
			return View(model);
		}
		public async Task<IActionResult> Logout()
		{
			await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
			return RedirectToAction("Login", "Account");
		}
	}
}
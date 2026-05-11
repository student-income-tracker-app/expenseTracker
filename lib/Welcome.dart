import 'package:flutter/material.dart';
import 'Login.dart';
import 'user_register.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDADCF6), // Light lavender background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ----------- LOGO -----------
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                "images/smartspend.png", // <-- your new logo
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 25),

            // ---------- TITLE ----------
            const Text(
              "SAY HI TO YOUR NEW\nFINANCE TRACKER",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF1C265A), // Dark blue
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 18),

            // ---------- SUBTEXT (UPDATED) ----------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Great job taking control of your finances! Every small step counts towards your financial freedom.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF3B3D56), // Soft blue-gray
                ),
              ),
            ),

            const SizedBox(height: 45),

            // ----------- LOGIN BUTTON -----------
            SizedBox(
              width: 250,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C7BA6), // Blue button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ----------- SIGN UP BUTTON -----------
            SizedBox(
              width: 250,
              height: 55,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserRegister()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF6C7BA6),
                    width: 2,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF1C265A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

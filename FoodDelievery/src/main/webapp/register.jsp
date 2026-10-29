<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Join Us | FoodieDash</title>
<style>
    body {
        font-family: 'Poppins', sans-serif;
        margin: 0;
        min-height: 100vh; /* Changed to min-height to allow scrolling if needed */
        display: flex;
        justify-content: center;
        align-items: center;
        background: linear-gradient(-45deg, #2d3436, #6c5ce7, #a29bfe, #fd79a8);
        background-size: 400% 400%;
        animation: gradientBG 15s ease infinite;
        padding: 20px; /* Added padding for mobile responsiveness */
    }

    @keyframes gradientBG {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    .register-card {
        background: rgba(255, 255, 255, 0.95);
        padding: 30px 40px;
        border-radius: 24px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        width: 100%;
        max-width: 450px;
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.3);
    }

    .register-card h2 {
        text-align: center;
        color: #2d3436;
        margin-bottom: 5px;
        font-size: 1.8rem;
        font-weight: 800;
    }

    .register-card p {
        text-align: center;
        color: #636e72;
        font-size: 0.9rem;
        margin-bottom: 20px;
    }

    .input-group {
        margin-bottom: 15px;
    }

    label {
        display: block;
        font-size: 0.75rem;
        color: #2d3436;
        margin-bottom: 5px;
        font-weight: 700;
        text-transform: uppercase;
    }

    input[type="text"],
    input[type="email"],
    input[type="tel"],
    input[type="password"],
    textarea {
        width: 100%;
        padding: 12px;
        border: 2px solid #f1f2f6;
        border-radius: 12px;
        box-sizing: border-box;
        font-size: 0.95rem;
        transition: all 0.3s ease;
        background: #f9f9fb;
        font-family: inherit;
    }

    textarea {
        resize: none;
        height: 80px;
    }

    input:focus, textarea:focus {
        outline: none;
        border-color: #fd79a8;
        background-color: #fff;
        box-shadow: 0 0 12px rgba(253, 121, 168, 0.2);
    }

    .btn-submit {
        width: 100%;
        padding: 15px;
        background: linear-gradient(to right, #6c5ce7, #fd79a8);
        color: white;
        border: none;
        border-radius: 12px;
        font-size: 1.1rem;
        font-weight: 700;
        cursor: pointer;
        transition: transform 0.2s, box-shadow 0.2s;
        margin-top: 10px;
    }

    .btn-submit:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(108, 92, 231, 0.4);
    }

    .footer-link {
        text-align: center;
        margin-top: 20px;
        font-size: 0.85rem;
        color: #636e72;
    }

    .footer-link a {
        color: #6c5ce7;
        text-decoration: none;
        font-weight: 700;
    }
</style>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;800&display=swap" rel="stylesheet">
</head>
<body>

<div class="register-card">
    <h2>Join FoodieDash</h2>
    <p>Complete your profile to start ordering.</p>

    <form action="register" method="post">
        <div class="input-group">
            <label>Full Name</label>
            <input type="text" name="name" placeholder="Alex Smith" required>
        </div>

        <div class="input-group">
            <label>Email Address</label>
            <input type="email" name="email" placeholder="alex@mail.com" required>
        </div>

        <div class="input-group">
            <label>Phone Number</label>
            <input type="tel" name="phone" placeholder="+1 (555) 000-0000" required>
        </div>

        <div class="input-group">
            <label>Delivery Address</label>
            <textarea name="address" placeholder="123 Street Name, City, Zip Code" required></textarea>
        </div>

        <div class="input-group">
            <label>Password</label>
            <input type="password" name="password" placeholder="••••••••" required>
        </div>

        <button type="submit" class="btn-submit">Create Account</button>
    </form>

    <div class="footer-link">
        Already have an account? <a href="login.jsp">Login here</a>
    </div>
</div>

</body>
</html>